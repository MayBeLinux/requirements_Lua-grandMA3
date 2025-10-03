local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- include me into the target menu when you want to use an ObjectSettings placeholder

-- This is the OnLoad for the actual placeholder content:
-- <PlaceHolderBase Anchors="0,0" Name="ObjectSettings" OnLoad=":LoadObjectSettings"/>
signalTable.LoadObjectSettings = function(caller)
	if IsObjectValid(caller) then
		local editor = caller:GetOverlay();
		local target = editor.EditTarget;
		-- fill placeholder
		local settingsPluginName = "GenericSettings";
		if target and target:GetUISettings() then
			settingsPluginName = target:GetUISettings();
		end
		local settingsUI = Root().Menus[settingsPluginName]:CommandCall(editor);
		if settingsUI ~= nil then
			settingsUI.Target = target;
			editor:Changed()
		end
		return settingsUI
	end
end