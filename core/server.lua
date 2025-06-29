RegisterNetEvent('zotters-oilcontainer', function(oilType) 
    itemCheck(oilType)
end)

function itemCheck(oilType)
    local src = source -- <- This line is the key
    local hasItem = exports.ox_inventory:GetItemCount(src, "empty_oil")
    if hasItem > 0 then
        local fullItem = "full_oil"

        if oilType == "Heavy Crude" then
            fullItem = "full_oil_heavy"
        elseif oilType == "Light Crude" then
            fullItem = "full_oil_light"
        end

        local canCarry = exports.ox_inventory:CanCarryItem(src, fullItem, 1)
        if canCarry then
            exports.ox_inventory:RemoveItem(src, 'empty_oil', 1)
            exports.ox_inventory:AddItem(src, fullItem, 1)
        else
            TriggerClientEvent('ZOTTERS-FULLINVENTORY', src)
        end
    else
        TriggerClientEvent('ZOTTERS-MISSINGITEM', src)
    end
end

RegisterNetEvent("ZOTTERS-REFINERY:RefineOil", function()
    local src = source
    local refinedCount = 0

    while true do
        local items = exports.ox_inventory:GetInventoryItems(src)
        local oilItem = nil

        for _, item in pairs(items) do
            if item.name:match("^full_oil") then
                oilItem = item
                break
            end
        end

        if not oilItem then break end -- no more oil to refine

        local result = "refined_oil"
        local refineTime = Config.RefineTimes[oilItem.name] or 3000
        local oilLabel = oilItem.label or "crude oil"

        if oilItem.name == "full_oil_heavy" then
            result = "refined_heavy"
            oilLabel = "Heavy Crude"
        elseif oilItem.name == "full_oil_light" then
            result = "refined_light"
            oilLabel = "Light Crude"
        end

        TriggerClientEvent("ZOTTERS-REFINERY:ShowRefineProgress", src, refineTime, oilLabel)
        Wait(refineTime)

        exports.ox_inventory:RemoveItem(src, oilItem.name, 1)
        exports.ox_inventory:AddItem(src, result, 1)
        refinedCount += 1
    end

    if refinedCount == 0 then
        TriggerClientEvent("ZOTTERS-MISSINGITEM", src)
    end
end)


RegisterNetEvent("ZOTTERS-DRUM:LoadOilToDrum", function()
    local src = source
    local inv = exports.ox_inventory:GetInventoryItems(src)
    local hasDrum = exports.ox_inventory:GetItemCount(src, "empty_drum") or 0

    if hasDrum < 1 then
        TriggerClientEvent("ZOTTERS-MISSINGITEM", src)
        return
    end

    for oilName, data in pairs(Config.DrumFillRequirements) do
        local qty = exports.ox_inventory:GetItemCount(src, oilName)
        if qty >= data.required then
            if not exports.ox_inventory:CanCarryItem(src, data.output, 1) then
                TriggerClientEvent("ZOTTERS-FULLINVENTORY", src)
                return
            end
            TriggerClientEvent("ZOTTERS-DRUM:ShowDrumFilling", src, data.fillTime or 5000, data.label)
            Wait(data.fillTime or 5000)
            -- Process transaction
            exports.ox_inventory:RemoveItem(src, oilName, data.required)
            exports.ox_inventory:RemoveItem(src, "empty_drum", 1)
            exports.ox_inventory:AddItem(src, data.output, 1)

            return
        end
    end

    TriggerClientEvent("ZOTTERS-MISSINGITEM", src)
end)

RegisterNetEvent("ZOTTERS-DRUM:SellDrum", function()
    local src = source
    local inv = exports.ox_inventory:GetInventoryItems(src)

    for _, item in pairs(inv) do
        if Config.DrumSalePrices[item.name] then
            local payout = Config.DrumSalePrices[item.name]
            exports.ox_inventory:RemoveItem(src, item.name, 1)
            exports.ox_inventory:AddItem(src, "cash", payout)

            TriggerClientEvent("ox_lib:notify", src, {
                title = "Drum Sold",
                description = "You sold a " .. (item.label or item.name) .. " for $" .. payout,
                type = "success"
            })
            return
        end
    end

    TriggerClientEvent("ZOTTERS-MISSINGITEM", src)
end)