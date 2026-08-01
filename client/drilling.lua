local isDrilling = false

CreateThread(function()
    Wait(1500)

    for i, rig in ipairs(Config.OffshoreRigs) do
        Fiji.AddInteraction(
            'fiji_rig_' .. i,
            { type = 'sphere', coords = rig.coords, radius = 8.0 },
            {
                {
                    name = 'drill_rig_' .. i,
                    icon = 'fa-solid fa-oil-well',
                    label = 'Drill for Crude Oil',
                    onSelect = function() StartDrilling(i) end,
                },
            },
            Config.Debug or false
        )
    end
end)

function StartDrilling(rigIndex)
    if isDrilling then return end
    isDrilling = true

    local supplies = Callback.TriggerSync('fiji-oil:drilling:getSupplies', nil) or {}

    if not supplies.drillParts then
        UI.Notify({ description = "You need a drill part to operate the rig.", type = 'error' })
        isDrilling = false
        return
    end

    if not supplies.buckets or supplies.buckets <= 0 then
        UI.Notify({ description = "You don't have any oil buckets.", type = 'error' })
        isDrilling = false
        return
    end

    local drillTime = math.floor(Config.DrillBaseTime * (supplies.drillTimeMultiplier or 1.0))
    local totalUnits = supplies.buckets
    local collected = 0
    local cancelled = false

    for i = 1, totalUnits do
        if not UI.ProgressBar({
            duration = drillTime,
            label = ('Drilling (%d/%d)'):format(i, totalUnits),
            canCancel = true,
            disable = { move = true, car = true, combat = true },
        }) then
            cancelled = true
            break
        end

        local result = Callback.TriggerSync('fiji-oil:drilling:collect', { rigIndex = rigIndex })
        if result and result.success then
            collected = collected + 1
        else
            break
        end
    end

    isDrilling = false

    if collected > 0 then
        UI.Notify({ description = ('Collected %d units of crude oil.'):format(collected), type = 'success' })
    elseif cancelled then
        UI.Notify({ description = 'Drilling cancelled.', type = 'inform' })
    end
end
