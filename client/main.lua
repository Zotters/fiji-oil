FijiOil = {
    initialized = false,
    debug = false,
    playerData = {
        ped = nil,
        coords = nil
    }
}

function FijiOil.Init()
    if FijiOil.initialized then return end
    
    FijiOil.debug = Config.Debug or false
    
    FijiOil.UpdatePlayerData()
    
    FijiOil.CreateMainBlips()
    
    RegisterNetEvent('fiji-oil:client:notify')
    AddEventHandler('fiji-oil:client:notify', function(data)
        if lib and lib.notify then
            lib.notify({
                title = data.title or Config.OilCompany,
                description = data.message,
                type = data.type or 'inform',
                duration = data.duration or 5000
            })
        else
            BeginTextCommandThefeedPost('STRING')
            AddTextComponentSubstringPlayerName(data.message)
            EndTextCommandThefeedPostTicker(false, true)
        end
    end)
    
    FijiOil.initialized = true
end

function FijiOil.UpdatePlayerData()
    FijiOil.playerData.ped = PlayerPedId()
    FijiOil.playerData.coords = GetEntityCoords(FijiOil.playerData.ped)
end

function FijiOil.CreateMainBlips()
    if Config.OilPumpBlip then
        local blip = AddBlipForCoord(
            Config.OilPumpBlip.coords.x,
            Config.OilPumpBlip.coords.y,
            Config.OilPumpBlip.coords.z
        )
        SetBlipSprite(blip, Config.OilPumpBlip.icon)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.OilPumpBlip.scale)
        SetBlipColour(blip, Config.OilPumpBlip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.OilPumpBlip.label)
        EndTextCommandSetBlipName(blip)
    end
    
    if Config.RefineryBlip then
        local blip = AddBlipForCoord(
            Config.RefineryBlip.coords.x,
            Config.RefineryBlip.coords.y,
            Config.RefineryBlip.coords.z
        )
        SetBlipSprite(blip, Config.RefineryBlip.icon)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.RefineryBlip.scale)
        SetBlipColour(blip, Config.RefineryBlip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.RefineryBlip.label)
        EndTextCommandSetBlipName(blip)
    end
    
    if Config.PackagingBlip and Config.PackagingLocations and #Config.PackagingLocations > 0 then
        for _, location in ipairs(Config.PackagingLocations) do
            local blip = AddBlipForCoord(
                location.coords.x,
                location.coords.y,
                location.coords.z
            )
            SetBlipSprite(blip, Config.PackagingBlip.icon)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.PackagingBlip.scale)
            SetBlipColour(blip, Config.PackagingBlip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.PackagingBlip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    if Config.DeliveryBlip and Config.DeliveryStartLocations and #Config.DeliveryStartLocations > 0 then
        for _, location in ipairs(Config.DeliveryStartLocations) do
            local blip = AddBlipForCoord(
                location.coords.x,
                location.coords.y,
                location.coords.z
            )
            SetBlipSprite(blip, Config.DeliveryBlip.icon)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.DeliveryBlip.scale)
            SetBlipColour(blip, Config.DeliveryBlip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.DeliveryBlip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function FijiOil.GetItemLabel(item)
    if Config.ItemLabels and Config.ItemLabels[item] then
        return Config.ItemLabels[item]
    end
    return item
end

CreateThread(function()
    Wait(1000)
    
    FijiOil.Init()
    
    while true do
        FijiOil.UpdatePlayerData()
        Wait(1000)
    end
end)

exports('GetPlayerData', function()
    return FijiOil.playerData
end)

exports('GetItemLabel', function(item)
    return FijiOil.GetItemLabel(item)
end)
