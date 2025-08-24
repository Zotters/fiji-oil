local Bridge = {}
local Inventory = nil

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

function Bridge.Init()
    local detectedInventory = DetectInventory()
    
    if not detectedInventory then
        print("^1[Fiji Oil] No supported inventory system detected!^7")
        return false
    end
    
    print("^2[Fiji Oil] Detected inventory system: " .. detectedInventory .. "^7")
    Inventory = detectedInventory
    return true
end

function Bridge.HasItem(source, item, amount)
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

function Bridge.AddItem(source, item, amount, metadata)
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

function Bridge.RemoveItem(source, item, amount, metadata)
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

function Bridge.GetMoney(source, account)
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

function Bridge.AddMoney(source, account, amount, reason)
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

function Bridge.RemoveMoney(source, amount, account, reason)
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

function Bridge.Notify(source, message, type, duration)
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

function Bridge.GetItemLabel(item)
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

return Bridge
