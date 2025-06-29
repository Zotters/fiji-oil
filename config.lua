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

-- [[ BASIC CONFIGURATIONS ]] -- 
Config.OilCompany = 'Zotters Oil' -- Notification Setting
Config.ValveIcon = 'fa-solid fa-arrow-spin'
Config.ValveOpening = 10000 -- Time it takes to open the valve
Config.ValveClosing = 5 -- In minutes
Config.CollectionIcon = 'fa-solid fa-caret-right'

-- [[ LOCATIONS ]] -- 
Config.Refine = vec3(1050.49, -1957.07, 31.04)
Config.DrumFill = vec3(1061.24, -1998.17, 31.02)
Config.SellDrum = vec3(1082.82, -1949.72, 31.01)

-- [[ OIL TYPES ]] --
Config.OilTypes = {
    "Light Crude",
    "Heavy Crude"
}
Config.RefineTimes = {
    ["full_oil_light"] = 5000, -- Seconds
    ["full_oil_heavy"] = 9000, -- Seconds
}

Config.DrumFillRequirements = {
    ["refined_heavy"] = { required = 3, output = "oil_drum_heavy", label = "Drum of Heavy Crude", filltime = 12000 },
    ["refined_light"] = { required = 5, output = "oil_drum_light", label = "Drum of Light Crude", filltime = 8000 }
}

-- [[ OIL PAYOUTS ]] -- 
Config.DrumSalePrices = {
    ["oil_drum_heavy"] = 4000,
    ["oil_drum_light"] = 1200,
    ["Default"] = 500 -- Fail safe
}

--[[ ZONES ]] -- 
Config.OilPumps = { -- These are zones for the pumps.
    vector3(245.5, -2208.0, 8.0),
    vector3(242.0, -2164.5, 12.0)
}

Config.PumpValves = { -- These are target areas for the valves at the pumps.
   [1] = vector3(242.0, -2207.75, 8.25),
   --[2] = vector3(241.9, -2206.65, 8.0)
}

Config.CollectionZones = { -- These are areas where once the valve has been opened at pumps players can exchange empty oil buckets for full buckets.
    [1] = vector3(-40.5, -2243.5, 8.0),
    [2] = vector3(467.33, -2767.35, 6.22)
 }