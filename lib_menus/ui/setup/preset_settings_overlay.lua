local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.PresetSettingsOverlayLoaded = function(caller)
	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent(); 
	local presetSettingsUI = plugin_pool.PresetSettings:CommandCall(caller);

	local target = caller.EditTarget;
	if (presetSettingsUI) then
		local parentPlaceholder = caller:Parent();

		local editor = parentPlaceholder:GetOverlay();
		if (editor and editor.EditTarget) then
			target = editor.EditTarget;
		else
			target = caller.EditTarget;
		end

		presetSettingsUI.Target = target;
		caller.TitleBar.Title.Text = "Preset settings " .. target:Index() .. " \'" .. target.Name .. "\'";
		caller.Visible = true;
	end
end

signalTable.LoadFromDefault = function(caller)
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Frame.ObjectSettings;
 if (pbPlaceholder) then
	 local presetSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (presetSettingsUI) then
		presetSettingsUI.LoadFromDefault();
	 end
 end
end

signalTable.SaveToDefault = function(caller)
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Frame.ObjectSettings;
 if (pbPlaceholder) then
	 local presetSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (presetSettingsUI) then
		presetSettingsUI.SaveToDefault();
	 end
 end
end