local Bridge = require 'bridge'
local activeDeliveries = {}
local deliveryCounter = 0

lib.callback.register('fiji-oil:server:getPackagedOil', function(source)
    local oilData = {}
    local packagedOilTypes = {
        {name = 'packaged_light_pure', label = Config.ItemLabels['packaged_light_pure'] or 'Packaged Pure Light Oil'},
        {name = 'packaged_light_standard', label = Config.ItemLabels['packaged_light_standard'] or 'Packaged Standard Light Oil'},
        {name = 'packaged_light_dirty', label = Config.ItemLabels['packaged_light_dirty'] or 'Packaged Dirty Light Oil'},
        
        {name = 'packaged_heavy_pure', label = Config.ItemLabels['packaged_heavy_pure'] or 'Packaged Pure Heavy Oil'},
        {name = 'packaged_heavy_standard', label = Config.ItemLabels['packaged_heavy_standard'] or 'Packaged Standard Heavy Oil'},
        {name = 'packaged_heavy_dirty', label = Config.ItemLabels['packaged_heavy_dirty'] or 'Packaged Dirty Heavy Oil'}
    }
    
    for _, oil in ipairs(packagedOilTypes) do
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

RegisterNetEvent('fiji-oil:server:requestDelivery', function(oilType, quantity)
    local source = source
    
    local hasOil, oilCount = Bridge.HasItem(source, oilType)
    if not hasOil or oilCount < quantity then
        Bridge.Notify(source, "You don't have enough " .. (Config.ItemLabels[oilType] or oilType), "error")
        return
    end
    
    for _, delivery in pairs(activeDeliveries) do
        if delivery.player == source then
            Bridge.Notify(source, "You are already on a delivery", "error")
            return
        end
    end
    
    local validLocations = {}
    for i, location in ipairs(Config.DeliveryLocations) do
        if location.rewards[oilType] then
            table.insert(validLocations, {index = i, location = location})
        end
    end
    
    if #validLocations == 0 then
        Bridge.Notify(source, "No delivery locations available for this oil type", "error")
        return
    end
    
    local selectedLocation = validLocations[math.random(#validLocations)]
    local locationIndex = selectedLocation.index
    local location = selectedLocation.location
    
    local basePayment = location.rewards[oilType] * quantity
    
    deliveryCounter = deliveryCounter + 1
    local deliveryId = deliveryCounter
    
    activeDeliveries[deliveryId] = {
        id = deliveryId,
        player = source,
        oilType = oilType,
        quantity = quantity,
        locationIndex = locationIndex,
        locationName = location.label,
        destination = location.coords,
        distanceFactor = location.distance or 1.0,
        basePayment = basePayment,
        startTime = os.time()
    }
    
    if Bridge.RemoveItem(source, oilType, quantity) then
        TriggerClientEvent('fiji-oil:client:startDelivery', source, {
            id = deliveryId,
            destination = location.coords,
            locationName = location.label,
            quantity = quantity,
            oilType = oilType,
            distanceFactor = location.distance or 1.0
        })
    else
        Bridge.Notify(source, "Failed to remove oil from inventory", "error")
        activeDeliveries[deliveryId] = nil
    end
end)

RegisterNetEvent('fiji-oil:server:completeDelivery', function(deliveryId, timeRatio)
    local source = source
    
    local delivery = activeDeliveries[deliveryId]
    if not delivery then
        Bridge.Notify(source, "Invalid delivery", "error")
        return
    end
    
    if delivery.player ~= source then
        Bridge.Notify(source, "This is not your delivery", "error")
        return
    end
    
    local basePayment = tonumber(delivery.basePayment) or 0
    if basePayment <= 0 then
        basePayment = 1000
    end
    
    local timeBonus = 1.0
    if timeRatio and type(timeRatio) == "number" and timeRatio > 0 then
        timeBonus = 1.0 + (Config.TimeBonus * timeRatio)
    end
    
    local finalPayment = math.floor(basePayment * timeBonus)
    
    if not finalPayment or type(finalPayment) ~= "number" or finalPayment <= 0 then
        finalPayment = 1000
    end
    
    local success = pcall(function()
        Bridge.AddMoney(source, 'bank', finalPayment, 'Oil Delivery Payment')
    end)
    
    if not success then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('bank', finalPayment, 'Oil Delivery Payment')
        end
    end
    
    local bonusText = ""
    if timeRatio > 0 then
        local bonusPercent = math.floor((timeBonus - 1) * 100)
        bonusText = " (includes " .. bonusPercent .. "% time bonus)"
    end
    
    Bridge.Notify(source, "Delivery completed! You earned $" .. finalPayment .. bonusText, "success")
    
    activeDeliveries[deliveryId] = nil
end)

RegisterNetEvent('fiji-oil:server:cancelDelivery', function(deliveryId)
    local source = source
    
    local delivery = activeDeliveries[deliveryId]
    if not delivery then return end
    
    if delivery.player ~= source then return end
    
    Bridge.AddItem(source, delivery.oilType, delivery.quantity)
    
    Bridge.Notify(source, "Delivery cancelled. Your oil has been returned.", "inform")
    
    activeDeliveries[deliveryId] = nil
end)

AddEventHandler('playerDropped', function()
    local source = source
    
    for id, delivery in pairs(activeDeliveries) do
        if delivery.player == source then
            activeDeliveries[id] = nil
        end
    end
end)


-- Register event for cancelling delivery
RegisterNetEvent('fiji-oil:server:cancelDelivery', function(deliveryId)
    local source = source
    
    -- Check if delivery exists
    local delivery = activeDeliveries[deliveryId]
    if not delivery then return end
    
    -- Check if player is the delivery owner
    if delivery.player ~= source then return end
    
    -- Return oil to player
    Bridge.AddItem(source, delivery.oilType, delivery.quantity)
    
    -- Notify player
    Bridge.Notify(source, "Delivery cancelled. Your oil has been returned.", "inform")
    
    -- Remove delivery
    activeDeliveries[deliveryId] = nil
end)

-- Clean up when player disconnects
AddEventHandler('playerDropped', function()
    local source = source
    
    -- Find and cancel any active deliveries for this player
    for id, delivery in pairs(activeDeliveries) do
        if delivery.player == source then
            -- Return oil to player's stash or just remove the delivery
            activeDeliveries[id] = nil
        end
    end
end)
