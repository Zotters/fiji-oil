local Fiji = require 'bridge'
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
        Fiji.Notify(source, "Invalid oil type", "error")
        return
    end
    
    local playerIdentifier = GetPlayerIdentifier(source, 0)
    local currentTime = os.time()
    
    if lastCollection[playerIdentifier] and (currentTime - lastCollection[playerIdentifier]) < 2 then
        Fiji.Notify(source, "You're collecting too fast", "error")
        return
    end
    
    lastCollection[playerIdentifier] = currentTime
    
    local hasContainer, containerCount = Fiji.HasItem(source, "empty_oil")
    if not hasContainer or containerCount < 1 then
        Fiji.Notify(source, "You need an empty oil container", "error")
        return
    end
    
    if Fiji.RemoveItem(source, "empty_oil", 1) then
        local success = Fiji.AddItem(source, oilType, 1)
        
        if success then
            Fiji.Notify(source, "You collected " .. Fiji.GetItemLabel(oilType), "success")
        else
            Fiji.AddItem(source, "empty_oil", 1)
            Fiji.Notify(source, "Your inventory is full", "error")
        end
    else
        Fiji.Notify(source, "Failed to remove empty container", "error")
    end
end)
