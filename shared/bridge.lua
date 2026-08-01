Fiji = Fiji or {}
local Inventory = nil
local Target = nil
local Framework = nil

local function Warn(msg)
    print('^1[fiji-oil]^0 ' .. msg)
end

local function DetectInventory()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    else
        return nil
    end
end

-- Framework is independent of Inventory: ox_inventory (and qs-inventory) run on top of
-- either ESX or QBCore/QBX, so money/identifier operations can't be decided by which
-- inventory happens to be running.
local function DetectFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    else
        return nil
    end
end

local function DetectTarget()
    if GetResourceState('ox_target') == 'started' then
        return 'ox'
    elseif GetResourceState('qb-target') == 'started' then
        return 'qb'
    elseif GetResourceState('qtarget') == 'started' then
        return 'qtarget'
    else
        return nil
    end
end

function Fiji.Init()
    local detectedInventory = DetectInventory()

    if not detectedInventory then
        return false
    end

    Inventory = detectedInventory
    Framework = DetectFramework()
    Target = DetectTarget()

    return true
end

function Fiji.GetFramework()
    return Framework
end

function Fiji.GetInventorySystem()
    return Inventory
end

function Fiji.GetTargetSystem()
    return Target
end

-- ============================================================
-- Items
-- ============================================================
function Fiji.HasItem(source, item, amount)
    amount = amount or 1

    if Inventory == 'ox' then
        local count = exports.ox_inventory:GetItemCount(source, item)
        return count >= amount, count
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false, 0 end

        local playerItem = Player.Functions.GetItemByName(item)
        return playerItem and playerItem.amount >= amount, playerItem and playerItem.amount or 0
    elseif Inventory == 'qs' then
        local count = exports['qs-inventory']:GetItemAmount(source, item)
        return count >= amount, count
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false, 0 end

        local playerItem = xPlayer.getInventoryItem(item)
        return playerItem and playerItem.count >= amount, playerItem and playerItem.count or 0
    end

    return false, 0
end

function Fiji.ItemExists(item)
    if Inventory == 'ox' then
        local ok, items = pcall(function() return exports.ox_inventory:Items() end)
        return ok and items and items[item] ~= nil
    elseif Inventory == 'qb' then
        local ok, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
        return ok and QBCore and QBCore.Shared.Items[item] ~= nil
    elseif Inventory == 'esx' then
        local ok, ESX = pcall(function() return exports['es_extended']:getSharedObject() end)
        return ok and ESX and ESX.GetItemLabel(item) ~= nil
    end

    return true -- qs-inventory has no catalog export to check against - assume it's fine
end

function Fiji.AddItem(source, item, amount, metadata)
    local added = false

    if Inventory == 'ox' then
        added = exports.ox_inventory:AddItem(source, item, amount, metadata)
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            added = Player.Functions.AddItem(item, amount, nil, metadata)
        end
    elseif Inventory == 'qs' then
        added = exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            added = xPlayer.addInventoryItem(item, amount)
        end
    end

    if not added then
        if not Fiji.ItemExists(item) then
            Warn(('AddItem failed: "%s" is not a registered item in your %s inventory config. Add it there before it can be granted to players.'):format(tostring(item), tostring(Inventory)))
        else
            Warn(('AddItem failed for "%s" x%s (source %s) - player is likely out of inventory space or weight.'):format(tostring(item), tostring(amount), tostring(source)))
        end
    end

    return added
end

function Fiji.RemoveItem(source, item, amount, metadata)
    if Inventory == 'ox' then
        return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        return Player.Functions.RemoveItem(item, amount, nil, metadata)
    elseif Inventory == 'qs' then
        return exports['qs-inventory']:RemoveItem(source, item, amount, nil, metadata)
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end

        return xPlayer.removeInventoryItem(item, amount)
    end

    return false
end

function Fiji.GetItemLabel(item)
    if Config.ItemLabels and Config.ItemLabels[item] then
        return Config.ItemLabels[item]
    end

    if Inventory == 'ox' then
        local items = exports.ox_inventory:Items()
        if items[item] then
            return items[item].label
        end
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local qbItem = QBCore.Shared.Items[item]
        if qbItem then
            return qbItem.label
        end
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local label = ESX.GetItemLabel(item)
        if label then
            return label
        end
    end

    return item
end

function Fiji.RegisterUsableItem(itemName, handler)
    if Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem(itemName, function(src, item)
            handler(src, item)
        end)
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterUsableItem(itemName, function(src)
            handler(src, { name = itemName })
        end)
    elseif Inventory == 'qs' then
        exports['qs-inventory']:CreateUsableItem(itemName, function(src, item)
            handler(src, item)
        end)
    end
end

-- ============================================================
-- Money (branches on Framework, not Inventory - see DetectFramework comment above)
-- ============================================================
function Fiji.GetMoney(source, account)
    account = account or 'cash'

    -- QBX Core ships a 'qb-core' compatibility export, so it shares the qb branch.
    if Framework == 'qb' or Framework == 'qbx' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return 0 end

        return Player.PlayerData.money[account]
    elseif Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return 0 end

        if account == 'cash' then
            return xPlayer.getMoney()
        else
            return xPlayer.getAccount(account).money
        end
    end

    Warn(('GetMoney: no supported framework detected (Framework=%s, Inventory=%s)'):format(tostring(Framework), tostring(Inventory)))
    return 0
end

function Fiji.AddMoney(source, account, amount, reason)
    account = account or 'cash'
    reason = reason or 'Fiji Oil: Money added'

    if Framework == 'qb' or Framework == 'qbx' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        Player.Functions.AddMoney(account, amount, reason)
        return true
    elseif Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end

        if account == 'cash' then
            xPlayer.addMoney(amount)
        else
            xPlayer.addAccountMoney(account, amount)
        end
        return true
    end

    Warn(('AddMoney: no supported framework detected (Framework=%s, Inventory=%s) - player was not paid'):format(tostring(Framework), tostring(Inventory)))
    return false
end

function Fiji.RemoveMoney(source, account, amount, reason)
    account = account or 'cash'
    reason = reason or 'Fiji Oil: Money removed'

    if Framework == 'qb' or Framework == 'qbx' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        if (Player.PlayerData.money[account] or 0) < amount then
            return false
        end

        Player.Functions.RemoveMoney(account, amount, reason)
        return true
    elseif Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end

        if account == 'cash' then
            if xPlayer.getMoney() >= amount then
                xPlayer.removeMoney(amount)
                return true
            end
        else
            if xPlayer.getAccount(account).money >= amount then
                xPlayer.removeAccountMoney(account, amount)
                return true
            end
        end

        return false
    end

    Warn(('RemoveMoney: no supported framework detected (Framework=%s, Inventory=%s)'):format(tostring(Framework), tostring(Inventory)))
    return false
end

-- Stable per-character identifier for persistence (reputation/contracts/supply orders).
-- V1 never needed this since it was entirely session-scoped and DB-less.
function Fiji.GetIdentifier(source)
    if Framework == 'qb' or Framework == 'qbx' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    elseif Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    end

    Warn(('GetIdentifier: no supported framework detected (Framework=%s) - falling back to license identifier'):format(tostring(Framework)))

    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('license:') then
            return id
        end
    end

    return nil
end

-- ============================================================
-- Notifications - always custom NUI now (client/ui.lua renders it),
-- no more per-inventory branching to ox_lib/QBCore/ESX toast events.
-- ============================================================
function Fiji.Notify(source, message, notifyType, duration)
    TriggerClientEvent('fiji-oil:client:notify', source, {
        title = Config.OilCompany,
        description = message,
        type = notifyType or 'inform',
        duration = duration or 5000,
    })
end

-- ============================================================
-- Vehicle keys (client-only; generalized from V1's client/delivery.lua).
-- Tries every key system we know of, falls back to leaving the vehicle unlocked.
-- ============================================================
-- qbx_vehiclekeys' actual grant call (exports.qbx_vehiclekeys:GiveKeys(source, vehicle),
-- confirmed against qbx_core/config/server.lua) is server-only, so it needs a round trip
-- - the rest of these key systems expose their own TriggerServerEvent for the same reason.
if IsDuplicityVersion() then
    RegisterNetEvent('fiji-oil:server:giveVehicleKeys', function(vehicleNetId)
        local source = source
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if vehicle and vehicle ~= 0 then
            exports.qbx_vehiclekeys:GiveKeys(source, vehicle)
        end
    end)
end

function Fiji.GiveVehicleKeys(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return false end

    if GetResourceState('qbx_vehiclekeys') == 'started' then
        TriggerServerEvent('fiji-oil:server:giveVehicleKeys', NetworkGetNetworkIdFromEntity(vehicle))
        return true
    elseif GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', NetworkGetNetworkIdFromEntity(vehicle))
        return true
    elseif GetResourceState('esx_vehiclelock') == 'started' then
        TriggerServerEvent('esx_vehiclelock:givekey', 'no', GetVehicleNumberPlateText(vehicle))
        return true
    elseif GetResourceState('wasabi_carlock') == 'started' then
        TriggerServerEvent('wasabi_carlock:addKeys', GetVehicleNumberPlateText(vehicle))
        return true
    elseif GetResourceState('mk_vehiclekeys') == 'started' then
        TriggerEvent('mk_vehiclekeys:client:addkey', GetVehicleNumberPlateText(vehicle))
        return true
    end

    -- No recognized key system - leave it unlocked so the rental is still usable.
    -- Confirmed harmless on qbx_core specifically: its own hasKeys check
    -- (config/client.lua) returns true whenever qbx_vehiclekeys isn't running,
    -- i.e. no key enforcement exists at all in that case.
    SetVehicleDoorsLocked(vehicle, 1)
    return false
end

-- ============================================================
-- Target zones / proximity fallback
-- ============================================================
function Fiji.AddTargetBoxZone(name, coords, size, rotation, options, debug)
    if not Config.UseTarget then
        return false
    end

    if Target == 'ox' then
        local formattedOptions = {}
        for _, option in ipairs(options) do
            local formattedOption = {
                name = option.name,
                icon = option.icon,
                label = option.label
            }

            if option.event then
                formattedOption.onSelect = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                formattedOption.onSelect = option.onSelect
            end

            table.insert(formattedOptions, formattedOption)
        end

        return exports.ox_target:addBoxZone({
            name = name,
            coords = coords,
            size = size,
            rotation = rotation,
            debug = debug,
            options = formattedOptions
        })
    end

    if Target == 'qb' then
        local qbOptions = {}
        for _, option in ipairs(options) do
            local qbOption = {
                type = "client",
                icon = option.icon,
                label = option.label
            }

            if option.event then
                qbOption.action = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                qbOption.action = option.onSelect
            end

            table.insert(qbOptions, qbOption)
        end

        return exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
            name = name,
            heading = rotation,
            debugPoly = debug,
            minZ = coords.z - (size.z / 2),
            maxZ = coords.z + (size.z / 2)
        }, {
            options = qbOptions,
            distance = 2.5
        })
    elseif Target == 'qtarget' then
        local qtOptions = {}
        for _, option in ipairs(options) do
            local qtOption = {
                icon = option.icon,
                label = option.label
            }

            if option.event then
                qtOption.action = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                qtOption.action = option.onSelect
            end

            table.insert(qtOptions, qtOption)
        end

        return exports.qtarget:AddBoxZone(name, coords, size.x, size.y, {
            name = name,
            heading = rotation,
            debugPoly = debug,
            minZ = coords.z - (size.z / 2),
            maxZ = coords.z + (size.z / 2)
        }, {
            options = qtOptions,
            distance = 2.5
        })
    end

    return false
end

function Fiji.AddTargetSphereZone(name, coords, radius, options, debug)
    if not Config.UseTarget then
        return false
    end

    if Target == 'ox' then
        local formattedOptions = {}
        for _, option in ipairs(options) do
            local formattedOption = {
                name = option.name,
                icon = option.icon,
                label = option.label
            }

            if option.event then
                formattedOption.onSelect = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                formattedOption.onSelect = option.onSelect
            end

            table.insert(formattedOptions, formattedOption)
        end

        return exports.ox_target:addSphereZone({
            name = name,
            coords = coords,
            radius = radius,
            debug = debug,
            options = formattedOptions
        })
    end

    if Target == 'qb' then
        local qbOptions = {}
        for _, option in ipairs(options) do
            local qbOption = {
                type = "client",
                icon = option.icon,
                label = option.label
            }

            if option.event then
                qbOption.action = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                qbOption.action = option.onSelect
            end

            table.insert(qbOptions, qbOption)
        end

        return exports['qb-target']:AddCircleZone(name, vector3(coords.x, coords.y, coords.z), radius, {
            name = name,
            debugPoly = debug
        }, {
            options = qbOptions,
            distance = radius
        })
    elseif Target == 'qtarget' then
        local qtOptions = {}
        for _, option in ipairs(options) do
            local qtOption = {
                icon = option.icon,
                label = option.label
            }

            if option.event then
                qtOption.action = function()
                    TriggerEvent(option.event)
                end
            elseif option.onSelect then
                qtOption.action = option.onSelect
            end

            table.insert(qtOptions, qtOption)
        end

        return exports.qtarget:AddCircleZone(name, vector3(coords.x, coords.y, coords.z), radius, {
            name = name,
            debugPoly = debug
        }, {
            options = qtOptions,
            distance = radius
        })
    end

    return false
end

function Fiji.RemoveTargetZone(name)
    if not Config.UseTarget then
        return false
    end

    if Target == 'ox' then
        return exports.ox_target:removeZone(name)
    elseif Target == 'qb' then
        return exports['qb-target']:RemoveZone(name)
    elseif Target == 'qtarget' then
        return exports.qtarget:RemoveZone(name)
    end

    return false
end

--──────────────────────────────────────────────────────────────────────────
-- Unified interaction API: hides the target-vs-proximity branch so feature
-- files just describe a shape + options once. Proximity fallback renders its
-- hint through the custom UI kit (client/ui.lua's global UI table) - no ox_lib.
--──────────────────────────────────────────────────────────────────────────
local trackedInteractions = {}

local function StartProximityInteraction(name, coords, options)
    trackedInteractions[name] = true
    local option = options[1]

    CreateThread(function()
        local hintShown = false

        while trackedInteractions[name] do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))

            if distance < Config.InteractionDistance * 2 then
                sleep = 0

                if distance < Config.InteractionDistance then
                    if not hintShown then
                        UI.ShowTextUI(option and option.label or 'Interact', option and option.icon or nil)
                        hintShown = true
                    end

                    if option and IsControlJustReleased(0, 38) then -- E key
                        if option.onSelect then
                            option.onSelect()
                        elseif option.event then
                            TriggerEvent(option.event)
                        end
                    end
                elseif hintShown then
                    UI.HideTextUI()
                    hintShown = false
                end
            end

            Wait(sleep)
        end

        UI.HideTextUI()
    end)
end

-- shape = { type = 'box'|'sphere', coords = vector3, size = vector3, rotation = number, radius = number }
-- (size/rotation only apply to 'box', radius only applies to 'sphere')
function Fiji.AddInteraction(name, shape, options, debug)
    if Config.UseTarget and Target then
        if shape.type == 'sphere' then
            return Fiji.AddTargetSphereZone(name, shape.coords, shape.radius, options, debug)
        end

        return Fiji.AddTargetBoxZone(name, shape.coords, shape.size, shape.rotation or 0, options, debug)
    end

    StartProximityInteraction(name, shape.coords, options)
    return true
end

function Fiji.RemoveInteraction(name)
    if Config.UseTarget and Target then
        return Fiji.RemoveTargetZone(name)
    end

    trackedInteractions[name] = nil
    return true
end
