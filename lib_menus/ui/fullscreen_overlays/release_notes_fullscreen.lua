local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.ReleaseNotesFullscreenLoaded = function(caller,status,creator)
	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent(); 
	plugin_pool.ReleaseNotesDialog:CommandCall(caller);
end

signalTable.DontAgreeBtn = function(caller,dummy)
    Cmd("ShutDown /nc");
end

signalTable.Ok = function(caller,dummy)
	caller:GetOverlay().Close();
end

signalTable.SetTarget = function(caller)
	caller.Target=Root().StationSettings.LocalSettings;
end

