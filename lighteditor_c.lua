lr = ImportPackage("lightstreamer")

Edit = false
SelectedLight = 0
lightUI = 0
LightTimer = 0
UITimer = 0
EditMode = EDIT_LOCATION
LightsInWorld = {}


TemporySelectedLight = 0

AddEvent("OnPackageStart", function()
    local ScreenX, ScreenY = GetScreenSize()
    lightUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 30)
    SetWebAnchors(lightUI, 0.72, 0.0, 1.0, 1.0)
    LoadWebFile(lightUI, 'http://asset/' .. GetPackageName() .. '/lighteditor.html')
	SetWebVisibility(lightUI, WEB_HIDDEN)
end)

AddEvent("OnKeyPress", function(key)
    if (key == "K") then LightEditMode() end
    if not Edit then return end
    if (key == "Left Mouse Button") then LightSelection()
    elseif (key == "Left Alt" and SelectedLight ~= 0) then ChangeEditorState()
    elseif (key == "Delete" and SelectedLight ~= 0) then LightDestroy()
    elseif (IsCtrlPressed() and key == 'V' and SelectedLight ~= 0) then CallRemoteEvent("LightDuplication", SelectedLight)
    end
end)

function LightEditMode()
    if(Edit) then Edit = false
    else Edit = true end
    CallRemoteEvent("EditState", Edit) 
end

AddRemoteEvent("EditMode", function(lights)
    LightsInWorld = lights
    ShowMouseCursor(Edit)
    if (Edit) then 
        SetInputMode(INPUT_GAMEANDUI)
        SetWebVisibility(lightUI, WEB_VISIBLE)
        ExecuteWebJS(lightUI, 'ShowUI()')
        CallRemoteEvent("GetEditorLights")
    else 
        SetInputMode(INPUT_GAME)
        SetWebVisibility(lightUI, WEB_HIDDEN)
        if(SelectedLight ~= 0) then
            if(UITimer ~= 0)then DestroyTimer(UITimer) end
            SetObjectEditable(SelectedLight, EDIT_NONE)
            SelectedLight = 0
        end
    end
    ShowEdit(Edit, lights)
end)

function ShowEdit(edit)
    for k, v in pairs(LightsInWorld) do
        if(IsValidObject(k)) then
            local ObjectActor = GetObjectActor(k)
            if (edit) then
                ObjectActor:SetActorScale3D(FVector(1.0, 1.0, 1.0))
            else
                ObjectActor:SetActorScale3D(FVector(0.01, 0.01, 0.01))
            end
            ObjectActor:SetActorEnableCollision(edit)
        end
    end
    ShowLight(edit)
end

function ShowLight(edit)
    if not edit then DestroyTimer(LightTimer)
    else
        LightTimer = CreateTimer(function()
            local ScreenX, ScreenY = GetScreenSize()
            for k, v in pairs(LightsInWorld) do
                if(IsValidObject(v)) then
                    local x, y, z = GetObjectLocation(v)
                    local bs,sx,sy = WorldToScreen(x, y, z)
                    if bs then
                        if(v == SelectedLight) then 
                            DrawVector()
                            SetDrawColor(RGB(255, 255, 0, 255))
                        else 
                            SetDrawColor(RGB(255, 255, 255, 255)) 
                        end
                        DrawText(sx-string.len("LightID : " .. tostring(v)) * 3,sy - 45, "LightID : " .. tostring(v))
                        --DrawText(sx-string.len("Lighttype : " .. tostring(v.lighttype)) * 3,sy - 30, "Lighttype : " .. tostring(v.lighttype))
                        --DrawText(sx-string.len("Model : " .. tostring(modelname)) * 3,sy - 15, "Model : " .. tostring(modelname))
                        DrawText(sx-string.len("Location : " .. tostring(math.floor(x + 0.5)) .. " " .. tostring(math.floor(y + 0.5)) .. " " .. tostring(math.floor(z + 0.5))) * 3,sy, "Location : " .. tostring(math.floor(x + 0.5)) .. " " .. tostring(math.floor(y + 0.5)) .. " " .. tostring(math.floor(z + 0.5)))
                        local rx, ry, rz = GetObjectRotation(v)
                        DrawText(sx-string.len("Rotation : " .. tostring(math.floor(rx + 0.5)) .. " " .. tostring(math.floor(ry + 0.5)) .. " " .. tostring(math.floor(rz + 0.5))) * 3,sy + 15, "Rotation : " .. tostring(math.floor(rx + 0.5)) .. " " .. tostring(math.floor(ry + 0.5)) .. " " .. tostring(math.floor(rz + 0.5)))
                        local MinX, MinY, MinZ, MaxX, MaxY, MaxZ = GetObjectBoundingBox(v)
                        DrawLight(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
                    end
                end
            end
        end, 8)
    end
end

function DrawVector()
    local actorlight = GetObjectActor(SelectedLight)
    local x, y, z = GetObjectLocation(SelectedLight)
    local FV = actorlight:GetActorForwardVector()

    local sX = FV.X * 50 + x
    local sY = FV.Y * 50 + y
    local sZ = FV.Z * 50 + z

    local eX = FV.X * 150 + x
    local eY = FV.Y * 150 + y
    local eZ = FV.Z * 150 + z

    SetDrawColor(RGB(10, 100, 125, 255))
    DrawLine3D(sX, sY, sZ, eX, eY, eZ, 4)
end

function DrawLight(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
    local size = 2
    DrawLine3D(MinX, MinY, MinZ, MaxX, MinY, MinZ, size)
    DrawLine3D(MinX, MinY, MinZ, MinX, MaxY, MinZ, size)
    DrawLine3D(MinX, MinY, MinZ, MinX, MinY, MaxZ, size)

    DrawLine3D(MaxX, MinY, MinZ, MaxX, MaxY, MinZ, size)
    DrawLine3D(MaxX, MinY, MinZ, MaxX, MinY, MaxZ, size)

    DrawLine3D(MinX, MaxY, MinZ, MaxX, MaxY, MinZ, size)
    DrawLine3D(MinX, MaxY, MinZ, MinX, MaxY, MaxZ, size)

    DrawLine3D(MinX, MinY, MaxZ, MaxX, MinY, MaxZ, size)
    DrawLine3D(MinX, MinY, MaxZ, MinX, MaxY, MaxZ, size)

    DrawLine3D(MaxX, MaxY, MaxZ, MaxX, MaxY, MinZ, size)
    DrawLine3D(MaxX, MaxY, MaxZ, MinX, MaxY, MaxZ, size)
    DrawLine3D(MaxX, MaxY, MaxZ, MaxX, MinY, MaxZ, size)
end

function LightSelection()
    local x, y, z, distance = GetMouseHitLocation()
    local EntityType, EntityId = GetMouseHitEntity()
    if (TemporySelectedLight ~= 0) then
        LightSet(x, y, z)
    elseif (EntityType == HIT_OBJECT and EntityId ~= 0 and GetObjectPropertyValue(EntityId, "_lightStream") and SelectedLight ~= EntityId) then
        SelectedLight = EntityId
        SetObjectEditable(SelectedLight, EDIT_LOCATION)
        GetUIlightInfo()

        local lp = GetObjectPropertyValue(SelectedLight, "_lightStream")
        local text = string.lower(lp.lighttype).." selected !"
    
        ExecuteWebJS(lightUI, 'UIinfoText("'..text..'")')
    end
end

function LightSet(x, y, z)
    CallRemoteEvent("CreateEditorLight", TemporySelectedLight, x, y, z)
    TemporySelectedLight = 0
end

function ChangeEditorState()
    if EditMode == EDIT_LOCATION then EditMode = EDIT_ROTATION
    else EditMode = EDIT_LOCATION end
    SetObjectEditable(SelectedLight, EditMode)
end

function LightDestroy()
    CallRemoteEvent("DeleteLight", SelectedLight)
    DestroyTimer(UITimer)
    SelectedLight = 0
    ExecuteWebJS(lightUI, 'ShowUI()')
end

function GetUIlightInfo()
    local lp = GetObjectPropertyValue(SelectedLight, "_lightStream")
    if(lp.lighttype == "SPOTLIGHT") then type = 1
    elseif(lp.lighttype == "POINTLIGHT") then type = 2
    elseif(lp.lighttype == "RECTLIGHT") then type = 3
    end
    if(lp.shadow) then shadow = 1
    else shadow = 0 end
    ExecuteWebJS(lightUI, 'UIlightUpdate('..type..', '..SelectedLight..')')   
    local x, y, z = GetObjectLocation(SelectedLight)
    local rx, ry, rz = GetObjectRotation(SelectedLight)
    local r, g, b = HexToRGBA(lp.color)
    local color = tostring(rgb2hex(r, g, b))
    ExecuteWebJS(lightUI, 'UpdatePosition (' .. x .. ', ' .. y .. ', ' .. z .. ')')
	ExecuteWebJS(lightUI, 'UpdateRotation (' .. rx .. ', ' .. ry .. ', ' .. rz .. ')')
    ExecuteWebJS(lightUI, 'UpdateBase (' .. r .. ', ' .. g .. ', ' .. b .. ', '.. lp.intensity .. ', ' .. lp.attenuation_radius .. ', ' .. shadow .. ', ' .. lp.stream_distance ..')')

    if(lp.lighttype == "SPOTLIGHT") then
        ExecuteWebJS(lightUI, 'UpdateSpotlight (' .. lp.outer_cone .. ', ' .. lp.inner_cone .. ', ' .. lp.falloff .. ', ' .. lp.source_lenght .. ', ' .. lp.source_radius .. ', ' .. lp.soft_source_radius .. ')')
    elseif(lp.lighttype == "POINTLIGHT") then
        ExecuteWebJS(lightUI, 'UpdatePointlight (' .. lp.falloff .. ', ' .. lp.source_lenght .. ', ' .. lp.source_radius .. ', ' .. lp.soft_source_radius .. ')')
    elseif(lp.lighttype == "RECTLIGHT") then
        ExecuteWebJS(lightUI, 'UpdateRectlight (' .. lp.barn_door_angle .. ', ' .. lp.barn_door_lenght .. ', ' .. lp.source_height .. ', ' .. lp.source_width .. ')')
    end
end

function UpdateSelectedPosition(x, y, z)
    if(SelectedLight ~= 0) then
        CallRemoteEvent("UpdatePos", SelectedLight, x, y, z)
    end
end
AddEvent("UpdateSelectedPosition", UpdateSelectedPosition)

function UpdateSelectedRotation(rx, ry, rz)
    if(SelectedLight ~= 0) then
        CallRemoteEvent("UpdateRot", SelectedLight, rx, ry, rz)
    end
end
AddEvent("UpdateSelectedRotation", UpdateSelectedRotation)



function SetLightCollision(light, lights)
    SelectedLight = light
    Alight = GetObjectActor(SelectedLight)
    Alight:SetActorScale3D(FVector(1.0, 1.0, 1.0))
    Alight:SetActorEnableCollision(true)
    SetObjectEditable(SelectedLight, EDIT_LOCATION)
    LightsInWorld = lights
    
    GetUIlightInfo()

    local lp = GetObjectPropertyValue(SelectedLight, "_lightStream")
    local text = string.lower(lp.lighttype).." created !"

    ExecuteWebJS(lightUI, 'UIinfoText("'.. text ..'")')
end
AddRemoteEvent("SetLightCollision", SetLightCollision)


AddEvent("UILightSelection", function(lighttype)
    if(SelectedLight ~= 0) then
        if(UITimer ~= 0)then DestroyTimer(UITimer) end
        SetObjectEditable(SelectedLight, EDIT_NONE)
        SelectedLight = 0
    end
    TemporySelectedLight = lighttype 
end)

AddEvent("ChangeLightColor", function(hex)
    local r, g, b = hex2rgb(hex)
    local color = RGB(r, g, b)
    CallRemoteEvent("LightColor", SelectedLight, color)
end)
AddEvent("LightsSave", function()
    CallRemoteEvent("LightSave")
end)
AddEvent("LightDeleteAll", function()
    DestroyTimer(UITimer)
    SelectedLight = 0
    ExecuteWebJS(lightUI, 'ShowUI()')
    CallRemoteEvent("DeleteAllLight")
end)
AddEvent("LightDelete", function()
    LightDestroy()
end)
AddEvent("LightDuplicate", function()
    local ObjectActor = GetObjectActor(SelectedLight)
    local Vector = ObjectActor:GetActorLocation()
    CallRemoteEvent("LightDuplication", SelectedLight)
end)
AddEvent("ChangeLightIntensity", function(intensity)
    CallRemoteEvent("LightIntensity", SelectedLight, intensity)
end)
AddEvent("ChangeLightAttenuationradius", function(radius)
    CallRemoteEvent("LightAttenuationradius", SelectedLight, radius)
end)
AddEvent("ChangeLightShadow", function(shadow)
    CallRemoteEvent("LightShadow", SelectedLight, shadow)
end)
AddEvent("ChangeLightStreamradius", function(radius)
    CallRemoteEvent("LightStreamRadius", SelectedLight, radius)
end)
AddEvent("ChangeLightOutercone", function(cone)
    CallRemoteEvent("LightOuterCone", SelectedLight, cone)
end)
AddEvent("ChangeLightInnercone", function(cone)
    CallRemoteEvent("LightInnerCone", SelectedLight, cone)
end)
AddEvent("ChangeLightFalloff", function(falloff)
    CallRemoteEvent("LightFalloff", SelectedLight, falloff)
end)
AddEvent("ChangeLightSourceradius", function(radius)
    CallRemoteEvent("LightSourceRadius", SelectedLight, radius)
end)
AddEvent("ChangeLightSourcelenght", function(lenght)
    CallRemoteEvent("LightSourceLenght", SelectedLight, lenght)
end)
AddEvent("ChangeLightSoftsourceradius", function(radius)
    CallRemoteEvent("LightSoftSourceRadius", SelectedLight, radius)
end)
AddEvent("ChangeLightDoorangle", function(angle)
    CallRemoteEvent("LightDoorAngle", SelectedLight, angle)
end)
AddEvent("ChangeLightDoorlenght", function(lenght)
    CallRemoteEvent("LightDoorLenght", SelectedLight, lenght)
end)
AddEvent("ChangeLightSourceheight", function(height)
    CallRemoteEvent("LightSourceHeight", SelectedLight, height)
end)
AddEvent("ChangeLightSourcewidth", function(width)
    CallRemoteEvent("LightSourceWidth", SelectedLight, width)
end)
AddEvent("ChangeWorldTime", function(time)
    SetTime(time)
end)

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function rgb2hex(red, green, blue, alpha)
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

AddEvent("OnPlayerBeginEditObject", function(light)
    UITimer = CreateTimer(function() 
        local x, y, z = GetObjectLocation(SelectedLight)
        local rx, ry, rz = GetObjectRotation(SelectedLight)
        ExecuteWebJS(lightUI, 'UpdatePosition (' .. x .. ', ' .. y .. ', ' .. z .. ')')
	    ExecuteWebJS(lightUI, 'UpdateRotation (' .. rx .. ', ' .. ry .. ', ' .. rz .. ')')
    end, 100)
end)

AddEvent("OnPlayerEndEditObject", function(light)
    if(UITimer ~= 0)then DestroyTimer(UITimer) end
    local x, y, z = GetObjectLocation(SelectedLight)
    local rx, ry, rz = GetObjectRotation(SelectedLight)
    CallRemoteEvent("UpdatePos", light, x, y, z)
    CallRemoteEvent("UpdateRos", light, rx, ry, rz)
end)
