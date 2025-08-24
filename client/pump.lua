local activePumps = {}
local isCollecting = false

exports('DirectOpenValve', function(pumpId)
    OpenValve(pumpId)
end)

RegisterNetEvent('fiji-oil:client:openValve')
AddEventHandler('fiji-oil:client:openValve', function(data)
    if data and data.pumpId then
        OpenValve(data.pumpId)
    end
end)

RegisterNetEvent('fiji-oil:client:collectOil')
AddEventHandler('fiji-oil:client:collectOil', function(data)
    if data and data.pumpId and data.oilType then
        CollectOil(data.pumpId, data.oilType)
    end
end)

function OpenValve(pumpId)
    if not pumpId then
        return false
    end
    
    if activePumps[pumpId] then
        lib.notify({
            title = Config.OilCompany,
            description = 'This valve is already open',
            type = 'error'
        })
        return false
    end
    
    if not lib.progressBar({
        duration = Config.ValveOpening,
        label = 'Opening Valve',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
    }) then
        lib.notify({
            title = Config.OilCompany,
            description = 'Valve opening cancelled',
            type = 'error'
        })
        return false
    end
    
    local oilTypeIndex = math.random(#Config.OilTypes)
    local oilType = Config.OilTypes[oilTypeIndex]
    
    if not oilType then
        lib.notify({
            title = Config.OilCompany,
            description = 'Error selecting oil type',
            type = 'error'
        })
        return false
    end
    
    local zoneIndex = math.random(#Config.CollectionZones)
    local zoneCoords = Config.CollectionZones[zoneIndex]
    
    if not zoneCoords then
        lib.notify({
            title = Config.OilCompany,
            description = 'Error finding collection zone',
            type = 'error'
        })
        return false
    end
    
    local collectionZone = CreateCollectionZone(zoneCoords, pumpId, oilType)
    if not collectionZone then
        lib.notify({
            title = Config.OilCompany,
            description = 'Error creating collection zone',
            type = 'error'
        })
        return false
    end
    
    activePumps[pumpId] = {
        oilType = oilType,
        zone = collectionZone,
        timeRemaining = Config.ValveClosing * 60,
        startTime = GetGameTimer()
    }
    
    StartValveTimer(pumpId)
    
    SendNUIMessage({
        action = "showValveTimer",
        duration = Config.ValveClosing * 60
    })
    
    lib.notify({
        title = Config.OilCompany,
        description = 'Valve opened! Check your map for the collection point.',
        type = 'success'
    })
    
    return true
end

function CreateCollectionZone(coords, pumpId, oilType)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    if not blip then
        return nil
    end
    
    SetBlipSprite(blip, Config.OilCollectionBlip and Config.OilCollectionBlip.icon or 415)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.OilCollectionBlip and Config.OilCollectionBlip.scale or 0.8)
    SetBlipColour(blip, Config.OilCollectionBlip and Config.OilCollectionBlip.color or 5)
    SetBlipAsShortRange(blip, false)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Oil Collection")
    EndTextCommandSetBlipName(blip)
        
    exports.ox_target:addSphereZone({
        name = "oil_collection_" .. tostring(pumpId),
        coords = vec3(coords.x, coords.y, coords.z),
        radius = 3.0,
        debug = Config.Debug or false,
        options = {
            {
                name = "collect_oil_" .. tostring(pumpId),
                icon = Config.CollectionIcon or 'fa-solid fa-fill-drip',
                label = "Collect " .. oilType.label .. " Oil",
                onSelect = function()
                    CollectOil(pumpId, oilType.name)
                end
            }
        }
    })
    
    return {
        blip = blip,
        zone = zone,
        pumpId = pumpId
    }
end

function StartValveTimer(pumpId)
    CreateThread(function()
        local pumpData = activePumps[pumpId]
        if not pumpData then return end
        
        local startTime = pumpData.startTime
        local duration = pumpData.timeRemaining * 1000
        local warned = false
        
        while activePumps[pumpId] do
            local elapsed = GetGameTimer() - startTime
            local remaining = math.max(0, math.floor((duration - elapsed) / 1000))
            
            activePumps[pumpId].timeRemaining = remaining
            
            SendNUIMessage({
                action = "updateValveTimer",
                time = remaining
            })
            
            if not warned and remaining <= 30 then
                warned = true
                lib.notify({
                    title = Config.OilCompany,
                    description = 'Valve closing in 30 seconds!',
                    type = 'warning'
                })
            end
            
            if remaining <= 0 then
                CloseValve(pumpId)
                break
            end
            
            Wait(1000)
        end
    end)
end

function CloseValve(pumpId)
    local pumpData = activePumps[pumpId]
    if not pumpData then return false end
    
    if pumpData.zone then
        if pumpData.zone.blip then
            RemoveBlip(pumpData.zone.blip)
        end
        
        if pumpData.zone.zone then
            pumpData.zone.zone:remove()
        end
    end
    
    exports.ox_target:removeZone("oil_collection_" .. tostring(pumpId))
    
    activePumps[pumpId] = nil
    
    SendNUIMessage({
        action = "hideValveTimer"
    })
    
    lib.hideTextUI()
    
    lib.notify({
        title = Config.OilCompany,
        description = 'The valve has closed',
        type = 'inform'
    })
    
    return true
end

function CollectOil(pumpId, oilType)
    if isCollecting then return false end
    
    if not activePumps[pumpId] then
        lib.notify({
            title = Config.OilCompany,
            description = 'The valve is closed',
            type = 'error'
        })
        return false
    end
    
    isCollecting = true
    
    lib.callback('fiji-oil:server:getEmptyContainers', false, function(containerCount)
        if containerCount <= 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "You don't have any empty containers",
                type = 'error'
            })
            isCollecting = false
            return
        end
        
        local collected = 0
        for i = 1, containerCount do
            if lib.progressBar({
                duration = 3000,
                label = 'Collecting Oil (' .. i .. '/' .. containerCount .. ')',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    dict = 'amb@world_human_bum_wash@male@low@idle_a',
                    clip = 'idle_a'
                },
            }) then
                TriggerServerEvent('fiji-oil:server:collectOil', oilType)
                collected = collected + 1
            else
                lib.notify({
                    title = Config.OilCompany,
                    description = 'Collection cancelled',
                    type = 'error'
                })
                break
            end
            
            Wait(500)
        end
        
        if collected > 0 then
            lib.notify({
                title = Config.OilCompany,
                description = 'Collected ' .. collected .. ' containers of oil',
                type = 'success'
            })
        end
        
        isCollecting = false
    end)
    
    return true
end
