local isDelivering = false
local currentDelivery = nil
local deliveryVehicle = nil
local deliveryBlip = nil
local deliveryCheckpoint = nil
local deliveryDestination = nil
local deliveryStartTime = 0
local deliveryTimeRemaining = 0
local deliveryTimer = nil
local Fiji = require 'bridge'

RegisterNetEvent('fiji-oil:client:openDeliveryMenu')
AddEventHandler('fiji-oil:client:openDeliveryMenu', function()
    OpenDeliveryMenu()
end)

RegisterNetEvent('fiji-oil:client:startDelivery')
AddEventHandler('fiji-oil:client:startDelivery', function(deliveryData)
    StartDelivery(deliveryData)
end)

RegisterNetEvent('fiji-oil:client:cancelDelivery')
AddEventHandler('fiji-oil:client:cancelDelivery', function()
    CancelDelivery()
end)

function OpenDeliveryMenu()
    if isDelivering then
        lib.notify({
            title = Config.OilCompany,
            description = 'You are already on a delivery',
            type = 'error'
        })
        return
    end
    
    lib.callback('fiji-oil:server:getPackagedOil', false, function(oilData)
        if not oilData or #oilData == 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "You don't have any packaged oil",
                type = 'error'
            })
            return
        end
        
        local options = {}
        
        for _, oil in ipairs(oilData) do
            table.insert(options, {
                title = "Deliver " .. oil.label,
                description = "You have " .. oil.count .. "x " .. oil.label,
                onSelect = function()
                    SelectDeliveryQuantity(oil.name, oil.label, oil.count)
                end
            })
        end
        
        lib.registerContext({
            id = 'delivery_menu',
            title = 'Select Oil to Deliver',
            options = options
        })
        
        lib.showContext('delivery_menu')
    end)
end

function SelectDeliveryQuantity(oilType, oilLabel, maxCount)
    local input = lib.inputDialog('Deliver ' .. oilLabel, {
        {
            type = 'number',
            label = 'Quantity',
            description = 'How many units to deliver (max ' .. maxCount .. ')',
            default = 1,
            min = 1,
            max = maxCount,
            required = true
        }
    })
    
    if not input or not input[1] then return end
    
    local quantity = math.floor(input[1])
    if quantity < 1 or quantity > maxCount then
        lib.notify({
            title = Config.OilCompany,
            description = "Invalid quantity",
            type = 'error'
        })
        return
    end
    
    TriggerServerEvent('fiji-oil:server:requestDelivery', oilType, quantity)
end

function StartDelivery(deliveryData)
    if not deliveryData then return end
    
    isDelivering = true
    currentDelivery = deliveryData
    
    SpawnDeliveryVehicle(function(success)
        if not success then
            lib.notify({
                title = Config.OilCompany,
                description = "Failed to spawn delivery vehicle",
                type = 'error'
            })
            isDelivering = false
            currentDelivery = nil
            return
        end
        
        CreateDeliveryDestination()
        
        StartDeliveryTimer()
        
        lib.notify({
            title = Config.OilCompany,
            description = "Delivery started. Drive to " .. deliveryData.locationName .. ".",
            type = 'inform'
        })
    end)
end

function SpawnDeliveryVehicle(callback)
    local spawnPoint = Config.DeliveryVehicle.spawnLocation
    if not spawnPoint then
        if callback then callback(false) end
        return
    end
    
    local safeSpawnPoint = FindSafeSpawnPoint(spawnPoint)
    if not safeSpawnPoint then
        lib.notify({
            title = Config.OilCompany,
            description = "No safe vehicle spawn location found",
            type = 'error'
        })
        if callback then callback(false) end
        return
    end
    
    local vehicleModel = Config.DeliveryVehicle.model or 'mule'
    
    RequestModel(vehicleModel)
    local timeout = 0
    while not HasModelLoaded(vehicleModel) and timeout < 30 do
        timeout = timeout + 1
        Wait(100)
    end
    
    if not HasModelLoaded(vehicleModel) then
        lib.notify({
            title = Config.OilCompany,
            description = "Failed to load vehicle model",
            type = 'error'
        })
        if callback then callback(false) end
        return
    end
    
    deliveryVehicle = CreateVehicle(
        vehicleModel,
        safeSpawnPoint.x, safeSpawnPoint.y, safeSpawnPoint.z,
        safeSpawnPoint.w or spawnPoint.w or 0.0,
        true, false
    )
    
    if not deliveryVehicle or not DoesEntityExist(deliveryVehicle) then
        lib.notify({
            title = Config.OilCompany,
            description = "Failed to create delivery vehicle",
            type = 'error'
        })
        if callback then callback(false) end
        return
    end
    
    SetEntityAsMissionEntity(deliveryVehicle, true, true)
    SetVehicleOnGroundProperly(deliveryVehicle)
    SetVehicleNumberPlateText(deliveryVehicle, "OIL-" .. math.random(100, 999))
    SetVehicleColours(deliveryVehicle, 0, 0)
    
    GiveVehicleKeys(deliveryVehicle)
    
    local blip = AddBlipForEntity(deliveryVehicle)
    SetBlipSprite(blip, 477)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Vehicle")
    EndTextCommandSetBlipName(blip)
    
    if callback then callback(true) end
end

function FindSafeSpawnPoint(basePoint)
    local offsets = {
        {x = 0.0, y = 0.0, z = 0.0},
        {x = 5.0, y = 0.0, z = 0.0},
        {x = -5.0, y = 0.0, z = 0.0},
        {x = 0.0, y = 5.0, z = 0.0},
        {x = 0.0, y = -5.0, z = 0.0},
        {x = 5.0, y = 5.0, z = 0.0},
        {x = -5.0, y = 5.0, z = 0.0},
        {x = 5.0, y = -5.0, z = 0.0},
        {x = -5.0, y = -5.0, z = 0.0},
        {x = 10.0, y = 0.0, z = 0.0},
        {x = -10.0, y = 0.0, z = 0.0},
        {x = 0.0, y = 10.0, z = 0.0},
        {x = 0.0, y = -10.0, z = 0.0},
    }
    
    for _, offset in ipairs(offsets) do
        local testPoint = {
            x = basePoint.x + offset.x,
            y = basePoint.y + offset.y,
            z = basePoint.z + offset.z,
            w = basePoint.w
        }
        
        if IsAreaClear(testPoint.x, testPoint.y, testPoint.z, 4.0) then
            return testPoint
        end
    end
    
    local radius = 20.0
    local attempts = 8
    local angleStep = 360.0 / attempts
    
    for i = 1, attempts do
        local angle = math.rad(angleStep * i)
        local testPoint = {
            x = basePoint.x + radius * math.cos(angle),
            y = basePoint.y + radius * math.sin(angle),
            z = basePoint.z,
            w = basePoint.w
        }
        
        if IsAreaClear(testPoint.x, testPoint.y, testPoint.z, 4.0) then
            return testPoint
        end
    end
    
    return nil
end

function GiveVehicleKeys(vehicle)
    if exports['qb-vehiclekeys'] then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', NetworkGetNetworkIdFromEntity(vehicle))
    elseif exports['ox_lib'] and exports['ox_lib'].hasExport('addVehicleKey') then
        exports['ox_lib']:addVehicleKey(vehicle)
    elseif exports['esx_vehiclelock'] then
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
    elseif exports['wasabi_carlock'] then
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('wasabi_carlock:addKeys', plate)
    else
        SetVehicleDoorsLocked(vehicle, 1)
        lib.notify({
            title = Config.OilCompany,
            description = "Vehicle unlocked. No key system detected.",
            type = 'inform'
        })
    end
end

function CreateDeliveryDestination()
    if not currentDelivery or not currentDelivery.destination then return end
    
    local dest = currentDelivery.destination
    
    deliveryBlip = AddBlipForCoord(dest.x, dest.y, dest.z)
    SetBlipSprite(deliveryBlip, Config.DeliveryDestinationBlip.icon)
    SetBlipColour(deliveryBlip, Config.DeliveryDestinationBlip.color)
    SetBlipScale(deliveryBlip, Config.DeliveryDestinationBlip.scale)
    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Destination: " .. currentDelivery.locationName)
    EndTextCommandSetBlipName(deliveryBlip)
    
    deliveryCheckpoint = CreateCheckpoint(
        45,
        dest.x, dest.y, dest.z - 1.0,
        0.0, 0.0, 0.0,
        5.0,
        0, 200, 0, 200,
        0
    )
    
    SetCheckpointCylinderHeight(deliveryCheckpoint, 5.0, 5.0, 5.0)
    
    deliveryDestination = lib.zones.sphere({
        coords = vec3(dest.x, dest.y, dest.z),
        radius = 5.0,
        debug = Config.Debug or false,
        onEnter = function()
            if isDelivering and currentDelivery then
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)
                
                if vehicle == deliveryVehicle then
                    CompleteDeliveryProcess()
                else
                    lib.notify({
                        title = Config.OilCompany,
                        description = "You need to be in the delivery vehicle",
                        type = 'error'
                    })
                end
            end
        end
    })
end

function CompleteDeliveryProcess()
    if not isDelivering or not currentDelivery then return end
    
    if lib.progressBar({
        duration = Config.DeliveryCompletionTime,
        label = 'Unloading Oil Shipment',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        local timeRatio = deliveryTimeRemaining / (Config.DeliveryBaseTime * (currentDelivery.distanceFactor or 1.0))
        
        TriggerServerEvent('fiji-oil:server:completeDelivery', currentDelivery.id, timeRatio)
        
        CleanupDelivery()
        
        lib.notify({
            title = Config.OilCompany,
            description = "Delivery completed successfully!",
            type = 'success'
        })
    else
        lib.notify({
            title = Config.OilCompany,
            description = "Delivery unloading cancelled",
            type = 'error'
        })
    end
end

function StartDeliveryTimer()
    if not currentDelivery then return end
    
    local baseTime = Config.DeliveryBaseTime
    local distanceFactor = currentDelivery.distanceFactor or 1.0
    deliveryTimeRemaining = math.floor(baseTime * distanceFactor)
    deliveryStartTime = GetGameTimer()
    
    SendNUIMessage({
        action = "showDeliveryTimer",
        time = deliveryTimeRemaining
    })
    
    deliveryTimer = CreateThread(function()
        while isDelivering and deliveryTimeRemaining > 0 do
            local elapsed = (GetGameTimer() - deliveryStartTime) / 1000
            deliveryTimeRemaining = math.max(0, math.floor(baseTime * distanceFactor - elapsed))
            
            SendNUIMessage({
                action = "updateDeliveryTimer",
                time = deliveryTimeRemaining
            })
            
            if deliveryTimeRemaining <= 0 then
                lib.notify({
                    title = Config.OilCompany,
                    description = "Delivery time expired. No time bonus will be applied.",
                    type = 'inform'
                })
                break
            end
            
            Wait(1000)
        end
    end)
end

function CancelDelivery()
    if not isDelivering then return end
    
    if currentDelivery then
        TriggerServerEvent('fiji-oil:server:cancelDelivery', currentDelivery.id)
    end
    
    CleanupDelivery()
    
    lib.notify({
        title = Config.OilCompany,
        description = "Delivery cancelled",
        type = 'inform'
    })
end

function CleanupDelivery()
    isDelivering = false
    currentDelivery = nil
    deliveryTimeRemaining = 0
    
    SendNUIMessage({
        action = "hideDeliveryTimer"
    })
    
    if deliveryTimer then
        TerminateThread(deliveryTimer)
        deliveryTimer = nil
    end
    
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    if deliveryCheckpoint then
        DeleteCheckpoint(deliveryCheckpoint)
        deliveryCheckpoint = nil
    end
    
    if deliveryDestination then
        deliveryDestination:remove()
        deliveryDestination = nil
    end
    
    if deliveryVehicle and DoesEntityExist(deliveryVehicle) then
        DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end
end

function IsAreaClear(x, y, z, radius)
    if IsAnyVehicleNearPoint(x, y, z, radius) then
        return false
    end
    
    local objects = GetGamePool('CObject')
    local peds = GetGamePool('CPed')
    
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            local objCoords = GetEntityCoords(object)
            local distance = #(vector3(x, y, z) - objCoords)
            
            if distance < radius and not IsEntityAttached(object) then
                local model = GetEntityModel(object)
                local objectSize = GetModelDimensions(model)
                
                if objectSize and (objectSize.y > 1.0 or objectSize.x > 1.0) then
                    return false
                end
            end
        end
    end
    
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(vector3(x, y, z) - pedCoords)
            
            if distance < radius then
                return false
            end
        end
    end
    
    return true
end

CreateThread(function()
    RegisterCommand('canceldelivery', function()
        if isDelivering then
            CancelDelivery()
        else
            lib.notify({
                title = Config.OilCompany,
                description = "You are not on a delivery",
                type = 'error'
            })
        end
    end, false)
end)
