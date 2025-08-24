local Bridge = require 'bridge'
local lastCollection = {}

RegisterNetEvent('fiji-oil:server:collectOil', function(oilType)
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
    
    local playerIdentifier = GetPlayerIdentifier(source, 0)
    local currentTime = os.time()
    
    if lastCollection[playerIdentifier] and (currentTime - lastCollection[playerIdentifier]) < 2 then
        Bridge.Notify(source, "You're collecting too fast", "error")
        return
    end
    
    lastCollection[playerIdentifier] = currentTime
    
    local hasContainer, containerCount = Bridge.HasItem(source, "empty_oil")
    if not hasContainer or containerCount < 1 then
        Bridge.Notify(source, "You need an empty oil container", "error")
        return
    end
    
    if Bridge.RemoveItem(source, "empty_oil", 1) then
        local success = Bridge.AddItem(source, oilType, 1)
        
        if success then
            Bridge.Notify(source, "You collected " .. Bridge.GetItemLabel(oilType), "success")
        else
            Bridge.AddItem(source, "empty_oil", 1)
            Bridge.Notify(source, "Your inventory is full", "error")
        end
    else
        Bridge.Notify(source, "Failed to remove empty container", "error")
    end
end)
