local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnColorTitlebarLoaded = function(caller,status,creator)
	--caller:WaitInit(1)

	local window = caller:FindParent("Window")
	local colorPickerSettings = window.WindowSettings.ColorPickerSettings

	caller.Titlebuttons.AutoSetWindowSettings = false
	caller.Titlebuttons.WindowSettings = colorPickerSettings
	caller.Titlebuttons:SetChildren("Target",colorPickerSettings)

	-- adjust window itself
	window.EditEncoderBar="ColorPickerBar"
	window.HelpTopic="operate_color_picker.html"
	window.ReactToPreview="Yes"
	window.TitleBar.TitleButton.Text="Special Dialog - Color Picker"
end