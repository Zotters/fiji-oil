-- [[ Oil Pump Zones (Functionality for Multiple Zones) ]] --

CreateThread(function()
    for _, coords in pairs(Config.OilPumps) do
        setupOilPumps(coords)
    end
end)

function setupOilPumps(coords)
    local zone = lib.zones.box({
        coords = vec3(coords.x, coords.y, coords.z),
        size = vec3(11.0, 15.5, 21.0),
        rotation = coords.w,
        debug = false,
        onEnter = onEnter,
        onExit = onExit,
    })
end

exports.ox_target:addBoxZone({
    name = "RefineryStation",
    coords = Config.Refine,
    size = vec3(1.5, 1.5, 2.0),
    rotation = 0.0,
    debug = false,
    options = {
        {
            label = "Refine Oil",
            icon = "fa-solid fa-fire-burner",
            event = "ZOTTERS-REFINERY:StartRefine"
        }
    }
})

exports.ox_target:addBoxZone({
    name = "DrumLoader",
    coords = Config.DrumFill,
    size = vec3(1.2, 1.2, 2.0),
    rotation = 0,
    debug = false,
    options = {
        {
            label = "Load Oil Drum",
            icon = "fa-solid fa-barrel",
            event = "ZOTTERS-DRUM:StartLoad"
        }
    }
})

exports.ox_target:addBoxZone({
    name = "DrumSales",
    coords = Config.SellDrum, -- your sale location
    size = vec3(1.5, 1.5, 2.0),
    rotation = 0,
    debug = false,
    options = {
        {
            label = "Sell Oil Drum",
            icon = "fa-solid fa-oil-can",
            serverEvent = "ZOTTERS-DRUM:SellDrum"
        }
    }
})

