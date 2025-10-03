local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.BatteryStautsMenuLoaded = function(caller,status,creator)
    local BatteryOverlay = caller
    HookObjectChange(signalTable.PowerSourceChange,Root().HardwareStatus.BatteryStatus,my_handle:Parent(),BatteryOverlay);
    signalTable.PowerSourceChange(caller, nil, BatteryOverlay);
end

signalTable.PowerSourceChange = function(caller,signal,BatteryOverlay)
    local BattStatus = Root().HardwareStatus.BatteryStatus;
    if not BattStatus.Available then
        BatteryOverlay.Content.PowerSourceText.Text = "The console does not have a UPS."
        BatteryOverlay.Content.PowerSourceText.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewWarningBackground
    else 
        if BattStatus.BatteryFault then
            BatteryOverlay.Content.PowerSourceText.Text = "The console diagnosed a fault in the battery."
            BatteryOverlay.Content.PowerSourceText.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewAlertBackground
        elseif BattStatus.AcPowerOk then
            BatteryOverlay.Content.PowerSourceText.Text = "The console runs on AC."
            BatteryOverlay.Content.PowerSourceText.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewSpamBackground
        else
            BatteryOverlay.Content.PowerSourceText.Text = "The console runs on battery."
            BatteryOverlay.Content.PowerSourceText.BackColor = Root().ColorTheme.ColorGroups.MessageCenter.NewAlertBackground
        end
    end

end
