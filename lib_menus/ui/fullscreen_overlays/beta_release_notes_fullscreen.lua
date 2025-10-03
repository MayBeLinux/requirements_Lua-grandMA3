local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BetaReleaseNotesFullscreenLoaded = function(caller,status,creator)
	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent(); 
	plugin_pool.BetaReleaseNotesDialog:CommandCall(caller);
end

signalTable.DontAgree = function(caller,dummy)
	Cmd("ShutDown /nc");
end

signalTable.Agree = function(caller,dummy)
	Root().StationSettings:Save("", "");
	caller:GetOverlay().Close();
end
