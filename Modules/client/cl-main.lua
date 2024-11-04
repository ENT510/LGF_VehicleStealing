---@meta

-- [[LOADER FILE]]
local Utils                         = LGF:LuaLoader("Modules/client/cl-utils")
local Config                        = LGF:LuaLoader("Shared/shared")
local Locales                       = LGF:LuaLoader("Shared/locales")
local CurrentLocale                 = Config.Locales

-- [[VARS]]
local MAX_DISTANCE                  = 3.0
local isPlayerLoaded                = false
local stealInitialized              = false
VehicleInteraction                  = {}
VehicleInteraction.__index          = VehicleInteraction

-- [[NATIVES]]
local GetEntityBoneIndexByName      = GetEntityBoneIndexByName
local GetEntityCoords               = GetEntityCoords
local GetVehicleNumberPlateText     = GetVehicleNumberPlateText
local PlayerPedId                   = PlayerPedId
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity
local GetEntityFromStateBagName     = GetEntityFromStateBagName
local DoesEntityExist               = DoesEntityExist
local setmetatable                  = setmetatable
local GetVehicleClass               = GetVehicleClass
local vector3                       = vector3
local TaskTurnPedToFaceEntity       = TaskTurnPedToFaceEntity
local SetVehicleDoorOpen            = SetVehicleDoorOpen
local SetVehicleDoorShut            = SetVehicleDoorShut
local GetCurrentResourceName        = GetCurrentResourceName
local IsVehicleSeatFree             = IsVehicleSeatFree
local GetPedInVehicleSeat           = GetPedInVehicleSeat
local TaskLeaveVehicle              = TaskLeaveVehicle
local Wait                          = Wait
local TaskSmartFleePed              = TaskSmartFleePed
local ClearPedTasks                 = ClearPedTasks

-- [[ANIMATIONS]]
local Animation                     = {
    ["boot"] = { Anim = 'trevor_action', Dict = 'anim@heists@fleeca_bank@scope_out@return_case', },
    ["door"] = { Anim = 'base', Dict = 'anim@mp_player_int_upperdoor', },
}


AddEventHandler("LGF_Utility:PlayerLoaded", function(...)
    isPlayerLoaded = true
    stealInitialized = isPlayerLoaded
    VehicleInteraction:InitializeStealing()
end)

AddEventHandler("LGF_Utility:PlayerUnloaded", function(...)
    isPlayerLoaded = false
    VehicleInteraction:clearInteractions()
end)

function VehicleInteraction:create()
    local obj = setmetatable({}, VehicleInteraction)
    obj.interactionCreated = false
    obj.ID = nil
    obj.currentVehicleNetId = nil
    obj.currentVehiclePlate = nil
    return obj
end

function VehicleInteraction:hasTrunk(vehicle)
    return GetEntityBoneIndexByName(vehicle, "boot") ~= -1
end

function VehicleInteraction:getVehiclePlate(vehicle)
    return GetVehicleNumberPlateText(vehicle)
end

function VehicleInteraction:getBone(isTrunk, vehicle)
    local indexBone, offset

    if isTrunk then
        indexBone = GetEntityBoneIndexByName(vehicle, "boot")
        offset = vector3(0.0, 0.0, 0.0)
        if indexBone == -1 then return nil, nil end
    else
        indexBone = GetEntityBoneIndexByName(vehicle, "door_pside_r")
        offset = vector3(0.0, 0.5, 0.0)
        if indexBone == -1 then
            indexBone = GetEntityBoneIndexByName(vehicle, "door_pside_f")
            if indexBone == -1 then return nil, nil end
        end
    end

    return indexBone, offset
end

function VehicleInteraction:openTrunk(vehicle)
    TaskTurnPedToFaceEntity(LGF.Player:Ped(), vehicle, -1)
    SetVehicleDoorOpen(vehicle, 5, false, false)
end

function VehicleInteraction:closeTrunk(vehicle)
    SetVehicleDoorShut(vehicle, 5, false)
end

function VehicleInteraction:handlePassengers(vehicle)
    local handleDriverIsFree = IsVehicleSeatFree(vehicle, -1)
    if not handleDriverIsFree then
        local ped = GetPedInVehicleSeat(vehicle, -1)
        TaskLeaveVehicle(ped, vehicle, 0)
        if ped and ped ~= 0 and ped ~= LGF.Player:Ped() then
            Wait(1000)
            TaskSmartFleePed(ped, LGF.Player:Ped(), 150.0, -1, false, false)
            ClearPedTasks(ped)
        end
    end
end

function VehicleInteraction:createInteraction(vehicle, isTrunk)
    local indexBone, offset = self:getBone(isTrunk, vehicle)

    if indexBone == nil then return end

    self.ID = exports.LGF_Interaction:createInteractionVehicle({
        Entity = vehicle,
        IndexBone = indexBone,
        OffsetBone = offset,
        OffsetCoords = vector3(0.0, 0.0, 1.0),
        DataBind = {
            {
                index = 1,
                title = isTrunk and Locales[CurrentLocale].stealFromTrunk or Locales[CurrentLocale].stealFromDoor,
                icon = isTrunk and "car" or "door-open",
                description = isTrunk and Locales[CurrentLocale].attemptStealTrunk or
                    Locales[CurrentLocale].attemptStealDoor,
                onClick = function()
                    self:handlePassengers(vehicle)

                    local animData = isTrunk and Animation.boot or Animation.door
                    local prop = Utils.StartPlayerAnim(animData.Anim, animData.Dict, nil)

                    if isTrunk then self:openTrunk(vehicle) end

                    exports["LGF_Utility"]:CreateProgressBar({
                        message = isTrunk and Locales[CurrentLocale].stealingFromTrunk or
                            Locales[CurrentLocale].stealingFromDoor,
                        colorProgress = "rgba(54, 156, 129, 0.381)",
                        position = "bottom",
                        duration = 5000,
                        transition = "fade",
                        onFinish = function()
                            Utils.ClearPlayerAnim(prop, animData.Dict)
                            Entity(vehicle).state:set('stolenFrom', true)

                            self:attemptStealItems(vehicle)

                            if isTrunk then
                                self:closeTrunk(vehicle)
                            end

                            self:removeInteraction()
                        end,
                        disableBind = false,
                        disableKeyBind = { 24, 32, 33, 34, 30, 31, 36, 21 },
                    })
                end
            }
        }
    })
    self.interactionCreated = true
end

function VehicleInteraction:attemptStealItems(vehicle)
    local vehicleClass     = GetVehicleClass(vehicle)
    local itemsConfig      = Config.StealedItem[vehicleClass]

    local foundItem        = false
    local selectedItemName = ""
    local selectedQuantity = 0

    if itemsConfig and itemsConfig.RandomItems and #itemsConfig.RandomItems > 0 then
        for _, item in ipairs(itemsConfig.RandomItems) do
            if math.random() <= item.ProbabilityDrop then
                selectedItemName = item.ItemName
                selectedQuantity = math.random(item.QuantityMin, item.QuantityMax)
                foundItem = true
                break
            end
        end
    end

    if foundItem then
        local Success = LGF:TriggerServerCallback("LGF_VehicleStealing.AddItemsRandom", selectedQuantity,selectedItemName)
        if Success then
            Utils.notification("Success",(Locales[CurrentLocale].stealSuccess):format(selectedQuantity, selectedItemName), "success")
        end
    else
        Utils.notification("No Items", (Locales[CurrentLocale].stealFailure):format("items"), "warning")
    end
end

function VehicleInteraction:removeInteraction()
    if self.interactionCreated and self.ID then
        exports.LGF_Interaction:removeInteractionById(self.ID)
        self.interactionCreated = false
        self.ID = nil
    end
end

function VehicleInteraction:isVehicleStolen(vehicle)
    return Entity(vehicle).state.stolenFrom
end

function VehicleInteraction:manageInteraction()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle, _ = lib.getClosestVehicle(playerCoords, MAX_DISTANCE, false)

    if vehicle then
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        local plate = self:getVehiclePlate(vehicle)

        local vehicleCoords = GetEntityCoords(vehicle)

        if #(playerCoords - vehicleCoords) > MAX_DISTANCE then warn("NO.") return end

        if self.currentVehicleNetId == netId and self.currentVehiclePlate == plate then return end

        self.currentVehicleNetId = netId
        self.currentVehiclePlate = plate

        -- Prevent Vehicle from another Steal
        if VehicleInteraction:isVehicleStolen(vehicle) then return end

        if self:hasTrunk(vehicle) then
            self:createInteraction(vehicle, true)
        else
            self:createInteraction(vehicle, false)
        end
    elseif self.interactionCreated then
        if self.ID then
            exports.LGF_Interaction:removeInteractionById(self.ID)
        end
        self.ID = nil
        self.interactionCreated = false
        self.currentVehicleNetId = nil
        self.currentVehiclePlate = nil
    end
end

function VehicleInteraction:start()
    self.threadHandle = CreateThread(function()
        while stealInitialized do
            Wait(500)
            self:manageInteraction()
        end
    end)
end

function VehicleInteraction:InitializeStealing()
    VehicleInteraction.instances = {}
    local vehicleInteraction = VehicleInteraction:create()
    table.insert(VehicleInteraction.instances, vehicleInteraction)
    vehicleInteraction:start()
    stealInitialized = true
end

function VehicleInteraction:clearInteractions()
    if not VehicleInteraction.instances then return end
    for _, interaction in pairs(VehicleInteraction.instances) do
        if interaction.interactionCreated and interaction.ID then
            exports.LGF_Interaction:removeInteractionById(interaction.ID)
            interaction.interactionCreated = false
            interaction.ID = nil
        end
    end
    VehicleInteraction.instances = nil
    stealInitialized = false
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        VehicleInteraction:clearInteractions()
    end
end)


RegisterCommand("initsteal", function(source, args, rawCommand)
    if not Config.AllowedGroups[LGF.Core:GetGroup()] then return end
    if stealInitialized then return end
    VehicleInteraction:InitializeStealing()
    Utils.notification("Success", Locales[CurrentLocale].stealingStarted, "success")
end)



AddStateBagChangeHandler('stolenFrom', nil, function(bagName, key, value, _reserved, replicated)
    if key == 'stolenFrom' and value then
        local entity = GetEntityFromStateBagName(bagName)

        if entity and entity ~= 0 and DoesEntityExist(entity) then
            for _, vehicleInteraction in pairs(VehicleInteraction.instances) do
                if vehicleInteraction.currentVehicleNetId == NetworkGetNetworkIdFromEntity(entity) then
                    vehicleInteraction:removeInteraction()
                end
            end
        else
            warn(("entityId is invalid or does not exist for bagName: %s"):format(bagName))
        end
    end
end)

exports("isVehicleStolen", function(vehicle)
    return VehicleInteraction:isVehicleStolen(vehicle)
end)
