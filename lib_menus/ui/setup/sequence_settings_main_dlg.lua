local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SequenceSettingsOverlayLoaded = function(caller)
	local parentPlaceholder = caller:Parent();
	local editor = parentPlaceholder:GetOverlay();
	if (editor and editor:GetClass() == "GenericSettingsEditor" and editor.EditTarget) then
		local plugin     =my_handle:Parent();
		local plugin_pool=plugin:Parent(); 
		local sequenceSettingsUI = plugin_pool.SequenceSettings:CommandCall(caller);
		if (sequenceSettingsUI) then
			sequenceSettingsUI.Target = editor.EditTarget;
		end
	end
end

signalTable.LoadFromDefault = function(caller)
 Echo("Load from default");
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Content.ObjectSettings;
 if (pbPlaceholder) then
	 local sequenceSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (sequenceSettingsUI) then
		sequenceSettingsUI.LoadFromDefault();
	 end
 end
end

signalTable.SaveToDefault = function(caller)
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Content.ObjectSettings;
 if (pbPlaceholder) then
	 local sequenceSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (sequenceSettingsUI) then
		sequenceSettingsUI.SaveToDefault();
		 Echo("Save to default");
	 end
 end
end