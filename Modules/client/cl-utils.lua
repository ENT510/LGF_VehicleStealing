local Utils   = {}
local Config  = LGF:LuaLoader("Shared/shared")
local Context = LGF:GetContext()
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
        AttachEntityToEntity(props, Ped, GetPedBoneIndex(Ped, 28422), 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true,
            false, true, 1, true)
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

function Utils.notification(title, message, type, position,source)
    if Context == "client" then
        if Config.ProviderNotification == "ox_lib" and GetResourceState("ox_lib"):find("start") then
            lib.notify({
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = position or 'top-right',
            })
        elseif Config.ProviderNotification == "utility" and GetResourceState("LGF_Utility"):find("start") then
            TriggerEvent('LGF_Utility:SendNotification', {
                id = math.random(111111111, 3333333333),
                title = title,
                message = message,
                icon = type,
                duration = 5000,
                position = 'top-right',
            })
        end
    elseif Context == "server" then
        if Config.ProviderNotification == "ox_lib" and GetResourceState("ox_lib"):find("start") then
            TriggerClientEvent('ox_lib:notify', source, {
                title = title,
                description = message,
                type = type,
                duration = 5000,
                position = position or 'top-right',
            })
        elseif Config.ProviderNotification == "utility" and GetResourceState("LGF_Utility"):find("start") then
            Utility:TriggerClientEvent('LGF_Utility:SendNotification', source, {
                id = math.random(111111111, 3333333333),
                title = title,
                message = message,
                icon = type,
                duration = 5000,
                position = 'top-right',
            })
        end
    end
end

return Utils
