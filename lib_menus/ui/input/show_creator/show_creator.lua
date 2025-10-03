local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnMenuLoaded = function(caller)
end

signalTable.UseSettingsTarget = function(caller)
    caller:WaitInit(1);
    local overlay = caller:GetOverlay();
    caller.Target = overlay.Settings;
end