local Fiji = require 'bridge'

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
        local hasOil, oilCount = Fiji.HasItem(source, oil.name)
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
    local hasItem, itemCount = Fiji.HasItem(source, 'empty_drum')
    return itemCount or 0
end)

RegisterNetEvent('fiji-oil:server:packageOil', function(oilType)
    local source = source
    
    local hasOil, oilCount = Fiji.HasItem(source, oilType)
    if not hasOil or oilCount < 1 then
        Fiji.Notify(source, "You don't have any " .. Fiji.GetItemLabel(oilType), "error")
        return
    end
    
    local hasDrums, drumCount = Fiji.HasItem(source, 'empty_drum')
    if not hasDrums or drumCount < 1 then
        Fiji.Notify(source, "You don't have any empty drums", "error")
        return
    end
    
    local packagedItem = oilType:gsub("refined_", "packaged_")
    
    if Fiji.RemoveItem(source, oilType, 1) and Fiji.RemoveItem(source, 'empty_drum', 1) then
        if Fiji.AddItem(source, packagedItem, 1) then
            Fiji.Notify(source, "Successfully packaged " .. Fiji.GetItemLabel(oilType), "success")
        else
            Fiji.AddItem(source, oilType, 1)
            Fiji.AddItem(source, 'empty_drum', 1)
            Fiji.Notify(source, "Failed to package oil", "error")
        end
    else
        Fiji.Notify(source, "Failed to remove items from inventory", "error")
    end
end)
