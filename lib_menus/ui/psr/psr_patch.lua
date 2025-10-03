local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller)


	HookObjectChange(signalTable.OnSettingsChanged,	caller.Settings, my_handle:Parent(), caller);
	signalTable.mainDialog = caller;
	signalTable.OnSettingsChanged(caller.Settings, nil, caller);
	local root=Root();
	caller.Content.PSRGrid.PSRSubTitle.PsrSubTitleText.Text = "PSR Patch: " ..root.Temp.ConvertTask.ShowfileName;
	caller.Content.LocalGrid.LocalSubTitle.LocalSubTitleText.Text = "Local Running Patch: " .. root.ManetSocket.Showfile .. ".show";
end

signalTable.OnSettingsChanged = function(settings, dummy, overlay)
	local filters = {
		{ settingsVar = overlay.Settings.StageFilter,       button = overlay.Content.FilterBlock.Stage },
		{ settingsVar = overlay.Settings.FilterType,        button = overlay.Content.FilterBlock.FilterType },
		{ settingsVar = overlay.Settings.LayerFilter,       button = overlay.Content.FilterBlock.Layer },
		{ settingsVar = overlay.Settings.ClassFilter,       button = overlay.Content.FilterBlock.Class },
		{ settingsVar = overlay.Settings.FixtureTypeFilter, button = overlay.Content.FilterBlock.FixtureType },
	}

	overlay.Content.PSRGrid.PSRPatchGrid:GridGetBase():Changed();
	overlay.Content.LocalGrid.LocalPatchGrid:GridGetBase():Changed();

	for i = 1, #filters do
	    if(filters[i]["settingsVar"] ~= "None") then
			filters[i]["button"].ColorIndicator = "Filter.ActiveIcon"
		else
			filters[i]["button"].ColorIndicator = "IndicatorControl.ColorIndicator"
		end
    end
end

signalTable.AllToLocal = function(caller)
	signalTable.mainDialog:SetAllToLocal();
end

signalTable.AllToPsr = function(caller)
	signalTable.mainDialog:SetAllToPsr();
end

signalTable.MergeLocal = function(caller)
	signalTable.mainDialog:MergeLocal();
end

signalTable.MergePSR = function(caller)
	signalTable.mainDialog:MergePsr();
end

signalTable.ChooseLocal = function(caller)
	signalTable.mainDialog:ChooseLocal();
end

signalTable.ChooseNone = function(caller)
	signalTable.mainDialog:ChooseNone();
end

signalTable.ChoosePsr = function(caller)
	signalTable.mainDialog:ChoosePsr();
end

signalTable.ChooseSelected = function(caller)
	signalTable.mainDialog:ChooseSelected();
end

signalTable.ToggleSelected = function(caller)
	signalTable.mainDialog:ToggleSelected();
end

signalTable.Reset = function(caller)
	signalTable.mainDialog:ResetFixtureMatch();
end

signalTable.Proceed = function(caller)

    local overlay = caller:GetOverlay();
	local parentDialog = overlay:Parent():Parent();
    parentDialog.PsrMenu.SubTabs:SelectListItemByIndex(3)

	local ct=Root().Temp.ConvertTask;
	ct:OnRunConversion();
end

signalTable.UseSettingsTarget = function(caller)
	caller.Target = signalTable.mainDialog.Settings;
end

signalTable.SetFilter = function(caller)
	signalTable.mainDialog:CreateFilterLists();
	caller.Target = signalTable.mainDialog.Settings;
end

signalTable.ResetFilters = function(caller)
	signalTable.mainDialog.Settings:ResetFilters();
end