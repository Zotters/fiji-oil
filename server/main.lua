local Fiji = require 'bridge'
local isInitialized = false

function Initialize()
    if isInitialized then return end
    
    if not Fiji.Init() then
        return false
    end
    
    RegisterCallbacks()
    
    isInitialized = true
    
    return true
end

function RegisterCallbacks()
    lib.callback.register('fiji-oil:server:getEmptyContainers', function(source)
        local hasItem, count = Fiji.HasItem(source, "empty_oil")
        return count or 0
    end)
    
    lib.callback.register('fiji-oil:server:getAvailableOil', function(source)
        local availableOil = {}
        
        for _, oilType in ipairs(Config.OilTypes) do
            local hasItem, itemCount = Fiji.HasItem(source, oilType.name)
            
            if hasItem and itemCount > 0 then
                table.insert(availableOil, {
                    name = oilType.name,
                    label = oilType.label,
                    count = itemCount
                })
            end
        end
        
        return availableOil
    end)
    
    lib.callback.register('fiji-oil:server:getAvailableRefinedOil', function(source)
        local refinedOil = {}
        
        for _, oilConfig in pairs(Config.RefineryTypes) do
            local qualities = {"pure", "standard", "dirty"}
            
            for _, quality in ipairs(qualities) do
                local refinedName = oilConfig.result .. "_" .. quality
                local hasItem, itemCount = Fiji.HasItem(source, refinedName)
                
                if hasItem and itemCount > 0 then
                    table.insert(refinedOil, {
                        name = refinedName,
                        label = Fiji.GetItemLabel(refinedName),
                        count = itemCount
                    })
                end
            end
        end
        
        return refinedOil
    end)
    
    lib.callback.register('fiji-oil:server:getAvailablePackagedOil', function(source)
        local packagedOil = {}
        
        for _, recipe in ipairs(Config.PackagingRequirements.items) do
            if recipe.result then
                local hasItem, itemCount = Fiji.HasItem(source, recipe.result)
                
                if hasItem and itemCount > 0 then
                    table.insert(packagedOil, {
                        name = recipe.result,
                        label = Fiji.GetItemLabel(recipe.result),
                        count = itemCount
                    })
                end
            end
        end
        
        return packagedOil
    end)
end

CreateThread(function()
    Wait(1000)
    
    if not Initialize() then
    end
end)
