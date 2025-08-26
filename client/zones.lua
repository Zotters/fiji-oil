local Fiji = require 'bridge'
local activeZones = {}
local activeTextUIs = {}


CreateThread(function()
    Wait(1500)
    
    SetupPumpZones()
    SetupRefineryZones()
    SetupPackagingZones()
    SetupDeliveryZones()
end)

function SetupPumpZones()
    if not Config or not Config.PumpValves then return end
    
    for id, coords in pairs(Config.PumpValves) do
        if Config.UseTarget then
            Fiji.AddTargetSphereZone(
                "oil_valve_" .. tostring(id),
                vec3(coords.x, coords.y, coords.z),
                0.5,
                {
                    {
                        name = "open_valve_" .. tostring(id),
                        icon = Config.ValveIcon or 'fa-solid fa-faucet',
                        label = "Open Valve",
                        onSelect = function()
                            exports['fiji-oil']:DirectOpenValve(id)
                        end
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["valve_" .. id] then
                                lib.showTextUI('[E] Open Valve', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-faucet',
                                })
                                activeTextUIs["valve_" .. id] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                exports['fiji-oil']:DirectOpenValve(id)
                            end
                        else
                            if activeTextUIs["valve_" .. id] then
                                lib.hideTextUI()
                                activeTextUIs["valve_" .. id] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end
end

function SetupRefineryZones()
    if Config and Config.Hopper then
        if Config.UseTarget then
            Fiji.AddTargetBoxZone(
                "refinery_hopper",
                Config.Hopper,
                vec3(3, 3, 3),
                0,
                {
                    {
                        name = "load_hopper",
                        icon = "fa-solid fa-arrow-down",
                        label = "Load Hopper",
                        event = "fiji-oil:client:openHopperMenu"
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(Config.Hopper.x, Config.Hopper.y, Config.Hopper.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["hopper"] then
                                lib.showTextUI('[E] Load Hopper', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-arrow-down',
                                })
                                activeTextUIs["hopper"] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerEvent("fiji-oil:client:openHopperMenu")
                            end
                        else
                            if activeTextUIs["hopper"] then
                                lib.hideTextUI()
                                activeTextUIs["hopper"] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end

    if Config and Config.Distill then
        if Config.UseTarget then
            Fiji.AddTargetBoxZone(
                "refinery_distill",
                Config.Distill,
                vec3(3, 3, 3),
                0,
                {
                    {
                        name = "start_distillation",
                        icon = "fa-solid fa-temperature-high",
                        label = "Begin Distillation",
                        event = "fiji-oil:client:startDistillation"
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(Config.Distill.x, Config.Distill.y, Config.Distill.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["distill"] then
                                lib.showTextUI('[E] Begin Distillation', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-temperature-high',
                                })
                                activeTextUIs["distill"] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerEvent("fiji-oil:client:startDistillation")
                            end
                        else
                            if activeTextUIs["distill"] then
                                lib.hideTextUI()
                                activeTextUIs["distill"] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end

    if Config and Config.Extraction then
        if Config.UseTarget then
            Fiji.AddTargetBoxZone(
                "refinery_extraction",
                Config.Extraction,
                vec3(3, 3, 3),
                0,
                {
                    {
                        name = "start_extraction",
                        icon = "fa-solid fa-flask",
                        label = "Extract Refined Oil",
                        event = "fiji-oil:client:startExtraction"
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(Config.Extraction.x, Config.Extraction.y, Config.Extraction.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["extraction"] then
                                lib.showTextUI('[E] Extract Refined Oil', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-flask',
                                })
                                activeTextUIs["extraction"] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerEvent("fiji-oil:client:startExtraction")
                            end
                        else
                            if activeTextUIs["extraction"] then
                                lib.hideTextUI()
                                activeTextUIs["extraction"] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end
end

function SetupPackagingZones()
    if not Config or not Config.PackagingLocations then return end
    
    for i, location in ipairs(Config.PackagingLocations) do
        if Config.UseTarget then
            Fiji.AddTargetBoxZone(
                "oil_packaging_" .. tostring(i),
                location.coords,
                vec3(3, 3, 3),
                0,
                {
                    {
                        name = "package_oil_" .. tostring(i),
                        icon = "fa-solid fa-box",
                        label = "Package Oil",
                        event = "fiji-oil:client:openPackagingMenu"
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                local locationId = i
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["packaging_" .. locationId] then
                                lib.showTextUI('[E] Package Oil', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-box',
                                })
                                activeTextUIs["packaging_" .. locationId] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerEvent("fiji-oil:client:openPackagingMenu")
                            end
                        else
                            if activeTextUIs["packaging_" .. locationId] then
                                lib.hideTextUI()
                                activeTextUIs["packaging_" .. locationId] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end
end

function SetupDeliveryZones()
    if not Config or not Config.DeliveryStartLocations then return end
    
    for i, location in ipairs(Config.DeliveryStartLocations) do
        if Config.UseTarget then
            Fiji.AddTargetBoxZone(
                "oil_delivery_start_" .. tostring(i),
                location.coords,
                vec3(3, 3, 3),
                0,
                {
                    {
                        name = "start_delivery_" .. tostring(i),
                        icon = "fa-solid fa-truck",
                        label = "Start Oil Delivery",
                        event = "fiji-oil:client:openDeliveryMenu"
                    }
                },
                Config.Debug or false
            )
        else
            CreateThread(function()
                local locationId = i
                while true do
                    local sleep = 1000
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))
                    
                    if distance < Config.InteractionDistance * 2 then
                        sleep = 0
                        
                        if distance < Config.InteractionDistance then
                            if not activeTextUIs["delivery_" .. locationId] then
                                lib.showTextUI('[E] Start Delivery', {
                                    position = "left-center",
                                    icon = 'fa-solid fa-truck',
                                })
                                activeTextUIs["delivery_" .. locationId] = true
                            end
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerEvent("fiji-oil:client:openDeliveryMenu")
                            end
                        else
                            if activeTextUIs["delivery_" .. locationId] then
                                lib.hideTextUI()
                                activeTextUIs["delivery_" .. locationId] = nil
                            end
                        end
                    end
                    
                    Wait(sleep)
                end
            end)
        end
    end
end

function CreateDeliveryDestinationZone(coords, deliveryId)
    if not coords or not deliveryId then
        return nil
    end
    
    local deliveryIdStr = tostring(deliveryId)
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    if not blip then
        return nil
    end
    
    SetBlipSprite(blip, Config.DeliveryDestinationBlip and Config.DeliveryDestinationBlip.icon or 38)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.DeliveryDestinationBlip and Config.DeliveryDestinationBlip.scale or 0.8)
    SetBlipColour(blip, Config.DeliveryDestinationBlip and Config.DeliveryDestinationBlip.color or 5)
    SetBlipAsShortRange(blip, false)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Destination")
    EndTextCommandSetBlipName(blip)
    
    activeZones['delivery_blip_' .. deliveryIdStr] = blip
    
    local checkpoint = CreateCheckpoint(
        45,
        coords.x, coords.y, coords.z,
        0, 0, 0,
        5.0,
        0, 200, 0, 200,
        0
    )
    
    if not checkpoint then
        RemoveBlip(blip)
        activeZones['delivery_blip_' .. deliveryIdStr] = nil
        return nil
    end
    
    SetCheckpointCylinderHeight(checkpoint, 5.0, 5.0, 5.0)
    
    activeZones['delivery_checkpoint_' .. deliveryIdStr] = checkpoint
    
    return {
        blip = blip,
        checkpoint = checkpoint,
        deliveryId = deliveryIdStr
    }
end

function RemoveDeliveryDestinationZone(deliveryId)
    if not deliveryId then
        return
    end
    
    local deliveryIdStr = tostring(deliveryId)
    
    if activeZones['delivery_blip_' .. deliveryIdStr] then
        RemoveBlip(activeZones['delivery_blip_' .. deliveryIdStr])
        activeZones['delivery_blip_' .. deliveryIdStr] = nil
    end
    
    if activeZones['delivery_checkpoint_' .. deliveryIdStr] then
        DeleteCheckpoint(activeZones['delivery_checkpoint_' .. deliveryIdStr])
        activeZones['delivery_checkpoint_' .. deliveryIdStr] = nil
    end
end

exports('CreateDeliveryDestinationZone', CreateDeliveryDestinationZone)
exports('RemoveDeliveryDestinationZone', RemoveDeliveryDestinationZone)
