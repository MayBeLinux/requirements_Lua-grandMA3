local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SequenceSettingsOverlayLoaded = function(caller)
	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent(); 
	local sequenceSettingsUI = plugin_pool.SequenceSettings:CommandCall(caller);

	local target = caller.EditTarget;
	if (sequenceSettingsUI) then
		local parentPlaceholder = caller:Parent();
		local sGrid = parentPlaceholder:Parent();
		if (sGrid and sGrid:GetClass() == "SequenceGrid") then
			target = sGrid.TargetObject;
		else
			local editor = parentPlaceholder:GetOverlay();
			if (editor and editor:GetClass() == "GenericSettingsEditor" and editor.EditTarget) then
				target = editor.EditTarget;
			else
				target = caller.EditTarget;
			end
		end

		sequenceSettingsUI.Target = target;
		caller.TitleBar.Title.Text = "Sequence settings " .. target:Index() .. " \'" .. target.Name .. "\'";
		caller.Visible = true;

		-- adjusted to the display size
		local disp = caller:GetDisplay();
		if (disp.AbsRect.w > 1440 and disp.AbsRect.h > 900) then
			caller.W = 1200;
			caller.H = 600;
		else
			caller.W = math.ceil(disp.AbsRect.w * 0.9);
			caller.H = math.ceil(disp.AbsRect.h * 0.9);
		end

		caller:Changed();
	end
end

signalTable.LoadFromDefault = function(caller)
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Frame.ObjectSettings;
 if (pbPlaceholder) then
	 local sequenceSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (sequenceSettingsUI) then
		sequenceSettingsUI.LoadFromDefault();
	 end
 end
end

signalTable.SaveToDefault = function(caller)
 local main = caller:GetOverlay();
 local pbPlaceholder = main.Frame.ObjectSettings;
 if (pbPlaceholder) then
	 local sequenceSettingsUI = pbPlaceholder:GetUIChild(1);
	 if (sequenceSettingsUI) then
		sequenceSettingsUI.SaveToDefault();
	 end
 end
end