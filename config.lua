--[[ 
 ███████████ █████       █████ █████       ███████    █████ █████      
░░███░░░░░░█░░███       ░░███ ░░███      ███░░░░░███ ░░███ ░░███       
 ░███   █ ░  ░███        ░███  ░███     ███     ░░███ ░███  ░███       
 ░███████    ░███        ░███  ░███    ░███      ░███ ░███  ░███       
 ░███░░░█    ░███        ░███  ░███    ░███      ░███ ░███  ░███       
 ░███  ░     ░███  ███   ░███  ░███    ░░███     ███  ░███  ░███      █
 █████       █████░░████████   █████    ░░░███████░   █████ ███████████
░░░░░       ░░░░░  ░░░░░░░░   ░░░░░       ░░░░░░░    ░░░░░ ░░░░░░░░░░░ 
                        VERSION 1.0
                        ----------
            https://github.com/Zotters/fiji-oil/
                        ----------
                       CONFIGURATION
]] 

Config = {}

-- [[ DEBUG ]] --
Config.Debug = false

-- [[ BASIC CONFIGURATIONS ]] -- 
Config.OilCompany = '[LOS SANTOS OIL COMPANY]' 
Config.ValveIcon = 'fa-solid fa-faucet'
Config.ValveOpening = 10000 -- Time in ms to open valve
Config.ValveClosing = 5 -- Time in minutes before valve closes
Config.CollectionIcon = 'fa-solid fa-fill-drip'

-- [[ REFINE SETTINGS ]] -- 
Config.Hopper = vector3(228.76, -2978.77, 7.45)
Config.Distill = vector3(281.28, -2941.22, 5.45)
Config.Extraction = vector3(313.09, -2873.43, 6.01)

Config.HopperTime = 3500 -- Time in ms per unit loaded
Config.HopperFill = 10 -- Maximum units in hopper
Config.RefineryTypes = {
    crude_light = {
        name = "crude_light",
        label = "Light Crude",
        result = "refined_light",
        distillTime = 4000,
        extractionTime = 1500,
        qualityChances = {
            pure = 0.25,
            standard = 0.6,
            dirty = 0.15
        },
        byproducts = {
            plastic_residue = 0.3
        }
    },
    crude_heavy = {
        name = "crude_heavy",
        label = "Heavy Crude",
        result = "refined_heavy",
        distillTime = 5000,
        extractionTime = 2500,
        qualityChances = {
            pure = 0.15,
            standard = 0.65,
            dirty = 0.2
        },
        byproducts = {
            sulfur_chunk = 0.4
        }
    }
}

Config.RefineryPanel = {
    position = "top-middle", 
    cancelKey = 202 -- ESC
}

-- [[ OIL TYPES ]] --
Config.OilTypes = {
    { name = "crude_light", label = "Light Crude" },
    { name = "crude_heavy", label = "Heavy Crude" }
}

-- [[ PACKAGING SETTINGS ]] --
Config.PackagingLocations = {
    {
        coords = vector3(260.45, -2955.65, 5.8),
        label = "Oil Packaging"
    }
}

Config.PackagingRequirements = {
    items = {
        {
            refined_light_pure = 5,
            empty_drum = 1,
            result = "packaged_light_pure",
            time = 8000
        },
        {
            refined_light_standard = 5,
            empty_drum = 1,
            result = "packaged_light_standard",
            time = 7000
        },
        {
            refined_light_dirty = 5,
            empty_drum = 1,
            result = "packaged_light_dirty",
            time = 6000
        },
        {
            refined_heavy_pure = 5,
            empty_drum = 1,
            result = "packaged_heavy_pure",
            time = 10000
        },
        {
            refined_heavy_standard = 5,
            empty_drum = 1,
            result = "packaged_heavy_standard",
            time = 9000
        },
        {
            refined_heavy_dirty = 5,
            empty_drum = 1,
            result = "packaged_heavy_dirty",
            time = 8000
        }
    }
}

-- [[ DELIVERY SETTINGS ]] --
Config.DeliveryStartLocations = {
    {
        coords = vector3(292.12, -2981.25, 5.9),
        label = "Oil Delivery Office"
    }
}

Config.DeliveryLocations = {
    {
        coords = vector3(1734.8, -1647.87, 112.59),
        label = "Paleto Bay Refinery",
        distance = 7.5, -- Distance factor for time calculation
        rewards = {
            packaged_light_pure = 1200,
            packaged_light_standard = 900,
            packaged_light_dirty = 600,
            packaged_heavy_pure = 1500,
            packaged_heavy_standard = 1200,
            packaged_heavy_dirty = 800
        }
    },
    {
        coords = vector3(2772.85, 1391.78, 24.53),
        label = "Sandy Shores Depot",
        distance = 5.0, -- Distance factor for time calculation
        rewards = {
            packaged_light_pure = 1100,
            packaged_light_standard = 850,
            packaged_light_dirty = 550,
            packaged_heavy_pure = 1400,
            packaged_heavy_standard = 1100,
            packaged_heavy_dirty = 750
        }
    },
    {
        coords = vector3(-2043.64, 3175.96, 32.81),
        label = "Humane Labs",
        distance = 6.0, -- Distance factor for time calculation
        rewards = {
            packaged_light_pure = 1300,
            packaged_light_standard = 950,
            packaged_light_dirty = 650,
            packaged_heavy_pure = 1600,
            packaged_heavy_standard = 1300,
            packaged_heavy_dirty = 850
        }
    }
}

Config.DeliveryVehicle = {
    model = "mule",
    spawnLocation = vector4(301.45, -2994.12, 5.4, 90.0)
}

Config.DeliveryBaseTime = 300 -- 5 Minutes in Seconds (There is a variation adder based on distance from delivery point 6.0 x 300 = 1800 Seconds = 30 Minutes(Could be overkill but you are driving a mule. Adjust accordingly.))
Config.DeliveryCompletionTime = 10000 -- 10 seconds in ms
Config.TimeBonus = 0.5 -- 50% bonus for completing with full time remaining

--[[ ZONES/BLIPS ]] -- 
Config.OilPumpBlip = {
    label = "Oil Pumps",
    coords = vector3(233.55, -2111.56, 16.32),
    icon = 643,
    scale = 0.8,
    color = 21
}

Config.RefineryBlip = {
    label = "Refinery",
    coords = vector3(276.23, -2932.94, 5.69),
    icon = 436,
    scale = 0.8,
    color = 21
}

Config.PackagingBlip = {
    label = "Oil Packaging",
    coords = vector3(260.45, -2955.65, 5.8),
    icon = 478,
    scale = 0.8,
    color = 21
}

Config.DeliveryBlip = {
    label = "Oil Delivery Office",
    coords = vector3(292.12, -2981.25, 5.9),
    icon = 477,
    scale = 0.8,
    color = 21
}

Config.OilCollectionBlip = {
    icon = 415,
    scale = 0.8,
    color = 5
}

Config.DeliveryDestinationBlip = {
    icon = 38,
    scale = 0.8,
    color = 5
}

Config.OilPumps = { -- These are zones for the pumps.
    vector3(245.5, -2208.0, 8.0),
    vector3(242.0, -2164.5, 12.0),
    vector3(295.0, -2189.0, 10.0),
    vector3(304.0, -2218.0, 7.0)
}

Config.PumpValves = { -- These are target areas for the valves at the pumps.
   [1] = vector3(242.0, -2207.75, 8.25),
   [2] = vector3(303.53, -2214.4, 7.63),
   [3] = vector3(293.24, -2185.5, 10.34),
   [4] = vector3(243.43, -2168.01, 11.91)
}

Config.CollectionZones = { -- These are areas where once the valve has been opened at pumps players can exchange empty oil buckets for full buckets.
    [1] = vector3(-40.5, -2243.5, 8.0),
    [2] = vector3(467.33, -2767.35, 6.22)
}

-- Item labels for UI display
Config.ItemLabels = {
    -- Crude oil
    crude_light = "Light Crude Oil",
    crude_heavy = "Heavy Crude Oil",
    
    -- Refined oil
    refined_light_pure = "Pure Light Refined Oil",
    refined_light_standard = "Standard Light Refined Oil",
    refined_light_dirty = "Dirty Light Refined Oil",
    refined_heavy_pure = "Pure Heavy Refined Oil",
    refined_heavy_standard = "Standard Heavy Refined Oil",
    refined_heavy_dirty = "Dirty Heavy Refined Oil",
    
    -- Packaged oil
    packaged_light_pure = "Packaged Pure Light Oil",
    packaged_light_standard = "Packaged Standard Light Oil",
    packaged_light_dirty = "Packaged Dirty Light Oil",
    packaged_heavy_pure = "Packaged Pure Heavy Oil",
    packaged_heavy_standard = "Packaged Standard Heavy Oil",
    packaged_heavy_dirty = "Packaged Dirty Heavy Oil",
    
    -- Other items
    empty_oil = "Empty Oil Container",
    empty_drum = "Empty Oil Drum",
    plastic_residue = "Plastic Residue",
    sulfur_chunk = "Sulfur Chunk"
}
