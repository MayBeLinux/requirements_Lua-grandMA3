local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnFilebrowserExampleLoad = function(caller,status,creator)
    local initialPath = GetPathOverrideFor("gma3_library", "");
    caller.Content.FileBrowser.SetPath(initialPath)
end

