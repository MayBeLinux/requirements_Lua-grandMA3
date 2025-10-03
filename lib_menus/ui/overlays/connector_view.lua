local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.ConnectorViewLoaded = function(caller,status,creator)
    local DispIdx = caller:GetDisplayIndex()

    local hType = HostType()
    local hSubType = HostSubType()

    local isSupportedConsole = (hType == "Console") and ((hSubType == "FullSize") or (hSubType == "FullSizeCRV") or (hSubType == "Light") or (hSubType == "LightCRV"));
    local isFullSize = (hType == "Console") and ((hSubType == "FullSize") or ((hSubType == "FullSizeCRV")));
    local isFullSizeCrv = (hType == "Console") and (hSubType == "FullSizeCRV");
    local isCrv = (hType == "Console") and ((hSubType == "LightCRV") or ((hSubType == "FullSizeCRV")));

    if(isSupportedConsole) then
        caller.Visible = "Yes"

        if(DispIdx == 8) then
            caller.Disp8.Visible = "Yes"
            caller.Disp9.Visible = "No"
            caller.Disp10.Visible = "No"
            caller.Disp11.Visible = "No"
        end
        if(DispIdx == 9) then
            caller.Disp8.Visible = "No"
            caller.Disp9.Visible = "Yes"
            caller.Disp10.Visible = "No"
            caller.Disp11.Visible = "No"
        end
        if(DispIdx >= 10) then -- this can either be the left module on a full-size or an extension
            local isExtension;
            local wingID;
            wingID, extension = GetRemoteVideoInfo(DispIdx);
            -- Echo(tostring(wingID) .. " - " .. tostring(extension))
            if(not extension) then
                caller.Disp8.Visible = "No"
                caller.Disp9.Visible = "No"
                caller.Disp10.Visible = "Yes"
                caller.Disp11.Visible = "No"
            else
                caller.Disp8.Visible = "No"
                caller.Disp9.Visible = "No"
                caller.Disp10.Visible = "No"
                caller.Disp11.Visible = "Yes"
            end
        end
        FindBestFocus(caller)

        -- Echo (hType .. " " .. hSubType)

        if isFullSize then
            caller.Disp9.DesklightLightIcon.Visible = false
            caller.Disp9.DesklightLightText.Visible = false
        else
            caller.Disp9.DesklightLightIcon.Visible = true
            caller.Disp9.DesklightLightText.Visible = true
        end

        if isFullSizeCrv then
            caller.Disp8.Dp3Icon.Visible = true
            caller.Disp8.Dp3Text.Visible = true
        else
            caller.Disp8.Dp3Icon.Visible = false
            caller.Disp8.Dp3Text.Visible = false
        end

        if isCrv then
            caller.Disp8.Dp1Icon.Visible = true
            caller.Disp8.Dp1Text.Visible = true
            caller.Disp8.Dp2Icon.Visible = true
            caller.Disp8.Dp2Text.Visible = true
        else
            caller.Disp8.Dp1Icon.Visible = false
            caller.Disp8.Dp1Text.Visible = false
            caller.Disp8.Dp2Icon.Visible = false
            caller.Disp8.Dp2Text.Visible = false
        end

    else
        CloseAllOverlays();
    end
end

