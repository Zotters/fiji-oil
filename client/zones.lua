local activeZones = {}

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
        exports.ox_target:addSphereZone({
            name = "oil_valve_" .. tostring(id),
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 0.5,
            debug = Config.Debug or false,
            options = {
                {
                    name = "open_valve_" .. tostring(id),
                    icon = Config.ValveIcon or 'fa-solid fa-faucet',
                    label = "Open Valve",
                    onSelect = function()
                        exports['fiji-oil']:DirectOpenValve(id)
                    end
                }
            }
        })
    end
end

function SetupRefineryZones()
    if Config and Config.Hopper then
        exports.ox_target:addBoxZone({
            name = "refinery_hopper",
            coords = Config.Hopper,
            size = vec3(3, 3, 3),
            rotation = 0,
            debug = Config.Debug or false,
            options = {
                {
                    name = "load_hopper",
                    icon = "fa-solid fa-arrow-down",
                    label = "Load Hopper",
                    event = "fiji-oil:client:openHopperMenu"
                }
            }
        })
    end
    
    if Config and Config.Distill then
        exports.ox_target:addBoxZone({
            name = "refinery_distill",
            coords = Config.Distill,
            size = vec3(3, 3, 3),
            rotation = 0,
            debug = Config.Debug or false,
            options = {
                {
                    name = "start_distillation",
                    icon = "fa-solid fa-temperature-high",
                    label = "Begin Distillation",
                    event = "fiji-oil:client:startDistillation"
                }
            }
        })
    end
    
    if Config and Config.Extraction then
        exports.ox_target:addBoxZone({
            name = "refinery_extraction",
            coords = Config.Extraction,
            size = vec3(3, 3, 3),
            rotation = 0,
            debug = Config.Debug or false,
            options = {
                {
                    name = "start_extraction",
                    icon = "fa-solid fa-flask",
                    label = "Extract Refined Oil",
                    event = "fiji-oil:client:startExtraction"
                }
            }
        })
    end
end

function SetupPackagingZones()
    if not Config or not Config.PackagingLocations then return end
    
    for i, location in ipairs(Config.PackagingLocations) do
        exports.ox_target:addBoxZone({
            name = "oil_packaging_" .. tostring(i),
            coords = location.coords,
            size = vec3(3, 3, 3),
            rotation = 0,
            debug = Config.Debug or false,
            options = {
                {
                    name = "package_oil_" .. tostring(i),
                    icon = "fa-solid fa-box",
                    label = "Package Oil",
                    event = "fiji-oil:client:openPackagingMenu"
                }
            }
        })
    end
end

function SetupDeliveryZones()
    if not Config or not Config.DeliveryStartLocations then return end
    
    for i, location in ipairs(Config.DeliveryStartLocations) do
        exports.ox_target:addBoxZone({
            name = "oil_delivery_start_" .. tostring(i),
            coords = location.coords,
            size = vec3(3, 3, 3),
            rotation = 0,
            debug = Config.Debug or false,
            options = {
                {
                    name = "start_delivery_" .. tostring(i),
                    icon = "fa-solid fa-truck",
                    label = "Start Oil Delivery",
                    event = "fiji-oil:client:openDeliveryMenu"
                }
            }
        })
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

