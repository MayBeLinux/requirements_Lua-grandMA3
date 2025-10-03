local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function SetDateTimeTitle(caller)
    local NtpSynchronized = (Root().StationSettings.TimeConfig.TimeSyncMode == "NTP");
    
    if NtpSynchronized then
       caller.TitleBar.TitleButton.Text = "Date and Time (NTP synchronized)"       
    else
       caller.TitleBar.TitleButton.Text = "Date and Time"
    end
end

signalTable.ContentChange = function(caller,status,creator)
    local mainDialog = caller:Parent():Parent();
    local overlay = mainDialog:Parent();
    local NtpSynchronized = (Root().StationSettings.TimeConfig.TimeSyncMode == "NTP");
    
    if caller.SelectedItemIdx == 0 then
       mainDialog.SwitchMenu("");
       mainDialog.MainDateTime.FrameTime.Hour.enabled = (NtpSynchronized == false);
       mainDialog.MainDateTime.FrameTime.Minute.enabled = (NtpSynchronized == false);
       mainDialog.MainDateTime.FrameTime.Second.enabled = (NtpSynchronized == false);
       mainDialog.MainDateTime.FrameDate.Day.enabled = (NtpSynchronized == false);
       mainDialog.MainDateTime.FrameDate.Month.enabled = (NtpSynchronized == false);
       mainDialog.MainDateTime.FrameDate.Year.enabled = (NtpSynchronized == false);       
    elseif caller.SelectedItemIdx == 1 then
       mainDialog.SwitchMenu("DaylightConfiguration");
    elseif caller.SelectedItemIdx == 2 then
       mainDialog.SwitchMenu("TimeServer");
    end

    SetDateTimeTitle(overlay.MainDialog);

end

signalTable.OnLoadDaylightInfo = function(caller,status,creator)
    SetDateTimeTitle(caller);
end

signalTable.OnLoadTimeServer = function(caller,status,creator)
    SetDateTimeTitle(caller);
    HookObjectChange(signalTable.TimeConfigHook,  Root().StationSettings.TimeConfig, my_handle:Parent(), caller);
end

signalTable.TimeConfigHook = function(settings, dummy, caller)
    SetDateTimeTitle(caller);
end