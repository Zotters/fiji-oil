RegisterNetEvent('ZOTTERS-MISSINGITEM', function()
    lib.notify({
        title = 'Oil Company',
        description = 'Missing items',
        type = 'error'
    })
end)

RegisterNetEvent('ZOTTERS-FULLINVENTORY', function()
    lib.notify({
        title = 'Oil Company',
        description = 'Inventory full!',
        type = 'error'
    })
end)

RegisterNetEvent('ZOTTERS-COLLECTOIL', function()
    if CurrentOilType then
        TriggerServerEvent('zotters-oilcontainer', CurrentOilType)
    else
        TriggerServerEvent('zotters-oilcontainer', "Unknown Oil")
    end
end)

RegisterNetEvent("ZOTTERS-REFINERY:StartRefine", function()
        TriggerServerEvent("ZOTTERS-REFINERY:RefineOil")
end)

RegisterNetEvent("ZOTTERS-REFINERY:ShowRefineProgress", function(refineTime)
    lib.progressBar({
        duration = refineTime,
        label = 'Refining ' .. (oilLabel or "crude oil") .. '...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,
        },
    })
end)

RegisterNetEvent("ZOTTERS-DRUM:StartLoad", function()
    TriggerServerEvent("ZOTTERS-DRUM:LoadOilToDrum")
end)

RegisterNetEvent("ZOTTERS-DRUM:ShowDrumFilling", function(duration, oilType)
    lib.progressBar({
        duration = duration,
        label = "" .. (oilType or "refined oil") .. "...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = true
        },
    })
end)


