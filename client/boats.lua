-- Boat rental at the Globe Oil Marina. Safe-spawn search ported from V1's
-- client/delivery.lua (FindSafeSpawnPoint/IsAreaClear), which was already
-- proven there for vehicle spawning.

local activeBoat = nil
local rentalTier = nil
local rentalEndTime = 0

local function IsAreaClear(x, y, z, radius)
    if IsAnyVehicleNearPoint(x, y, z, radius) then
        return false
    end

    local objects = GetGamePool('CObject')
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) and not IsEntityAttached(object) then
            local objCoords = GetEntityCoords(object)
            if #(vector3(x, y, z) - objCoords) < radius then
                local model = GetEntityModel(object)
                local objectSize = GetModelDimensions(model)
                if objectSize and (objectSize.y > 1.0 or objectSize.x > 1.0) then
                    return false
                end
            end
        end
    end

    return true
end

local function FindSafeSpawnPoint(basePoint)
    local offsets = {
        { x = 0.0, y = 0.0 }, { x = 5.0, y = 0.0 }, { x = -5.0, y = 0.0 },
        { x = 0.0, y = 5.0 }, { x = 0.0, y = -5.0 }, { x = 5.0, y = 5.0 },
        { x = -5.0, y = 5.0 }, { x = 5.0, y = -5.0 }, { x = -5.0, y = -5.0 },
        { x = 10.0, y = 0.0 }, { x = -10.0, y = 0.0 }, { x = 0.0, y = 10.0 }, { x = 0.0, y = -10.0 },
    }

    for _, offset in ipairs(offsets) do
        local testPoint = { x = basePoint.x + offset.x, y = basePoint.y + offset.y, z = basePoint.z, w = basePoint.w }
        if IsAreaClear(testPoint.x, testPoint.y, testPoint.z, 4.0) then
            return testPoint
        end
    end

    return basePoint
end

local function StartRentalTimer()
    UI.ShowCountdown('Boat Rental', rentalTier.rentalMinutes * 60)

    CreateThread(function()
        while activeBoat and DoesEntityExist(activeBoat) and GetGameTimer() < rentalEndTime do
            UI.UpdateCountdown(math.max(0, math.floor((rentalEndTime - GetGameTimer()) / 1000)))
            Wait(1000)
        end

        if activeBoat and DoesEntityExist(activeBoat) then
            UI.HideCountdown()
            UI.Notify({ description = 'Your boat rental has expired.', type = 'warning' })
            DeleteEntity(activeBoat)
            activeBoat = nil
            rentalTier = nil
            Callback.Trigger('fiji-oil:boats:expire', nil, function() end)
        end
    end)
end

-- SetVehicleOnGroundProperly is for cars settling onto terrain collision -
-- calling it on a boat can shove it down into the seabed instead of leaving
-- it on the water surface. Use the actual water height at the spawn point
-- instead, falling back to the configured Z if no water is found there
-- (e.g. the configured spawn point turns out to be on land).
local function ResolveSpawnZ(x, y, fallbackZ)
    local ok, foundWater, waterZ = pcall(GetWaterHeight, x, y, fallbackZ + 5.0)
    if ok and foundWater then
        return waterZ + 0.3
    end

    return fallbackZ
end

local function SpawnRentalBoat(tier)
    local safeSpawnPoint = FindSafeSpawnPoint(Config.Marina.spawnLocation)
    local spawnZ = ResolveSpawnZ(safeSpawnPoint.x, safeSpawnPoint.y, safeSpawnPoint.z)

    RequestModel(tier.model)
    local timeout = 0
    while not HasModelLoaded(tier.model) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end

    if not HasModelLoaded(tier.model) then
        UI.Notify({ description = 'Failed to load boat model.', type = 'error' })
        return
    end

    activeBoat = CreateVehicle(tier.model, safeSpawnPoint.x, safeSpawnPoint.y, spawnZ, safeSpawnPoint.w or 0.0, true, false)
    SetEntityAsMissionEntity(activeBoat, true, true)
    SetVehicleNumberPlateText(activeBoat, 'OIL-' .. math.random(100, 999))

    Fiji.GiveVehicleKeys(activeBoat)

    rentalTier = tier
    rentalEndTime = GetGameTimer() + (tier.rentalMinutes * 60000)

    StartRentalTimer()

    UI.Notify({ description = ('Boat rented for %d minutes.'):format(tier.rentalMinutes), type = 'success' })
end

local function RentBoat(tier)
    local result = Callback.TriggerSync('fiji-oil:boats:rent', { tierId = tier.id })
    if not result or not result.success then
        UI.Notify({ description = (result and result.message) or 'Unable to rent a boat right now.', type = 'error' })
        return
    end

    SpawnRentalBoat(tier)
end

local function OpenRentalMenu()
    local options = {}
    for _, tier in ipairs(Config.BoatTiers) do
        table.insert(options, {
            title = tier.label,
            description = ('$%d - %d minutes'):format(tier.price, tier.rentalMinutes),
            onSelect = function() RentBoat(tier) end,
        })
    end

    UI.ContextMenu('Rent a Boat', options)
end

local function ReturnBoat()
    if not activeBoat or not DoesEntityExist(activeBoat) then
        UI.Notify({ description = "You don't have a rented boat.", type = 'error' })
        return
    end

    if #(GetEntityCoords(activeBoat) - Config.Marina.coords) > 20.0 then
        UI.Notify({ description = 'Return the boat to the marina first.', type = 'error' })
        return
    end

    local remainingSeconds = math.max(0, math.floor((rentalEndTime - GetGameTimer()) / 1000))
    local result = Callback.TriggerSync('fiji-oil:boats:return', {
        tierId = rentalTier and rentalTier.id,
        remainingSeconds = remainingSeconds,
    })

    UI.HideCountdown()
    DeleteEntity(activeBoat)
    activeBoat = nil
    rentalTier = nil

    if result and result.refund and result.refund > 0 then
        UI.Notify({ description = ('Boat returned. Refunded $%d.'):format(result.refund), type = 'success' })
    else
        UI.Notify({ description = 'Boat returned.', type = 'success' })
    end
end

-- One interaction point that adapts to whether you currently have a rental,
-- so proximity mode (single-option-per-interaction) and target mode both
-- work identically without needing a second zone at the same spot.
CreateThread(function()
    Wait(1500)

    Fiji.AddInteraction(
        'fiji_marina',
        { type = 'sphere', coords = Config.Marina.coords, radius = 1.5 },
        {
            {
                name = 'marina_boat',
                icon = 'fa-solid fa-ship',
                label = 'Boat Rental',
                onSelect = function()
                    if activeBoat and DoesEntityExist(activeBoat) then
                        ReturnBoat()
                    else
                        OpenRentalMenu()
                    end
                end,
            },
        },
        Config.Debug or false
    )
end)
