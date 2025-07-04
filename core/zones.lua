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
        distance = 2,
        debug = false,
        onEnter = onEnter,
        onExit = onExit,
    })
end

-- [[ REFINE ]] --
exports.ox_target:addBoxZone({
    name = "HOPPER",
    coords = Config.Hopper,
    distance = 2,
    size = vec3(3, 3, 3),
    debug = true,
    options = {
        {
            icon = "fa-solid fa-temperature-high",
            label = "Load Hopper",
            serverEvent = "ZOTTERS-REFINERY:StartRefine"
        }
    }
})

exports.ox_target:addBoxZone({
    name = "DISTILL",
    coords = Config.Distill,
    distance = 2,
    size = vec3(3, 3, 3),
    debug = true,
    options = {
        {
            icon = "fa-solid fa-temperature-high",
            label = "Begin Distillation",
            serverEvent = "ZOTTERS-REFINERY:StartDistillation"
        }
    }
})

exports.ox_target:addBoxZone({
    name = "EXTRACTION",
    coords = Config.Extraction,
    distance = 2,
    size = vec3(3, 3, 3),
    debug = true,
    options = {
        {
            icon = "fa-solid fa-flask",
            label = "Extract Refined Oil",
            serverEvent = "ZOTTERS-REFINERY:StartExtraction"
        }
    }
})

