local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.AddPath = function(caller)
    local currentDrive = Root().StationSettings.LocalSettings.SelectedDriveObject;
    caller.Text = string.format("Could not create path \"%s\".\nCheck folders for write permissions.", currentDrive.Path)
end