local isPackaging = false
local Fiji = require 'bridge'

RegisterNetEvent('fiji-oil:client:openPackagingMenu')
AddEventHandler('fiji-oil:client:openPackagingMenu', function()
    OpenPackagingMenu()
end)

function OpenPackagingMenu()
    if isPackaging then
        lib.notify({
            title = Config.OilCompany,
            description = 'Packaging is busy',
            type = 'error'
        })
        return
    end
    
    lib.callback('fiji-oil:server:getRefinedOil', false, function(oilData)
        if not oilData or #oilData == 0 then
            lib.notify({
                title = Config.OilCompany,
                description = "You don't have any refined oil",
                type = 'error'
            })
            return
        end
        
        lib.callback('fiji-oil:server:getEmptyDrums', false, function(drumCount)
            if drumCount <= 0 then
                lib.notify({
                    title = Config.OilCompany,
                    description = "You don't have any empty drums",
                    type = 'error'
                })
                return
            end
            
            local options = {}
            for _, oil in ipairs(oilData) do
                local maxPackage = math.min(oil.count, drumCount)
                
                table.insert(options, {
                    title = "Package " .. oil.label,
                    description = "You have " .. oil.count .. "x " .. oil.label .. " and " .. drumCount .. "x Empty Drums",
                    onSelect = function()
                        PackageOil(oil.name, oil.label, maxPackage)
                    end
                })
            end
            
            lib.registerContext({
                id = 'packaging_menu',
                title = 'Select Oil to Package',
                options = options
            })
            
            lib.showContext('packaging_menu')
        end)
    end)
end

function PackageOil(oilType, oilLabel, maxCount)
    if isPackaging then return end
    
    local input = lib.inputDialog('Package ' .. oilLabel, {
        {
            type = 'number',
            label = 'Quantity',
            description = 'How many units to package (max ' .. maxCount .. ')',
            default = 1,
            min = 1,
            max = maxCount,
            required = true
        }
    })
    
    if not input or not input[1] then return end
    
    local quantity = math.floor(input[1])
    if quantity < 1 or quantity > maxCount then
        lib.notify({
            title = Config.OilCompany,
            description = "Invalid quantity",
            type = 'error'
        })
        return
    end
    
    isPackaging = true
    
    local packaged = 0
    local cancelled = false
    
    for i = 1, quantity do
        if lib.progressBar({
            duration = Config.PackagingTime or 3000,
            label = 'Packaging Oil (' .. i .. '/' .. quantity .. ')',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'anim@amb@business@weed@weed_inspecting_lo_med_hi@',
                clip = 'weed_crouch_checkingleaves_idle_01_inspector'
            },
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
        lib.notify({
            title = Config.OilCompany,
            description = 'Packaging cancelled after packaging ' .. packaged .. ' units',
            type = 'inform'
        })
    else
        lib.notify({
            title = Config.OilCompany,
            description = 'Successfully packaged ' .. packaged .. ' units of oil',
            type = 'success'
        })
    end
end
