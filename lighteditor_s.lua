lr = ImportPackage("lightstreamer")

function cmd_l(player, type)
    if (type == nil) then
		return AddPlayerChat(player, "Usage: /l <type>")
	end
    NewLight(player, type)
end
AddCommand("l", cmd_l)

function CreateEditorLight(player, type, x, y, z)
    local type = tonumber(type)
    local model
    if(type == 1) then model = "SPOTLIGHT"
    elseif (type == 2) then model = "POINTLIGHT"
    elseif (type == 3) then model = "RECTLIGHT"
    end
    
    light = lr.CreateLight(model, x, y, z + 25)
    
    lights = lr.GetAllLights()

    table.insert(EditorLights, light)

    Delay(100, function()
        CallRemoteEvent(player, "SetLightCollision", light, lights)
    end)
end
AddRemoteEvent("CreateEditorLight", CreateEditorLight)

function DeleteLight(player, light)
    for k, v in pairs(EditorLights) do
        if(v == light) then
            table.remove(EditorLights, k)
            break
        end
    end
    lr.DestroyLight(light)
end
AddRemoteEvent("DeleteLight", DeleteLight)

function DeleteAllLight(player)
    for k, v in pairs(EditorLights) do
        DestroyObject(v)
    end
    EditorLights = {}
end
AddRemoteEvent("DeleteAllLight", DeleteAllLight)

AddRemoteEvent("GetEditorLights", function(player)
    CallRemoteEvent(player, "EditorLights", EditorLights)
end)

function cmd_s(player)
    EditState(player)
end
AddCommand("s", cmd_s)

function EditState(player, state)
    SetPlayerSpectate(player, state)
    lights = lr.GetAllLights()
    CallRemoteEvent(player, "EditMode", lights)
end
AddRemoteEvent("EditState", EditState)

AddRemoteEvent("UpdatePos", function(player, light, x, y, z)
    lr.SetLightLocation(light, x, y, z)
end)

AddRemoteEvent("UpdateRot", function(player, light, rx, ry, rz)
    lr.SetLightRotation(light, rx, ry, rz)
end)

AddRemoteEvent("LightColor", function(player, light, color)
    lr.SetLightColor(light, color)
end)

AddRemoteEvent("LightIntensity", function(player, light, intensity)
    lr.SetLightIntensity(light, intensity)
end)

AddRemoteEvent("LightAttenuationradius", function(player, light, radius)
    lr.SetLightAttenuationRadius(light, radius)
end)

AddRemoteEvent("LightShadow", function(player, light, shadow)
    if(shadow == 0) then bEnable = false
    else bEnable = true end
    lr.SetLightCastShadows(light, bEnable)
end)

AddRemoteEvent("LightStreamRadius", function(player, light, radius)
    lr.SetLightStreamDistance(light, radius)
end)

AddRemoteEvent("LightOuterCone", function(player, light, cone)
    lr.SetLightOuterConeAngle(light, cone)
end)

AddRemoteEvent("LightInnerCone", function(player, light, cone)
    lr.SetLightOuterConeAngle(light, cone)
end)

AddRemoteEvent("LightFalloff", function(player, light, falloff)
    lr.SetLightFalloffExponent(light, falloff)
end)

AddRemoteEvent("LightSourceRadius", function(player, light, radius)
    lr.SetLightSourceRadius(light, radius)
end)

AddRemoteEvent("LightSourceLenght", function(player, light, lenght)
    lr.SetLightSourceLength(light, lenght)
end)

AddRemoteEvent("LightSoftSourceRadius", function(player, light, radius)
    lr.SetLightSoftSourceRadius(light, radius)
end)

AddRemoteEvent("LightDoorAngle", function(player, light, angle)
    lr.SetLightBarnDoorAngle(light, angle) 
end)

AddRemoteEvent("LightDoorLenght", function(player, light, lenght)
    lr.SetLightBarnDoorLength(light, lenght)
end)

AddRemoteEvent("LightSourceHeight", function(player, light, height)
    lr.SetLightBarnDoorLength(light, height)
end)

AddRemoteEvent("LightSourceWidth", function(player, light, width)
    lr.SetLightBarnDoorLength(light, width)
end)

AddRemoteEvent("LightDuplication", function(player, light)
    local newlight = lr.CreateLightDuplication(light)
    local lights = lr.GetAllLights()

    table.insert(EditorLights, newlight)

    Delay(100, function()
        CallRemoteEvent(player, "SetLightCollision", newlight, lights)
    end)
end)