local isRefining = false

CreateThread(function()
    Wait(1500)

    Fiji.AddInteraction(
        'fiji_refinery_hopper',
        { type = 'box', coords = Config.Hopper, size = vec3(3, 3, 3), rotation = 0 },
        { { name = 'load_hopper', icon = 'fa-solid fa-arrow-down', label = 'Load Hopper', event = 'fiji-oil:client:openHopperMenu' } },
        Config.Debug or false
    )

    Fiji.AddInteraction(
        'fiji_refinery_distill',
        { type = 'box', coords = Config.Distill, size = vec3(3, 3, 3), rotation = 0 },
        { { name = 'start_distillation', icon = 'fa-solid fa-temperature-high', label = 'Begin Distillation', event = 'fiji-oil:client:startDistillation' } },
        Config.Debug or false
    )

    Fiji.AddInteraction(
        'fiji_refinery_extraction',
        { type = 'box', coords = Config.Extraction, size = vec3(3, 3, 3), rotation = 0 },
        { { name = 'start_extraction', icon = 'fa-solid fa-flask', label = 'Extract Refined Oil', event = 'fiji-oil:client:startExtraction' } },
        Config.Debug or false
    )
end)

RegisterNetEvent('fiji-oil:client:openHopperMenu', function() OpenHopperMenu() end)
RegisterNetEvent('fiji-oil:client:startDistillation', function() StartDistillation() end)
RegisterNetEvent('fiji-oil:client:startExtraction', function() StartExtraction() end)

local function GetPerks()
    return Callback.TriggerSync('fiji-oil:refinery:getPerks', nil) or { timeMultiplier = 1.0, pureBonus = 0 }
end

function OpenHopperMenu()
    if isRefining then
        UI.Notify({ description = 'Refinery is busy', type = 'error' })
        return
    end

    local oilData = Callback.TriggerSync('fiji-oil:refinery:getAvailableOil', nil) or {}
    if #oilData == 0 then
        UI.Notify({ description = "You don't have any crude oil", type = 'error' })
        return
    end

    local options = {}
    for _, oil in ipairs(oilData) do
        table.insert(options, {
            title = 'Load ' .. oil.label,
            description = 'You have ' .. oil.count .. 'x ' .. oil.label,
            onSelect = function() LoadHopper(oil.name, oil.count) end,
        })
    end

    UI.ContextMenu('Select Oil Type', options)
end

function LoadHopper(oilType, availableCount)
    if isRefining then return end

    local state = Callback.TriggerSync('fiji-oil:refinery:getState', nil) or { hopperCount = 0, oilType = nil }

    if state.oilType and state.oilType ~= oilType then
        UI.Notify({ description = "Cannot mix different oil types", type = 'error' })
        return
    end

    local maxLoad = Config.HopperFill - (state.hopperCount or 0)
    local toLoad = math.min(availableCount, maxLoad)

    if toLoad <= 0 then
        UI.Notify({ description = "Hopper is already full", type = 'error' })
        return
    end

    isRefining = true
    local perks = GetPerks()
    local loaded = 0
    local cancelled = false

    for i = 1, toLoad do
        if UI.ProgressBar({
            duration = math.floor(Config.HopperTime * perks.timeMultiplier),
            label = 'Loading Hopper (' .. i .. '/' .. toLoad .. ')',
            canCancel = true,
            disable = { car = true, move = true, combat = true },
        }) then
            TriggerServerEvent('fiji-oil:server:loadHopper', oilType)
            loaded = loaded + 1
        else
            cancelled = true
            break
        end
    end

    isRefining = false

    if cancelled then
        UI.Notify({ description = 'Hopper loading cancelled after loading ' .. loaded .. ' units', type = 'inform' })
    else
        UI.Notify({ description = 'Successfully loaded ' .. loaded .. ' units into the hopper', type = 'success' })
    end
end

function StartDistillation()
    if isRefining then return end

    local state = Callback.TriggerSync('fiji-oil:refinery:getState', nil) or { hopperCount = 0 }

    if not state.oilType or (state.hopperCount or 0) <= 0 then
        UI.Notify({ description = "Hopper is empty", type = 'error' })
        return
    end

    local oilConfig = Config.RefineryTypes[state.oilType]
    if not oilConfig then
        UI.Notify({ description = "Invalid oil type", type = 'error' })
        return
    end

    isRefining = true
    local perks = GetPerks()
    local toDistill = state.hopperCount
    local distilled = 0
    local cancelled = false

    for i = 1, toDistill do
        if UI.ProgressBar({
            duration = math.floor(oilConfig.distillTime * perks.timeMultiplier),
            label = 'Distilling Oil (' .. i .. '/' .. toDistill .. ')',
            canCancel = true,
            disable = { car = true, move = true, combat = true },
        }) then
            TriggerServerEvent('fiji-oil:server:distillOne')
            distilled = distilled + 1
        else
            cancelled = true
            break
        end
    end

    isRefining = false
    TriggerServerEvent('fiji-oil:server:distillComplete')

    if cancelled then
        UI.Notify({ description = 'Distillation cancelled after processing ' .. distilled .. ' units', type = 'inform' })
    else
        UI.Notify({ description = 'Successfully distilled ' .. distilled .. ' units of oil', type = 'success' })
    end
end

function StartExtraction()
    if isRefining then return end

    local state = Callback.TriggerSync('fiji-oil:refinery:getState', nil) or { distilledCount = 0, extractedCount = 0 }
    local toExtract = (state.distilledCount or 0) - (state.extractedCount or 0)

    if toExtract <= 0 then
        UI.Notify({ description = "No distilled oil to extract", type = 'error' })
        return
    end

    local oilConfig = Config.RefineryTypes[state.oilType]
    if not oilConfig then
        UI.Notify({ description = "Invalid oil type", type = 'error' })
        return
    end

    isRefining = true
    local perks = GetPerks()
    local extracted = 0
    local cancelled = false

    for i = 1, toExtract do
        if UI.ProgressBar({
            duration = math.floor(oilConfig.extractionTime * perks.timeMultiplier),
            label = 'Extracting Oil (' .. i .. '/' .. toExtract .. ')',
            canCancel = true,
            disable = { car = true, move = true, combat = true },
        }) then
            TriggerServerEvent('fiji-oil:server:extractOil')
            extracted = extracted + 1
        else
            cancelled = true
            break
        end
    end

    isRefining = false

    if cancelled then
        UI.Notify({ description = 'Extraction cancelled after extracting ' .. extracted .. ' units', type = 'inform' })
    else
        UI.Notify({ description = 'Successfully extracted ' .. extracted .. ' units of refined oil', type = 'success' })
    end
end
