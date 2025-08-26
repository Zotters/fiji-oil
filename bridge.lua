local Fiji = {}
local Inventory = nil
local Target = nil

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
    
    local detectedTarget = DetectTarget()
    Target = detectedTarget
    
    return true
end

function Fiji.HasItem(source, item, amount)
    amount = amount or 1
    
    if Inventory == 'ox' then
        local count = exports.ox_inventory:GetItemCount(source, item)
        return count >= amount, count
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false, 0 end
        
        local item = Player.Functions.GetItemByName(item)
        return item and item.amount >= amount, item and item.amount or 0
    elseif Inventory == 'qs' then
        local count = exports['qs-inventory']:GetItemAmount(source, item)
        return count >= amount, count
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false, 0 end
        
        local item = xPlayer.getInventoryItem(item)
        return item and item.count >= amount, item and item.count or 0
    end
    
    return false, 0
end

function Fiji.AddItem(source, item, amount, metadata)
    if Inventory == 'ox' then
        return exports.ox_inventory:AddItem(source, item, amount, metadata)
    elseif Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        return Player.Functions.AddItem(item, amount, nil, metadata)
    elseif Inventory == 'qs' then
        return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        return xPlayer.addInventoryItem(item, amount)
    end
    
    return false
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

function Fiji.GetMoney(source, account)
    account = account or 'cash'
    
    if Inventory == 'ox' or Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return 0 end
        
        return Player.PlayerData.money[account]
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return 0 end
        
        if account == 'cash' then
            return xPlayer.getMoney()
        else
            return xPlayer.getAccount(account).money
        end
    end
    
    return 0
end

function Fiji.AddMoney(source, account, amount, reason)
    account = account or 'cash'
    reason = reason or 'Fiji Oil: Money added'
    
    if Inventory == 'ox' or Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        Player.Functions.AddMoney(account, amount, reason)
        return true
    elseif Inventory == 'esx' then
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
    
    return false
end

function Fiji.RemoveMoney(source, account, amount, reason)
    account = account or 'cash'
    reason = reason or 'Fiji Oil: Money removed'
    
    if Inventory == 'ox' or Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        Player.Functions.RemoveMoney(account, amount, reason)
        return true
    elseif Inventory == 'esx' then
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
    end
    
    return false
end

function Fiji.Notify(source, message, type, duration)
    type = type or 'inform'
    duration = duration or 5000
    
    if Inventory == 'ox' then
        TriggerClientEvent('ox_lib:notify', source, {
            title = Config.OilCompany,
            description = message,
            type = type,
            duration = duration
        })
    elseif Inventory == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, type, duration)
    elseif Inventory == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {Config.OilCompany, message}
        })
    end
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
        local item = QBCore.Shared.Items[item]
        if item then
            return item.label
        end
    elseif Inventory == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local item = ESX.GetItemLabel(item)
        if item then
            return item
        end
    end
    
    return item
end

function Fiji.AddTargetBoxZone(name, coords, size, rotation, options, debug)
    if not Config.UseTarget then
        return false
    end
    
    -- Direct check for ox_target
    if GetResourceState('ox_target') == 'started' then
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
    
    -- Fall back to other target systems
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
    
    -- Direct check for ox_target
    if GetResourceState('ox_target') == 'started' then
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
    
    -- Fall back to other target systems
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
    
    if GetResourceState('ox_target') == 'started' then
        return exports.ox_target:removeZone(name)
    elseif Target == 'qb' then
        return exports['qb-target']:RemoveZone(name)
    elseif Target == 'qtarget' then
        return exports.qtarget:RemoveZone(name)
    end
    
    return false
end

function Fiji.AddTargetEntity(entity, options)
    if not Config.UseTarget then
        return false
    end
    
    if GetResourceState('ox_target') == 'started' then
        return exports.ox_target:addEntity(entity, options)
    elseif Target == 'qb' then
        return exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = 2.5
        })
    elseif Target == 'qtarget' then
        return exports.qtarget:AddTargetEntity(entity, {
            options = options,
            distance = 2.5
        })
    end
    
    return false
end

function Fiji.GetTargetSystem()
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

return Fiji
