local Bridge = require 'bridge'

lib.callback.register('fiji-oil:server:getRefinedOil', function(source)
    local oilData = {}
    local refinedOilTypes = {
        {name = 'refined_light_pure', label = 'Pure Light Oil'},
        {name = 'refined_light_standard', label = 'Standard Light Oil'},
        {name = 'refined_light_dirty', label = 'Dirty Light Oil'},
        
        {name = 'refined_heavy_pure', label = 'Pure Heavy Oil'},
        {name = 'refined_heavy_standard', label = 'Standard Heavy Oil'},
        {name = 'refined_heavy_dirty', label = 'Dirty Heavy Oil'}
    }
    
    for _, oil in ipairs(refinedOilTypes) do
        local hasOil, oilCount = Bridge.HasItem(source, oil.name)
        if hasOil and oilCount > 0 then
            table.insert(oilData, {
                name = oil.name,
                label = oil.label,
                count = oilCount
            })
        end
    end
    
    return oilData
end)

lib.callback.register('fiji-oil:server:getEmptyDrums', function(source)
    local hasItem, itemCount = Bridge.HasItem(source, 'empty_drum')
    return itemCount or 0
end)

RegisterNetEvent('fiji-oil:server:packageOil', function(oilType)
    local source = source
    
    local hasOil, oilCount = Bridge.HasItem(source, oilType)
    if not hasOil or oilCount < 1 then
        Bridge.Notify(source, "You don't have any " .. Bridge.GetItemLabel(oilType), "error")
        return
    end
    
    local hasDrums, drumCount = Bridge.HasItem(source, 'empty_drum')
    if not hasDrums or drumCount < 1 then
        Bridge.Notify(source, "You don't have any empty drums", "error")
        return
    end
    
    local packagedItem = oilType:gsub("refined_", "packaged_")
    
    if Bridge.RemoveItem(source, oilType, 1) and Bridge.RemoveItem(source, 'empty_drum', 1) then
        if Bridge.AddItem(source, packagedItem, 1) then
            Bridge.Notify(source, "Successfully packaged " .. Bridge.GetItemLabel(oilType), "success")
        else
            Bridge.AddItem(source, oilType, 1)
            Bridge.AddItem(source, 'empty_drum', 1)
            Bridge.Notify(source, "Failed to package oil", "error")
        end
    else
        Bridge.Notify(source, "Failed to remove items from inventory", "error")
    end
end)
