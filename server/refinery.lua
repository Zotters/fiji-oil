-- Same 3-phase hopper -> distill -> extract flow as V1, with Meridian's
-- refining perk (faster times, better pure-quality odds) applied.

local refineryProgress = {}
local nextActionAt = {}

-- ox_target/proximity zones are UX filters only - re-validate distance server-side.
local function IsNearStation(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    return #(GetEntityCoords(ped) - coords) <= maxDist
end

-- Blocks a client from spamming these events far faster than the progress bar
-- it's supposed to sit behind - floor is set below the fastest legitimate
-- (max-perk) time so real players never trip it, only a client skipping the wait.
local function PassesRateLimit(source, minMs)
    local now = GetGameTimer()
    if (nextActionAt[source] or 0) > now then
        return false
    end
    nextActionAt[source] = now + math.floor(minMs * 0.6)
    return true
end

local function GetMeridianPerk(source)
    local identifier = Fiji.GetIdentifier(source)
    if not identifier then return { timeMultiplier = 1.0, pureBonus = 0 } end

    local tier = GetCompanyPerkTier('meridian', GetCompanyReputation(identifier, 'meridian'))
    if not tier then return { timeMultiplier = 1.0, pureBonus = 0 } end

    return { timeMultiplier = tier.refineTimeMultiplier or 1.0, pureBonus = tier.pureChanceBonus or 0 }
end

Callback.Register('fiji-oil:refinery:getPerks', function(source)
    return GetMeridianPerk(source)
end)

Callback.Register('fiji-oil:refinery:getAvailableOil', function(source)
    local oilData = {}

    local hasLightOil, lightCount = Fiji.HasItem(source, 'crude_light')
    if hasLightOil and lightCount > 0 then
        table.insert(oilData, { name = 'crude_light', label = Fiji.GetItemLabel('crude_light'), count = lightCount })
    end

    local hasHeavyOil, heavyCount = Fiji.HasItem(source, 'crude_heavy')
    if hasHeavyOil and heavyCount > 0 then
        table.insert(oilData, { name = 'crude_heavy', label = Fiji.GetItemLabel('crude_heavy'), count = heavyCount })
    end

    return oilData
end)

Callback.Register('fiji-oil:refinery:getState', function(source)
    return refineryProgress[source] or { phase = 0, oilType = nil, hopperCount = 0, distilledCount = 0, extractedCount = 0 }
end)

RegisterNetEvent('fiji-oil:server:loadHopper', function(oilType)
    local source = source

    if not Config.RefineryTypes[oilType] then
        Fiji.Notify(source, "Invalid oil type", "error")
        return
    end

    if not IsNearStation(source, Config.Hopper, 5.0) then
        return
    end

    if not PassesRateLimit(source, Config.HopperTime) then
        return
    end

    local hasOil, oilCount = Fiji.HasItem(source, oilType)
    if not hasOil or oilCount < 1 then
        Fiji.Notify(source, "You don't have any " .. Fiji.GetItemLabel(oilType), "error")
        return
    end

    if not refineryProgress[source] then
        refineryProgress[source] = { oilType = oilType, hopperCount = 0, distilledCount = 0, extractedCount = 0, phase = 1 }
    end

    if refineryProgress[source].oilType ~= oilType then
        Fiji.Notify(source, "Cannot mix different oil types", "error")
        return
    end

    if refineryProgress[source].hopperCount >= Config.HopperFill then
        Fiji.Notify(source, "Hopper is already full", "error")
        return
    end

    if Fiji.RemoveItem(source, oilType, 1) then
        refineryProgress[source].hopperCount = refineryProgress[source].hopperCount + 1
    else
        Fiji.Notify(source, "Failed to remove oil from inventory", "error")
    end
end)

RegisterNetEvent('fiji-oil:server:distillOne', function()
    local source = source
    if not refineryProgress[source] then
        Fiji.Notify(source, "No active refining process", "error")
        return
    end

    if not IsNearStation(source, Config.Distill, 5.0) then
        return
    end

    local oilConfig = Config.RefineryTypes[refineryProgress[source].oilType]
    if not oilConfig or not PassesRateLimit(source, oilConfig.distillTime) then
        return
    end

    refineryProgress[source].hopperCount = math.max((refineryProgress[source].hopperCount or 0) - 1, 0)
    refineryProgress[source].distilledCount = (refineryProgress[source].distilledCount or 0) + 1
    refineryProgress[source].phase = 2
end)

RegisterNetEvent('fiji-oil:server:distillComplete', function()
    local source = source
    if not refineryProgress[source] then return end

    if refineryProgress[source].hopperCount <= 0 then
        refineryProgress[source].phase = 3
        Fiji.Notify(source, "All oil processed. Ready for extraction.", "success")
    else
        refineryProgress[source].phase = 1
        Fiji.Notify(source, "Distillation complete. You can continue loading or distilling.", "inform")
    end
end)

RegisterNetEvent('fiji-oil:server:extractOil', function()
    local source = source

    if not refineryProgress[source] then
        Fiji.Notify(source, "No active refining process", "error")
        return
    end

    if not IsNearStation(source, Config.Extraction, 5.0) then
        return
    end

    local toExtract = refineryProgress[source].distilledCount - refineryProgress[source].extractedCount
    if toExtract <= 0 then
        Fiji.Notify(source, "No distilled oil to extract", "error")
        return
    end

    -- Always the type actually loaded/distilled (refineryProgress[source].oilType),
    -- never a client-supplied one - otherwise a player could load cheap crude but
    -- claim a different, more valuable type's quality odds and result item here.
    local oilConfig = Config.RefineryTypes[refineryProgress[source].oilType]
    if not oilConfig then
        Fiji.Notify(source, "Invalid oil type configuration", "error")
        return
    end

    if not PassesRateLimit(source, oilConfig.extractionTime) then
        return
    end

    local perk = GetMeridianPerk(source)
    local roll = math.random()
    local quality = "standard"

    if oilConfig.qualityChances then
        local pureChance = oilConfig.qualityChances.pure + (perk.pureBonus or 0)
        if roll <= pureChance then
            quality = "pure"
        elseif roll <= (pureChance + oilConfig.qualityChances.standard) then
            quality = "standard"
        else
            quality = "dirty"
        end
    end

    local resultItem = oilConfig.result .. "_" .. quality

    if Fiji.AddItem(source, resultItem, 1) then
        refineryProgress[source].extractedCount = refineryProgress[source].extractedCount + 1

        if oilConfig.byproducts then
            for byproduct, chance in pairs(oilConfig.byproducts) do
                if math.random() <= chance then
                    Fiji.AddItem(source, byproduct, 1)
                end
            end
        end

        if refineryProgress[source].extractedCount >= refineryProgress[source].distilledCount then
            refineryProgress[source] = nil
        end
    else
        Fiji.Notify(source, "Failed to add refined oil to inventory", "error")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    refineryProgress[source] = nil
    nextActionAt[source] = nil
end)
