local nextPackageAt = {}

local function FindRecipe(inputItem)
    for _, recipe in ipairs(Config.PackagingRecipes) do
        if recipe.input == inputItem then return recipe end
    end
    return nil
end

-- ox_target/proximity zones are UX filters only - re-validate distance server-side.
local function IsNearStation(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    return #(GetEntityCoords(ped) - coords) <= maxDist
end

-- Blocks a client from spamming this event far faster than the progress bar
-- it's supposed to sit behind.
local function PassesRateLimit(source)
    local now = GetGameTimer()
    if (nextPackageAt[source] or 0) > now then
        return false
    end
    nextPackageAt[source] = now + math.floor((Config.PackagingTime or 3000) * 0.6)
    return true
end

Callback.Register('fiji-oil:packaging:getRefinedOil', function(source)
    local oilData = {}

    for _, recipe in ipairs(Config.PackagingRecipes) do
        local hasOil, oilCount = Fiji.HasItem(source, recipe.input)
        if hasOil and oilCount > 0 then
            table.insert(oilData, { name = recipe.input, label = Fiji.GetItemLabel(recipe.input), count = oilCount })
        end
    end

    return oilData
end)

Callback.Register('fiji-oil:packaging:getEmptyDrums', function(source)
    local _, count = Fiji.HasItem(source, 'empty_drum')
    return count or 0
end)

RegisterNetEvent('fiji-oil:server:packageOil', function(oilType)
    local source = source

    local recipe = FindRecipe(oilType)
    if not recipe then
        Fiji.Notify(source, "Invalid oil type", "error")
        return
    end

    if not IsNearStation(source, Config.PackagingLocation.coords, 5.0) then
        return
    end

    if not PassesRateLimit(source) then
        return
    end

    local hasOil, oilCount = Fiji.HasItem(source, oilType)
    if not hasOil or oilCount < 1 then
        Fiji.Notify(source, "You don't have any " .. Fiji.GetItemLabel(oilType), "error")
        return
    end

    local hasDrums, drumCount = Fiji.HasItem(source, 'empty_drum')
    if not hasDrums or drumCount < recipe.drum then
        Fiji.Notify(source, "You don't have enough empty drums", "error")
        return
    end

    if Fiji.RemoveItem(source, oilType, 1) and Fiji.RemoveItem(source, 'empty_drum', recipe.drum) then
        if Fiji.AddItem(source, recipe.result, 1) then
            Fiji.Notify(source, "Successfully packaged " .. Fiji.GetItemLabel(oilType), "success")
        else
            Fiji.AddItem(source, oilType, 1)
            Fiji.AddItem(source, 'empty_drum', recipe.drum)
            Fiji.Notify(source, "Failed to package oil - inventory full", "error")
        end
    else
        Fiji.Notify(source, "Failed to remove items from inventory", "error")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    nextPackageAt[source] = nil
end)
