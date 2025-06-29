local ValveOpened = false
local collectionBlip = {}
local timerActive = false
CurrentOilType = chosenOil


function onEnter()
    for _, coords in pairs(Config.PumpValves) do
        setupValves(coords)
    end
end

function setupValves(coords)
        exports.ox_target:addSphereZone({
            name = "VALVE",
            coords = vec3(coords.x, coords.y, coords.z),
            radius = 0.4,
                options = {
                    label = "Open Valve",
                    distance = 2.0,
                    icon = Config.ValveIcon,
                    event = 'ZOTTERS-OPENVALVE'
                },
        })
end

RegisterNetEvent('ZOTTERS-OPENVALVE', function(info)
    if not ValveOpened then
        if lib.progressBar({
            duration = Config.ValveOpening,
            label = 'Opening Valve',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
            },
            anim = {
                dict = 'anim@scripted@freemode@ig11_valve_turn@male@',
                clip = 'action',
            },
        }) then 
                        -- RANDOMIZING OIL TYPES
                        CurrentOilType = Config.OilTypes[math.random(#Config.OilTypes)]
                        lib.notify({
                            title = Config.OilCompany,
                            description = 'You’ve opened the valve for: **' .. CurrentOilType .. '**!',
                            type = 'success'
                        })
                        ValveOpened = true
                        LoadOilCollection()
                else lib.notify({
                    title = Config.OilCompany,
                    description = 'You failed to open the valve.',
                    type = 'error'
                }) end
            end
end)

function LoadOilCollection()
    if ValveOpened then
                -- RANDOM COLLECTION ZONE LOGIC
                local zones = Config.CollectionZones
                local chosenZone = zones[math.random(#zones)]
                -- TARGET LOGIC
            exports.ox_target:addSphereZone({
                name = "CollectOil",
                coords = vec3(chosenZone.x, chosenZone.y, chosenZone.z),
                radius = 1,
                options = {
                    label = "Fill Bucket",
                    icon = Config.CollectionIcon,
                    event = "ZOTTERS-COLLECTOIL"
                },
            })
                -- BLIP LOGIC
            local blip = AddBlipForCoord(chosenZone.x, chosenZone.y, chosenZone.z)
            SetBlipSprite(blip, 415)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 5)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Oil Collection")
            EndTextCommandSetBlipName(blip)

            table.insert(collectionBlip, blip)
            -- TIMER LOGIC
            StartOilTimer(Config.ValveClosing * 60 * 1000)
    end
end

function StartOilTimer(duration)
    timerActive = true
    local startTime = GetGameTimer()
    local warned = false

    CreateThread(function()
        while timerActive do
            local elapsed = GetGameTimer() - startTime

            -- Optional: 5-second warning
            if not warned and elapsed >= duration - 5000 then
                warned = true
                lib.notify({
                    title = Config.OilCompany,
                    description = 'Valve closing in 5 seconds!',
                    type = 'warning'
                })
            end
            if elapsed >= duration then
                timerActive = false
                -- CLEANUP LOGIC
                exports.ox_target:removeZone("CollectOil")
                ValveOpened = false

                for _, blip in ipairs(collectionBlip) do
                    RemoveBlip(blip)
                end
                collectionBlip = {}

                lib.notify({
                    title = Config.OilCompany,
                    description = 'The valve has closed!',
                    type = 'error'
                })
            end
            Wait(250) 
        end
    end)
end

function onExit(self)
    exports.ox_target:removeZone("VALVE")
end