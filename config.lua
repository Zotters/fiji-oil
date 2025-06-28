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
Config.ValveIcon = 'arrow-spin'
Config.ValveOpening = 10000 -- Time it takes to open the valve
Config.ValveClosing = 600000 -- 10 Minutes allowed for collection
Config.CollectionIcon = 'caret-right'

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
    --[2] = vector3(241.9, -2206.65, 8.0)
 }
