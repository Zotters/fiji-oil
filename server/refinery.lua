local Bridge = require 'bridge'
local refineryProgress = {}

lib.callback.register('fiji-oil:server:getAvailableOil', function(source)
    local oilData = {}
    
    local hasLightOil, lightCount = Bridge.HasItem(source, 'crude_light')
    if hasLightOil and lightCount > 0 then
        table.insert(oilData, {
            name = 'crude_light',
            label = Bridge.GetItemLabel('crude_light'),
            count = lightCount
        })
    end
    
    local hasHeavyOil, heavyCount = Bridge.HasItem(source, 'crude_heavy')
    if hasHeavyOil and heavyCount > 0 then
        table.insert(oilData, {
            name = 'crude_heavy',
            label = Bridge.GetItemLabel('crude_heavy'),
            count = heavyCount
        })
    end
    
    return oilData
end)

lib.callback.register('fiji-oil:server:getRefineryState', function(source)
    return refineryProgress[source] or {
        phase = 0,
        oilType = nil,
        hopperCount = 0,
        distilledCount = 0,
        extractedCount = 0
    }
end)

RegisterNetEvent('fiji-oil:server:loadHopper', function(oilType)
    local source = source
    
    local validOilType = false
    for _, oil in ipairs(Config.OilTypes) do
        if oil.name == oilType then
            validOilType = true
            break
        end
    end
    
    if not validOilType then
        Bridge.Notify(source, "Invalid oil type", "error")
        return
    end
    
    local hasOil, oilCount = Bridge.HasItem(source, oilType)
    if not hasOil or oilCount < 1 then
        Bridge.Notify(source, "You don't have any " .. Bridge.GetItemLabel(oilType), "error")
        return
    end
    
    if not refineryProgress[source] then
        refineryProgress[source] = {
            oilType = oilType,
            hopperCount = 0,
            distilledCount = 0,
            extractedCount = 0,
            phase = 1
        }
    end
    
    if refineryProgress[source].oilType ~= oilType then
        Bridge.Notify(source, "Cannot mix different oil types", "error")
        return
    end
    
    if refineryProgress[source].hopperCount >= Config.HopperFill then
        Bridge.Notify(source, "Hopper is already full", "error")
        return
    end
    
    if Bridge.RemoveItem(source, oilType, 1) then
        refineryProgress[source].hopperCount = refineryProgress[source].hopperCount + 1
        
        TriggerClientEvent('fiji-oil:client:updateRefineryState', source, refineryProgress[source])
    else
        Bridge.Notify(source, "Failed to remove oil from inventory", "error")
    end
end)

RegisterNetEvent('fiji-oil:server:distillOne', function()
    local source = source
    
    if not refineryProgress[source] then
        Bridge.Notify(source, "No active refining process", "error")
        return
    end
    
    refineryProgress[source].hopperCount = math.max((refineryProgress[source].hopperCount or 0) - 1, 0)
    refineryProgress[source].distilledCount = (refineryProgress[source].distilledCount or 0) + 1
    refineryProgress[source].phase = 2
    
    TriggerClientEvent('fiji-oil:client:updateRefineryState', source, refineryProgress[source])
end)

RegisterNetEvent('fiji-oil:server:distillComplete', function()
    local source = source
    
    if not refineryProgress[source] then
        Bridge.Notify(source, "No active refining process", "error")
        return
    end
    
    if refineryProgress[source].hopperCount <= 0 then
        refineryProgress[source].phase = 3
        Bridge.Notify(source, "All oil processed. Ready for extraction.", "success")
    else
        refineryProgress[source].phase = 1
        Bridge.Notify(source, "Distillation complete. You can continue loading or distilling.", "inform")
    end
    
    TriggerClientEvent('fiji-oil:client:updateRefineryState', source, refineryProgress[source])
end)

RegisterNetEvent('fiji-oil:server:extractOil', function(oilType)
    local source = source
    
    if not refineryProgress[source] then
        Bridge.Notify(source, "No active refining process", "error")
        return
    end
    
    local toExtract = refineryProgress[source].distilledCount - refineryProgress[source].extractedCount
    if toExtract <= 0 then
        Bridge.Notify(source, "No distilled oil to extract", "error")
        return
    end
    
    local oilConfig = Config.RefineryTypes[oilType]
    if not oilConfig then
        Bridge.Notify(source, "Invalid oil type configuration", "error")
        return
    end
    
    local roll = math.random()
    local quality = "standard"
    
    if oilConfig.qualityChances then
        if roll <= oilConfig.qualityChances.pure then
            quality = "pure"
        elseif roll <= (oilConfig.qualityChances.pure + oilConfig.qualityChances.standard) then
            quality = "standard"
        else
            quality = "dirty"
        end
    end
    
    local resultItem = oilConfig.result .. "_" .. quality
    
    if Bridge.AddItem(source, resultItem, 1) then
        refineryProgress[source].extractedCount = refineryProgress[source].extractedCount + 1
        
        if oilConfig.byproducts then
            for byproduct, chance in pairs(oilConfig.byproducts) do
                if math.random() <= chance then
                    Bridge.AddItem(source, byproduct, 1)
                end
            end
        end
        
        if refineryProgress[source].extractedCount >= refineryProgress[source].distilledCount then
            refineryProgress[source] = nil
        end
        
        TriggerClientEvent('fiji-oil:client:updateRefineryState', source, refineryProgress[source] or {
            phase = 0,
            oilType = nil,
            hopperCount = 0,
            distilledCount = 0,
            extractedCount = 0
        })
    else
        Bridge.Notify(source, "Failed to add refined oil to inventory", "error")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    refineryProgress[source] = nil
end)

