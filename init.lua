if not lib then error("Missing ox_ib") return end 

local MINIMUM_LGF_VERSION <const> = "1.0.7"

LGF = exports.LGF_Utility:UtilityData()

local requested, errorMessage = LGF:GetDependency("LGF_Utility", MINIMUM_LGF_VERSION)

if not requested then print(errorMessage) return end

