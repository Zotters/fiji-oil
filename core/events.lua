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





