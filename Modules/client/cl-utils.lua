local Utils = {}

local RequestAnimDict = RequestAnimDict
local HasAnimDictLoaded = HasAnimDictLoaded
local Wait = Citizen.Wait
local TaskPlayAnim = TaskPlayAnim
local GetPedBoneIndex = GetPedBoneIndex
local CreateObject = CreateObject
local AttachEntityToEntity = AttachEntityToEntity
local ClearPedTasks = ClearPedTasks
local DetachEntity = DetachEntity
local DeleteEntity = DeleteEntity
local RemoveAnimDict = RemoveAnimDict

function Utils.StartPlayerAnim(anim, dict, prop)

    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do Wait(1) end

    local Ped = LGF.Player:Ped()
    local PlayerCoords = LGF.Player:Coords()

    TaskPlayAnim(Ped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)

    if prop then
        local model = LGF:RequestEntityModel(prop, 3000)
        local props = CreateObject(model, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.2, true, true, true)
        AttachEntityToEntity(props, Ped, GetPedBoneIndex(Ped, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)
        return props
    end
end

function Utils.ClearPlayerAnim(prop, dict)
    local Ped = LGF.Player:Ped()
    ClearPedTasks(Ped)
    if prop then
        DetachEntity(prop, true, true)
        DeleteEntity(prop)
    end

    if dict then
        Utils.RemoveAnimSet(dict)
    end
end

function Utils.RemoveAnimSet(dict)
    if HasAnimDictLoaded(dict) then
        RemoveAnimDict(dict)
    end
end

return Utils
