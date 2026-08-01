-- Offshore drilling: server-validated, portable across every inventory system.
-- drill_part durability is tracked in memory per session rather than via
-- item metadata, since metadata mutation conventions differ significantly
-- across ox/qb/qs/esx inventories and this keeps the mechanic identical
-- regardless of which one a server runs.

local drillCharges = {}
local nextDrillAt = {}

-- Blocks a client from spamming this callback far faster than the drill's
-- progress bar - floor is set below the fastest legitimate (max-perk) time
-- so real players never trip it, only a client skipping the wait entirely.
local function PassesRateLimit(source)
    local now = GetGameTimer()
    if (nextDrillAt[source] or 0) > now then
        return false
    end
    nextDrillAt[source] = now + math.floor(Config.DrillBaseTime * 0.6)
    return true
end

local function RollCrude()
    local totalWeight = 0
    for _, entry in ipairs(Config.DrillYield) do
        totalWeight = totalWeight + entry.weight
    end

    local roll = math.random() * totalWeight
    local cumulative = 0

    for _, entry in ipairs(Config.DrillYield) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.name
        end
    end

    return Config.DrillYield[1].name
end

Callback.Register('fiji-oil:drilling:getSupplies', function(source)
    local hasDrillPart = Fiji.HasItem(source, 'drill_part')
    local _, buckets = Fiji.HasItem(source, 'oil_bucket')

    local drillTimeMultiplier = 1.0
    local identifier = Fiji.GetIdentifier(source)
    if identifier then
        local tier = GetCompanyPerkTier('kraken', GetCompanyReputation(identifier, 'kraken'))
        if tier then drillTimeMultiplier = tier.drillTimeMultiplier or 1.0 end
    end

    return {
        drillParts = hasDrillPart,
        buckets = buckets or 0,
        drillTimeMultiplier = drillTimeMultiplier,
    }
end)

Callback.Register('fiji-oil:drilling:collect', function(source, payload)
    local rigIndex = payload and payload.rigIndex
    local rig = rigIndex and Config.OffshoreRigs[rigIndex]
    if not rig then return { success = false } end

    -- ox_target/proximity zones are UX filters only - re-validate distance server-side.
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    if #(coords - rig.coords) > 25.0 then
        return { success = false }
    end

    if not PassesRateLimit(source) then
        return { success = false }
    end

    if not Fiji.HasItem(source, 'drill_part') then
        Fiji.Notify(source, "You need a drill part to operate the rig.", "error")
        return { success = false }
    end

    local hasBucket, bucketCount = Fiji.HasItem(source, 'oil_bucket')
    if not hasBucket or bucketCount < 1 then
        Fiji.Notify(source, "You don't have any oil buckets.", "error")
        return { success = false }
    end

    if not Fiji.RemoveItem(source, 'oil_bucket', 1) then
        return { success = false }
    end

    drillCharges[source] = (drillCharges[source] or Config.DrillPartMaxUses) - 1

    if drillCharges[source] <= 0 then
        Fiji.RemoveItem(source, 'drill_part', 1)
        drillCharges[source] = nil
        Fiji.Notify(source, "Your drill part broke. Order a replacement.", "warning")
    end

    local bonusChance = 0
    local identifier = Fiji.GetIdentifier(source)
    if identifier then
        local tier = GetCompanyPerkTier('kraken', GetCompanyReputation(identifier, 'kraken'))
        if tier then bonusChance = tier.bonusCrudeChance or 0 end
    end

    local crudeType = RollCrude()
    local units = (math.random() <= bonusChance) and 2 or 1

    if not Fiji.AddItem(source, crudeType, units) then
        Fiji.Notify(source, "Your inventory is full.", "error")
        return { success = false }
    end

    return { success = true, crudeType = crudeType, units = units }
end)

AddEventHandler('playerDropped', function()
    local source = source
    drillCharges[source] = nil
    nextDrillAt[source] = nil
end)
