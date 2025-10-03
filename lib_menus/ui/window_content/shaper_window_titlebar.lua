local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnShaperTitlebarLoaded = function(caller,status,creator)
	--caller:WaitInit(1)

	local window = caller:FindParent("Window")
	local shaperWindowSettings = window.WindowSettings.ShaperWindowSettings

	caller.Titlebuttons.AutoSetWindowSettings = false
	caller.Titlebuttons.WindowSettings = shaperWindowSettings
	caller.Titlebuttons:SetChildren("Target",shaperWindowSettings)

	-- adjust window itself
	window.EditEncoderBar="ShaperBar"
	window.ReactToPreview="Yes"
	window.HelpTopic="operate_shapers.html"
	window.TitleBar.TitleButton.Text="Special Dialog - Shaper"

	HookObjectChange(signalTable.OnWindowSettingsChanged, shaperWindowSettings, my_handle:Parent(), caller);
	signalTable.OnWindowSettingsChanged(shaperWindowSettings, my_handle:Parent(), caller);
end

signalTable.OnWindowSettingsChanged = function(settings, signal, caller)
	caller.Titlebuttons.MiniFadersMode.Enabled = settings.ViewMode == "Graphical";
end