local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.AddSize = function(caller)
    local currentDrive = Root().StationSettings.LocalSettings.SelectedDriveObject;
    if currentDrive then
        caller.Text = [[
            Your hard drive is getting full and has only ]]..currentDrive.FreeSpaceStr..[[ memory space left. We recommend you delete old show files and all backup files.
        ]]
    else
        caller.Text = [[
        Your hard drive is getting full. We recommend you delete old show files and all backup files.
        ]]
    end
end