local refineryProgress = {}
local lastCollection = {}

-- [[ CALLBACKS ]] --
lib.callback.register("zotters:getEmptyBucketCount", function(src)
    return exports.ox_inventory:GetItemCount(src, "empty_oil") or 0
end)

-- [[ UTILITIES ]] --
local function notify(src, title, description, type)
    TriggerClientEvent("ox_lib:notify", src, {
        title = title,
        description = description,
        type = type or "info"
    })
end

local function updateRefineryUI(src, state)
    local phaseLabels = {
        [1] = "Loading",
        [2] = "Distilling",
        [3] = "Extracting"
    }

    TriggerClientEvent("ZOTTERS-REFINERY:UpdateUI", src, {
        oilLabel = Config.RefineryTypes[state.oilType].label,
        hopperCount = state.hopperCount or 0,
        maxFill = Config.HopperFill,
        phase = phaseLabels[state.phase] or "Idle",
        position = Config.RefineryPanel.position
    })
end

local function getOilType(src)
    for oilName, data in pairs(Config.RefineryTypes) do
        if exports.ox_inventory:GetItemCount(src, oilName) > 0 then
            return oilName, data.result, data.label
        end
    end
    return nil
end

-- [[ OIL COLLECTION ]] --
RegisterNetEvent('zotters-oilcontainer', function(oilType)
    local src = source
    local inv = exports.ox_inventory

    if inv:GetItemCount(src, "empty_oil") < 1 then
        return TriggerClientEvent('ZOTTERS-MISSINGITEM', src)
    end

    if inv:RemoveItem(src, "empty_oil", 1) then
        inv:AddItem(src, oilType, 1)
    else
        TriggerClientEvent('ZOTTERS-FULLINVENTORY', src)
    end
end)

-- [[ PHASE 1: LOAD HOPPER ]] --
RegisterNetEvent("ZOTTERS-REFINERY:StartRefine", function()
    local src = source
    local state = refineryProgress[src]

    if state and state.phase ~= 1 then
        if state.phase == 3 then
            local d, e, h = state.distilledCount or 0, state.extractedCount or 0, state.hopperCount or 0
            if d >= h and e >= d then
                refineryProgress[src] = nil
                state = nil
            else
                return notify(src, Config.OilCompany, "Finish collecting all refined product before reloading the hopper.", "error")
            end
        else
            return notify(src, Config.OilCompany, "You're still in the middle of processing. Finish current phase first.", "error")
        end
    end

    local oilType, result, label = getOilType(src)
    if not oilType then return TriggerClientEvent("ZOTTERS-MISSINGITEM", src) end

    state = refineryProgress[src]
    if state then
        if state.oilType ~= oilType then
            return notify(src, Config.OilCompany, "Can't mix oil types. Hopper is set for: " .. Config.RefineryTypes[state.oilType].label, "error")
        end
        if (state.hopperCount or 0) >= Config.HopperFill then
            return notify(src, Config.OilCompany, "Hopper is full. Start distillation first.", "error")
        end
    end

    local drumCount = exports.ox_inventory:GetItemCount(src, oilType)
    if drumCount < 1 then
        return notify(src, Config.OilCompany, "You don’t have any oil to load.", "error")
    end

    local availableSpace = Config.HopperFill - (state and state.hopperCount or 0)
    local toLoad = math.min(drumCount, availableSpace)

    refineryProgress[src] = state or {}
    state = refineryProgress[src]
    state.oilType = oilType
    state.result = result
    state.maxFill = Config.HopperFill
    state.hopperCount = state.hopperCount or 0
    state.distilledCount = state.distilledCount or 0
    state.extractedCount = state.extractedCount or 0
    state.phase = 1

    updateRefineryUI(src, state)
    TriggerClientEvent("ZOTTERS-REFINERY:BeginHopperLoad", src, toLoad, oilType)
end)

RegisterNetEvent("ZOTTERS-REFINERY:LoadOne", function()
    local src = source
    local state = refineryProgress[src]
    if not state then return end

    local oilType = state.oilType
    if not exports.ox_inventory:RemoveItem(src, oilType, 1) then
        return notify(src, Config.OilCompany, "Failed to remove oil during loading.", "error")
    end

    state.hopperCount = (state.hopperCount or 0) + 1
    updateRefineryUI(src, state)
end)

-- [[ PHASE 2: DISTILLATION ]] --
RegisterNetEvent("ZOTTERS-REFINERY:StartDistillation", function()
    local src = source
    local state = refineryProgress[src]
    if not state or state.phase ~= 1 then
        return notify(src, Config.OilCompany, "You must load the hopper before distilling.", "error")
    end

    local toDistill = (state.hopperCount or 0) - (state.distilledCount or 0)
    if toDistill < 1 then
        return notify(src, Config.OilCompany, "You've already distilled everything loaded.", "error")
    end

    state.phase = 2
    updateRefineryUI(src, state)
    TriggerClientEvent("ZOTTERS-REFINERY:BeginDistillation", src, toDistill, state.oilType)
end)

RegisterNetEvent("ZOTTERS-REFINERY:DistillOne", function()
    local src = source
    local state = refineryProgress[src]
    if not state then return end

    state.hopperCount = math.max((state.hopperCount or 0) - 1, 0)
    state.distilledCount = (state.distilledCount or 0) + 1

    if state.hopperCount <= 0 then
        state.phase = 3
    end

    updateRefineryUI(src, state)
end)

RegisterNetEvent("ZOTTERS-REFINERY:DistillComplete", function()
    local src = source
    local state = refineryProgress[src]
    if not state then return end

    if state.hopperCount <= 0 then
        state.phase = 3
        notify(src, Config.OilCompany, "All drums processed. You may now extract.", "success")
    else
        state.phase = 1
        notify(src, Config.OilCompany, "You can resume distilling remaining drums.", "info")
    end

    updateRefineryUI(src, state)
end)

-- [[ PHASE 3: EXTRACTION ]] --
RegisterNetEvent("ZOTTERS-REFINERY:StartExtraction", function()
    local src = source
    local state = refineryProgress[src]
    if not state then
        return notify(src, Config.OilCompany, "No refinery data available.", "error")
    end

    local d, e = state.distilledCount or 0, state.extractedCount or 0
    local toExtract = d - e

    if toExtract < 1 then
        return notify(src, Config.OilCompany, "You've already extracted all available refined product.", "error")
    end

    updateRefineryUI(src, state)
    TriggerClientEvent("ZOTTERS-REFINERY:BeginExtraction", src, toExtract, state.result, state.oilType)
end)

RegisterNetEvent("ZOTTERS-REFINERY:ExtractOne", function(resultItem, oilType)
    local src = source
    local state = refineryProgress[src]
    if not state then return end

    local oilConfig = Config.RefineryTypes[oilType]
    if not oilConfig then return end

    -- Quality roll
    local roll = math.random()
    local q = oilConfig.qualityChances
    local quality = (roll <= q.pure and "pure") or (roll <= q.pure + q.standard and "standard") or "dirty"
    local finalItem = oilConfig.result .. "_" .. quality

    exports.ox_inventory:AddItem(src, finalItem, 1)

    -- Byproduct roll
    for item, chance in pairs(oilConfig.byproducts or {}) do
        if math.random() < chance then
            exports.ox_inventory:AddItem(src, item, 1)
        end
    end

    -- Progress tracking
    state.extractedCount = (state.extractedCount or 0) + 1

    if state.extractedCount >= state.distilledCount then
        refineryProgress[src] = nil
        TriggerClientEvent("ZOTTERS-REFINERY:HideUI", src)
    else
        updateRefineryUI(src, state)
    end
end)

-- [[ DEBUG COMMANDS ]] --
