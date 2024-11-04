local Config = {}

Config.Locales = "it"

Config.AllowedGroups = {
    admin = true,
    mod = true,
    user = true,
}

Config.StealedItem = {
    [0] = { -- Compacts
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3 },
        }
    },
    [1] = { -- Sedans
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 5 },
        }
    },
    [2] = { -- SUVs
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 4 }
        }
    },
    [3] = { -- Coupes
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3 }
        }
    },
    [4] = { -- Muscle
        RandomItems = {
            { ItemName = "burger", QuantityMin = 1, QuantityMax = 2 },
        }
    },
    [5] = { -- Sports Classics
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 3 },
        }
    },
    [6] = { -- Sports
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 4 },
        }
    },
    [7] = { -- Super
        RandomItems = {
            { ItemName = "water", QuantityMin = 1, QuantityMax = 1 }
        }
    },
}

return Config
