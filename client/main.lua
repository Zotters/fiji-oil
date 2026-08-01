-- Blips for every fixed location in the production chain. Physical
-- interaction points (kiosk, drops, desks, rigs, marina, refinery,
-- packaging) are registered by their own feature files.

local function AddSimpleBlip(coords, blipConfig, label)
    if not coords or not blipConfig then return end

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipConfig.icon or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale or 0.8)
    SetBlipColour(blip, blipConfig.color or 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

CreateThread(function()
    Wait(500)

    for _, hqId in ipairs(Config.CompanyOrder) do
        local hq = Config.HQs[hqId]
        if hq then
            AddSimpleBlip(hq.coords, hq.blip, hq.label)
        end
    end

    for _, rig in ipairs(Config.OffshoreRigs) do
        AddSimpleBlip(rig.coords, rig.blip, rig.label)
    end

    AddSimpleBlip(Config.Marina.coords, Config.Marina.blip, Config.Marina.label)
    AddSimpleBlip(Config.Refinery and Config.Hopper, Config.Refinery and Config.Refinery.blip, Config.Refinery and Config.Refinery.label or 'Refinery')
    AddSimpleBlip(Config.PackagingLocation.coords, Config.PackagingLocation.blip, Config.PackagingLocation.label)
end)
