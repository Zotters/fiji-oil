--[[
 ███████████ █████       █████ █████       ███████    █████ █████
░░███░░░░░░█░░███       ░░███ ░░███      ███░░░░░███ ░░███ ░░███
 ░███   █ ░  ░███        ░███  ░███     ███     ░░███ ░███  ░███
 ░███████    ░███        ░███  ░███    ░███      ░███ ░███  ░███
 ░███░░░█    ░███        ░███  ░███    ░███      ░███ ░███  ░███
 ░███  ░     ░███  ███   ░███  ░███    ░░███     ███  ░███  ░███      █
 █████       █████░░████████   █████    ░░░███████░   █████ ███████████
░░░░░       ░░░░░  ░░░░░░░░   ░░░░░       ░░░░░░░    ░░░░░ ░░░░░░░░░░░
                        VERSION 2.0.0
                        ----------
            https://github.com/Zotters/fiji-oil/
                        ----------
                       CONFIGURATION

  All coordinates below are PLACEHOLDER / EXAMPLE locations (Elysian Island /
  Terminal area + open ocean south of Los Santos). Retune them to fit your
  map and other resources before going live!!
]]

Config = {}

-- ============================================================
-- GENERAL
-- ============================================================
Config.Debug = false
Config.OilCompany = '[GLOBE OIL]'          -- fallback notify title when no company context applies
Config.UseTarget = true                     -- false = proximity + text-hint interactions everywhere
Config.InteractionDistance = 2.0
Config.MaxReputation = 100
Config.UnlockThreshold = 25                 -- % reputation with Globe Oil that unlocks the other 3 companies
Config.MaxActiveContractsPerCompany = 2

-- ============================================================
-- TERMINAL / COMPANY HQs
-- ============================================================
Config.TerminalItem = 'globe_oil_terminal'

Config.HQs = {
    globe_oil = {
        label = 'Globe Oil HQ',
        coords = vector3(276.0, -2935.0, 5.7),
        terminalKiosk = vector3(285.19, -2945.16, 5.54),   -- one-time terminal pickup
        supplyDropoff = vector3(282.4, -2938.2, 5.7),   -- collect finished supply orders here
        tradeDesk = vector3(266.8, -2930.5, 5.7),       -- sell packaged oil / manage contracts in person
        blip = { icon = 410, color = 3, scale = 0.9 },
    },
    kraken = {
        label = 'Kraken Deepwater',
        coords = vector3(-88.0, -2650.0, 6.0),
        supplyDropoff = vector3(-92.5, -2646.0, 6.0),
        tradeDesk = vector3(-84.0, -2655.0, 6.0),
        blip = { icon = 356, color = 27, scale = 0.9 },
    },
    meridian = {
        label = 'Meridian Refineries',
        coords = vector3(1734.8, -1647.87, 112.59),
        supplyDropoff = vector3(1740.0, -1652.0, 112.59),
        tradeDesk = vector3(1729.0, -1643.0, 112.59),
        blip = { icon = 436, color = 5, scale = 0.9 },
    },
    blackgold = {
        label = 'Blackgold Traders',
        coords = vector3(-1607.6, -3011.0, 5.9),
        supplyDropoff = vector3(-1602.0, -3006.0, 5.9),
        tradeDesk = vector3(-1613.0, -3016.0, 5.9),
        blip = { icon = 442, color = 1, scale = 0.9 },
    },
}

-- Stable iteration order for UI (pairs() order over Config.Companies isn't guaranteed)
Config.CompanyOrder = { 'globe_oil', 'kraken', 'meridian', 'blackgold' }

-- ============================================================
-- COMPANIES (catalog, contracts, perk tiers, sell prices)
-- ============================================================
Config.Companies = {
    globe_oil = {
        id = 'globe_oil',
        label = 'Globe Oil',
        description = 'The neutral parent company. Every operator starts here.',
        alwaysUnlocked = true,
        perkType = nil,
        perkTiers = {},
        reputationPerSale = 1,
        catalog = {
            { item = 'oil_bucket',  label = 'Oil Bucket',  price = 35,  deliverySeconds = 300 },
            { item = 'drill_part',  label = 'Drill Part',  price = 250, deliverySeconds = 900 },
            { item = 'empty_drum',  label = 'Empty Drum',  price = 60,  deliverySeconds = 300 },
        },
        sellPrices = {
            packaged_light_pure = 260,     packaged_light_standard = 190,     packaged_light_dirty = 120,
            packaged_heavy_pure = 340,     packaged_heavy_standard = 250,     packaged_heavy_dirty = 160,
        },
        contracts = {
            {
                id = 'globe_intro_supply',
                title = 'Introductory Supply Run',
                description = 'Deliver standard-grade light oil to prove you can run a route.',
                item = 'packaged_light_standard', quantity = 5,
                rewardCash = 1400, rewardReputation = 10, riskTier = 'low',
            },
            {
                id = 'globe_heavy_batch',
                title = 'Heavy Batch Order',
                description = 'Globe Oil needs a bulk shipment of standard heavy oil.',
                item = 'packaged_heavy_standard', quantity = 8,
                rewardCash = 2600, rewardReputation = 14, riskTier = 'medium',
            },
            {
                id = 'globe_pure_reserve',
                title = 'Pure Reserve Stockpile',
                description = 'High-grade reserve stock. Pure oil only.',
                item = 'packaged_light_pure', quantity = 6,
                rewardCash = 3200, rewardReputation = 18, riskTier = 'high',
            },
        },
    },

    kraken = {
        id = 'kraken',
        label = 'Kraken Deepwater',
        description = 'Offshore drilling specialists. Rewards operators who spend their hours on the rigs.',
        alwaysUnlocked = false,
        perkType = 'drilling',
        perkTiers = {
            { threshold = 25,  drillTimeMultiplier = 0.90, bonusCrudeChance = 0.00 },
            { threshold = 60,  drillTimeMultiplier = 0.80, bonusCrudeChance = 0.10 },
            { threshold = 100, drillTimeMultiplier = 0.70, bonusCrudeChance = 0.20 },
        },
        reputationPerSale = 1,
        catalog = {
            { item = 'oil_bucket', label = 'Reinforced Oil Bucket', price = 40,  deliverySeconds = 240 },
            { item = 'drill_part', label = 'Heavy-Duty Drill Part', price = 300, deliverySeconds = 720 },
        },
        sellPrices = {
            packaged_light_pure = 250,     packaged_light_standard = 185,     packaged_light_dirty = 115,
            packaged_heavy_pure = 335,     packaged_heavy_standard = 245,     packaged_heavy_dirty = 155,
        },
        contracts = {
            {
                id = 'kraken_rig_quota',
                title = 'Rig Quota',
                description = 'Kraken wants proof your rig time pays off.',
                item = 'packaged_heavy_pure', quantity = 6,
                rewardCash = 3400, rewardReputation = 16, riskTier = 'medium',
            },
            {
                id = 'kraken_deep_run',
                title = 'Deepwater Run',
                description = 'A demanding order for their highest-margin buyers.',
                item = 'packaged_heavy_standard', quantity = 10,
                rewardCash = 4200, rewardReputation = 20, riskTier = 'high',
            },
        },
    },

    meridian = {
        id = 'meridian',
        label = 'Meridian Refineries',
        description = 'Refining specialists. They pay well for consistency and quality.',
        alwaysUnlocked = false,
        perkType = 'refining',
        perkTiers = {
            { threshold = 25,  refineTimeMultiplier = 0.90, pureChanceBonus = 0.00 },
            { threshold = 60,  refineTimeMultiplier = 0.80, pureChanceBonus = 0.10 },
            { threshold = 100, refineTimeMultiplier = 0.70, pureChanceBonus = 0.20 },
        },
        reputationPerSale = 1,
        catalog = {
            { item = 'empty_drum', label = 'Reinforced Drum', price = 70, deliverySeconds = 240 },
        },
        sellPrices = {
            packaged_light_pure = 285,     packaged_light_standard = 200,     packaged_light_dirty = 125,
            packaged_heavy_pure = 365,     packaged_heavy_standard = 260,     packaged_heavy_dirty = 165,
        },
        contracts = {
            {
                id = 'meridian_quality_control',
                title = 'Quality Control Batch',
                description = 'Only pure-grade product meets Meridian spec.',
                item = 'packaged_light_pure', quantity = 5,
                rewardCash = 2800, rewardReputation = 15, riskTier = 'medium',
            },
            {
                id = 'meridian_flagship',
                title = 'Flagship Order',
                description = 'Their biggest recurring client wants pure heavy oil, in bulk.',
                item = 'packaged_heavy_pure', quantity = 8,
                rewardCash = 4600, rewardReputation = 22, riskTier = 'high',
            },
        },
    },

    blackgold = {
        id = 'blackgold',
        label = 'Blackgold Traders',
        description = 'Commerce specialists. No questions, better prices.',
        alwaysUnlocked = false,
        perkType = 'commerce',
        perkTiers = {
            { threshold = 25,  sellPriceMultiplier = 1.10, contractReputationMultiplier = 1.00 },
            { threshold = 60,  sellPriceMultiplier = 1.20, contractReputationMultiplier = 1.10 },
            { threshold = 100, sellPriceMultiplier = 1.30, contractReputationMultiplier = 1.25 },
        },
        reputationPerSale = 1,
        catalog = {
            { item = 'oil_bucket', label = 'Oil Bucket',  price = 30, deliverySeconds = 300 },
            { item = 'empty_drum', label = 'Empty Drum',  price = 55, deliverySeconds = 300 },
        },
        sellPrices = {
            packaged_light_pure = 300,     packaged_light_standard = 220,     packaged_light_dirty = 140,
            packaged_heavy_pure = 390,     packaged_heavy_standard = 280,     packaged_heavy_dirty = 180,
        },
        contracts = {
            {
                id = 'blackgold_quiet_shipment',
                title = 'Quiet Shipment',
                description = 'Move product, no questions asked.',
                item = 'packaged_light_dirty', quantity = 10,
                rewardCash = 2400, rewardReputation = 12, riskTier = 'low',
            },
            {
                id = 'blackgold_premium_buyer',
                title = 'Premium Buyer',
                description = 'A buyer paying well above market - for pure stock only.',
                item = 'packaged_heavy_pure', quantity = 7,
                rewardCash = 4400, rewardReputation = 20, riskTier = 'high',
            },
        },
    },
}

-- ============================================================
-- OFFSHORE DRILLING
-- ============================================================
Config.OffshoreRigs = {
    { label = 'Rig Alpha',   coords = vector3(-1450.0, -3400.0, 0.15), blip = { icon = 68, color = 5, scale = 0.8 } },
    { label = 'Rig Bravo',   coords = vector3(-800.0,  -3550.0, 0.15), blip = { icon = 68, color = 5, scale = 0.8 } },
    { label = 'Rig Charlie', coords = vector3(300.0,   -3600.0, 0.15), blip = { icon = 68, color = 5, scale = 0.8 } },
}

Config.DrillPartMaxUses = 15        -- charges before a drill_part breaks
Config.DrillBaseTime = 4000         -- ms per unit collected, before company perk multiplier
Config.DrillYield = {
    { name = 'crude_light', label = 'Light Crude', weight = 55 },
    { name = 'crude_heavy', label = 'Heavy Crude', weight = 45 },
}

-- ============================================================
-- BOAT RENTAL
-- ============================================================
Config.Marina = {
    label = 'Globe Oil Marina',
    coords = vector3(285.08, -2980.91, 5.54),
    spawnLocation = vector4(327.89, -2970.12, 3.18, 212.53),
    blip = { icon = 356, color = 3, scale = 0.9 },
}

Config.BoatTiers = {
    { id = 'standard', label = 'Standard Skiff', model = 'suntrap', price = 250, rentalMinutes = 30 },
    { id = 'fast',      label = 'Speeder',       model = 'speeder', price = 500, rentalMinutes = 30 },
}

Config.BoatReturnRefundPct = 0.5     -- refund this fraction of the unused-time proportion of the price on early return

-- ============================================================
-- REFINERY
-- ============================================================
Config.Refinery = {
    label = 'Globe Oil Refinery',
    blip = { icon = 436, color = 3, scale = 0.8 },
}

Config.Hopper = vector3(228.76, -2978.77, 7.45)
Config.Distill = vector3(281.28, -2941.22, 5.45)
Config.Extraction = vector3(313.09, -2873.43, 6.01)

Config.HopperTime = 3500      -- ms per unit loaded, before perk multiplier
Config.HopperFill = 10

Config.RefineryTypes = {
    crude_light = {
        name = "crude_light",
        label = "Light Crude",
        result = "refined_light",
        distillTime = 4000,
        extractionTime = 1500,
        qualityChances = { pure = 0.25, standard = 0.60, dirty = 0.15 },
        byproducts = { plastic_residue = 0.3 },
    },
    crude_heavy = {
        name = "crude_heavy",
        label = "Heavy Crude",
        result = "refined_heavy",
        distillTime = 5000,
        extractionTime = 2500,
        qualityChances = { pure = 0.15, standard = 0.65, dirty = 0.20 },
        byproducts = { sulfur_chunk = 0.4 },
    },
}

-- ============================================================
-- PACKAGING
-- ============================================================
Config.PackagingLocation = {
    label = 'Globe Oil Packaging',
    coords = vector3(260.45, -2955.65, 5.8),
    blip = { icon = 478, color = 3, scale = 0.8 },
}

Config.PackagingTime = 3000

Config.PackagingRecipes = {
    { input = 'refined_light_pure',     drum = 1, result = 'packaged_light_pure',     time = 8000 },
    { input = 'refined_light_standard', drum = 1, result = 'packaged_light_standard', time = 7000 },
    { input = 'refined_light_dirty',    drum = 1, result = 'packaged_light_dirty',    time = 6000 },
    { input = 'refined_heavy_pure',     drum = 1, result = 'packaged_heavy_pure',     time = 10000 },
    { input = 'refined_heavy_standard', drum = 1, result = 'packaged_heavy_standard', time = 9000 },
    { input = 'refined_heavy_dirty',    drum = 1, result = 'packaged_heavy_dirty',    time = 8000 },
}

-- ============================================================
-- ITEM LABELS
-- ============================================================
Config.ItemLabels = {
    globe_oil_terminal = "Globe Oil Terminal",

    oil_bucket = "Oil Bucket",
    drill_part = "Drill Part",

    crude_light = "Light Crude Oil",
    crude_heavy = "Heavy Crude Oil",

    refined_light_pure = "Pure Light Refined Oil",
    refined_light_standard = "Standard Light Refined Oil",
    refined_light_dirty = "Dirty Light Refined Oil",
    refined_heavy_pure = "Pure Heavy Refined Oil",
    refined_heavy_standard = "Standard Heavy Refined Oil",
    refined_heavy_dirty = "Dirty Heavy Refined Oil",

    empty_drum = "Empty Oil Drum",
    packaged_light_pure = "Packaged Pure Light Oil",
    packaged_light_standard = "Packaged Standard Light Oil",
    packaged_light_dirty = "Packaged Dirty Light Oil",
    packaged_heavy_pure = "Packaged Pure Heavy Oil",
    packaged_heavy_standard = "Packaged Standard Heavy Oil",
    packaged_heavy_dirty = "Packaged Dirty Heavy Oil",

    plastic_residue = "Plastic Residue",
    sulfur_chunk = "Sulfur Chunk",
}

-- ============================================================
-- UI THEME (mirrored in ui/style.css - kept here too so Lua-side
-- code can pass company accent colors into NUI payloads if needed)
-- ============================================================
Config.Theme = {
    background = '#0b1d2a',
    panel = '#122c3d',
    accent = '#f5a623',
    accentAlt = '#3fa9f5',
    danger = '#e5484d',
    success = '#3ecf8e',
    text = '#e8f1f5',
    muted = '#8ba3b0',
}
