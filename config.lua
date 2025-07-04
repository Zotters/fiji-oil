--[[ 
 ███████████ █████       █████ █████       ███████    █████ █████      
░░███░░░░░░█░░███       ░░███ ░░███      ███░░░░░███ ░░███ ░░███       
 ░███   █ ░  ░███        ░███  ░███     ███     ░░███ ░███  ░███       
 ░███████    ░███        ░███  ░███    ░███      ░███ ░███  ░███       
 ░███░░░█    ░███        ░███  ░███    ░███      ░███ ░███  ░███       
 ░███  ░     ░███  ███   ░███  ░███    ░░███     ███  ░███  ░███      █
 █████       █████░░████████   █████    ░░░███████░   █████ ███████████
░░░░░       ░░░░░  ░░░░░░░░   ░░░░░       ░░░░░░░    ░░░░░ ░░░░░░░░░░░ 
                        VERSION 0.5
                        ----------
            https://github.com/Zotters/fiji-oil/
                        ----------
                       CONFIGURATION
]] 

Config = {}

-- [[ DEBUG ]] --
Config.Debug = true

-- [[ BASIC CONFIGURATIONS ]] -- 
Config.OilCompany = '[LOS SANTOS OIL COMPANY]' 
Config.ValveIcon = 'fa-solid fa-arrow-spin'
Config.ValveOpening = 10000 
Config.ValveClosing = 3 -- In minutes
Config.CollectionIcon = 'fa-solid fa-caret-right'

-- [[ REFINE SETTINGS ]] -- 
Config.Hopper = vec3(228.76, -2978.77, 7.45)
Config.Distill = vec3(281.28, -2941.22, 5.45)
Config.Extraction = vec3(313.09, -2873.43, 6.01)

Config.HopperTime = 3500
Config.HopperFill = 10
Config.RefineryTypes = {
    crude_light = {
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
    cancelKey = 202      -- ESC
}

-- [[ OIL TYPES ]] --
Config.OilTypes = {
    { name = "crude_light", label = "Light Crude" },
    { name = "crude_heavy", label = "Heavy Crude" }
}


--[[ ZONES/BLIPS ]] -- 
Config.OilPumpBlip = {
    label = "Oil Pumps",
    coords = vec3(233.55, -2111.56, 16.32),
    icon = 643,
    scale = 0.8,
    color = 21
}

Config.RefineryBlip = {
    label = "Refinery",
    coords = vec3(276.23, -2932.94, 5.69),
    icon = 436,
    scale = 0.8,
    color = 21
}

Config.OilCollectionBlip = {
    icon = 415,
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


 --[[ VARIABLES ]]--

 --[[ PANEL SETTINGS ]]--

 --[[
Top Left	top-left
Top Middle	top-middle
Top Right	top-right
Bottom Left	bottom-left
Bottom Middle	bottom-middle
Bottom Right	bottom-right
Left Middle	left-middle
Right Middle	right-middle]]--