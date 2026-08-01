local isPackaging = false

CreateThread(function()
    Wait(1500)

    Fiji.AddInteraction(
        'fiji_packaging',
        { type = 'box', coords = Config.PackagingLocation.coords, size = vec3(3, 3, 3), rotation = 0 },
        { { name = 'package_oil', icon = 'fa-solid fa-box', label = 'Package Oil', event = 'fiji-oil:client:openPackagingMenu' } },
        Config.Debug or false
    )
end)

RegisterNetEvent('fiji-oil:client:openPackagingMenu', function() OpenPackagingMenu() end)

function OpenPackagingMenu()
    if isPackaging then
        UI.Notify({ description = 'Packaging is busy', type = 'error' })
        return
    end

    local oilData = Callback.TriggerSync('fiji-oil:packaging:getRefinedOil', nil) or {}
    if #oilData == 0 then
        UI.Notify({ description = "You don't have any refined oil", type = 'error' })
        return
    end

    local drumCount = Callback.TriggerSync('fiji-oil:packaging:getEmptyDrums', nil) or 0
    if drumCount <= 0 then
        UI.Notify({ description = "You don't have any empty drums", type = 'error' })
        return
    end

    local options = {}
    for _, oil in ipairs(oilData) do
        local maxPackage = math.min(oil.count, drumCount)
        table.insert(options, {
            title = 'Package ' .. oil.label,
            description = 'You have ' .. oil.count .. 'x ' .. oil.label .. ' and ' .. drumCount .. 'x Empty Drums',
            onSelect = function() PackageOil(oil.name, oil.label, maxPackage) end,
        })
    end

    UI.ContextMenu('Select Oil to Package', options)
end

function PackageOil(oilType, oilLabel, maxCount)
    if isPackaging then return end

    local input = UI.InputDialog('Package ' .. oilLabel, {
        { type = 'number', label = 'Quantity', description = 'How many units to package (max ' .. maxCount .. ')', default = 1, min = 1, max = maxCount },
    })

    if not input or not input[1] then return end

    local quantity = math.floor(input[1])
    if quantity < 1 or quantity > maxCount then
        UI.Notify({ description = "Invalid quantity", type = 'error' })
        return
    end

    isPackaging = true
    local packaged = 0
    local cancelled = false

    for i = 1, quantity do
        if UI.ProgressBar({
            duration = Config.PackagingTime or 3000,
            label = 'Packaging Oil (' .. i .. '/' .. quantity .. ')',
            canCancel = true,
            disable = { car = true, move = true, combat = true },
        }) then
            TriggerServerEvent('fiji-oil:server:packageOil', oilType)
            packaged = packaged + 1
        else
            cancelled = true
            break
        end
    end

    isPackaging = false

    if cancelled then
        UI.Notify({ description = 'Packaging cancelled after packaging ' .. packaged .. ' units', type = 'inform' })
    else
        UI.Notify({ description = 'Successfully packaged ' .. packaged .. ' units of oil', type = 'success' })
    end
end
