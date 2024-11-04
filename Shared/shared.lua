local Config = {}
-- "en" or "it" or "fr" or "de" or add Custom in (Shared.locales.lua)
Config.Locales = "en"

-- "utility" or "ox_lib" or add custom Notification in (client.cl-utils.lua)
Config.ProviderNotification = "utility"

-- Start Forced With command /initsteal
Config.AllowedGroups = {
    admin = true,
    mod = true,
    user = true,
}

Config.StealedItem = {
    [0] = {  -- Compacts
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3, ProbabilityDrop = 0.5 }, -- 50% chance
        }
    },
    [1] = { -- Sedans
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 5, ProbabilityDrop = 0.75 }, -- 75% chance
        }
    },
    [2] = { -- SUVs
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 4, ProbabilityDrop = 0.6 }
        }
    },
    [3] = { -- Coupes
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3, ProbabilityDrop = 0.4 }
        }
    },
    [4] = { -- Muscle
        RandomItems = {
            { ItemName = "burger", QuantityMin = 1, QuantityMax = 2, ProbabilityDrop = 0.3 },
        }
    },
    [5] = { -- Sports Classics
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3, ProbabilityDrop = 0.5 },
        }
    },
    [6] = { -- Sports
        RandomItems = {
            { ItemName = "water",  QuantityMin = 1, QuantityMax = 4, ProbabilityDrop = 0.6 },
            { ItemName = "burger", QuantityMin = 1, QuantityMax = 4, ProbabilityDrop = 0.6 },
        }
    },
    [7] = {                                                                                 -- Super
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 1, ProbabilityDrop = 0.1 } -- 10% chance
        }
    },
}


return Config
