local collectionBlip = {}
local timerActive = false
local collecting = false
local valveStartTime, valveDuration = 0, 0

-- [[ Blip Creation ]] --
local function createBlip(coords, sprite, scale, color, label)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

CreateThread(function()
    createBlip(Config.OilPumpBlip.coords, Config.OilPumpBlip.icon, Config.OilPumpBlip.scale, Config.OilPumpBlip.color, Config.OilPumpBlip.label)
    createBlip(Config.RefineryBlip.coords, Config.RefineryBlip.icon, Config.RefineryBlip.scale, Config.RefineryBlip.color, Config.RefineryBlip.label)
end)

-- [[ Valve Zones ]] --
function onEnter()
    for _, coords in pairs(Config.PumpValves) do
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
end

function onExit()
    exports.ox_target:removeZone("VALVE")
end

-- [[ Valve Interaction ]] --
RegisterNetEvent('ZOTTERS-OPENVALVE', function()
    local player = PlayerPedId()
    local state = Entity(player).state
    if state.valveOpened then return end

    local success = lib.progressBar({
        duration = Config.ValveOpening,
        label = 'Opening Valve',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@scripted@freemode@ig11_valve_turn@male@',
            clip = 'action'
        },
    })

    if not success then
        return lib.notify({
            title = Config.OilCompany,
            description = 'You failed to open the valve.',
            type = 'error',
            position = 'top-center',
        })
    end

    local oil = Config.OilTypes[math.random(#Config.OilTypes)]
    state:set("valveOpened", true, true)
    state:set("oilType", oil.name, true)

    lib.notify({
        title = Config.OilCompany,
        description = 'You’ve opened the valve for: **' .. oil.label .. '**!',
        type = 'success'
    })

    LoadOilCollection(oil.label)
end)

-- [[ Oil Collection Setup ]] --
function LoadOilCollection(oilLabel)
    local player = PlayerPedId()
    if not Entity(player).state.valveOpened then return end

    local zone = Config.CollectionZones[math.random(#Config.CollectionZones)]

    exports.ox_target:addSphereZone({
        name = "CollectOil",
        coords = vec3(zone.x, zone.y, zone.z),
        radius = 3,
        debug = Config.Debug,
        options = {
            {
                label = "Fill Bucket (" .. oilLabel .. ")",
                icon = Config.CollectionIcon,
                event = "ZOTTERS-COLLECTOIL"
            }
        },
        onEnter = function()
            local now = GetGameTimer()
            local elapsed = now - (valveStartTime or now)
            local remaining = math.max(0, math.floor((valveDuration - elapsed) / 1000))

            SendNUIMessage({
                action = "showValveTimer",
                duration = remaining
            })
        end,
        onExit = function()
            SendNUIMessage({ action = "hideValveTimer" })
        end
    })

    local blip = createBlip(zone, Config.OilCollectionBlip.icon, Config.OilCollectionBlip.scale, Config.OilCollectionBlip.color, "Oil Collection")
    table.insert(collectionBlip, blip)

    StartOilTimer(Config.ValveClosing * 60 * 1000)
end

-- [[ Oil Collection Interaction ]] --
RegisterNetEvent("ZOTTERS-COLLECTOIL", function()
    if collecting then return end
    collecting = true

    local player = PlayerPedId()
    local state = Entity(player).state
    local oilType = state.oilType

    if not state.valveOpened or not oilType then
        lib.notify({
            title = Config.OilCompany,
            description = "The valve is closed or unassigned.",
            type = "error"
        })
        collecting = false
        return
    end

    lib.callback("zotters:getEmptyBucketCount", false, function(bucketCount)
        if bucketCount < 1 then
            lib.notify({
                title = Config.OilCompany,
                description = "You don’t have any empty buckets.",
                type = "error"
            })
            collecting = false
            return
        end

        for i = 1, bucketCount do
            local success = lib.progressCircle({
                duration = 2500,
                label = ("Filling Bucket %d/%d"):format(i, bucketCount),
                icon = "fa-solid fa-bucket",
                position = "middle",
                useWhileDead = false,
                canCancel = true,
                anim = {
                    dict = "amb@world_human_bum_wash@male@low@idle_a",
                    clip = "idle_a"
                },
                disable = { move = true, car = true, combat = true }
            })

            if success then
                TriggerServerEvent("zotters-oilcontainer", oilType)
                Wait(100)
            else
                lib.notify({
                    title = Config.OilCompany,
                    description = "You stopped filling.",
                    type = "error"
                })
                break
            end
        end

        collecting = false
    end)
end)

-- [[ Valve Timer ]] --
function StartOilTimer(duration)
    timerActive = true
    valveStartTime = GetGameTimer()
    valveDuration = duration
    local warned = false
    local player = PlayerPedId()
    local state = Entity(player).state

    CreateThread(function()
        while timerActive do
            local elapsed = GetGameTimer() - valveStartTime

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
                SendNUIMessage({ action = "hideValveTimer" })
                exports.ox_target:removeZone("CollectOil")

                state:set("valveOpened", false, true)
                state:set("oilType", nil, true)

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
