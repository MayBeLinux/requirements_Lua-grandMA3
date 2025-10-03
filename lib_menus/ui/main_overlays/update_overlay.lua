local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnSavePreferences = function(caller)
--global call
	SaveStorePreferencesToProfile();
end

signalTable.OnLoadPreferences = function(caller)
--global call
	LoadStorePreferencesFromProfile();
end

local function OnUserProfileChanged(up, dummy, ui)
	ui.MainDlg.PresetLayoutGrid.PresetExtendedOptions.Visible = up.UpdateMenuPresetOptionsExpanded
	ui.MainDlg.CueLayoutGrid.CueExtendedOptions.Visible = up.UpdateMenuCueOptionsExpanded
end

local function TempStoreSetttingsChanged(settings, dummy, ui)
    local presetDetails = ui.MainDlg.PresetLayoutGrid.PresetHeader.PresetHeaderDetails
    local cueDetails = ui.MainDlg.CueLayoutGrid.CueHeader.CueHeaderDetails

    presetDetails.PresetModeBlock.PresetModeSummary.Text = settings.UpdateModePresets
    presetDetails.PresetUpdateModeBlock.PresetUpdateModeSummary.Text = settings.UpdatePresetMode
    if settings.UpdateInputFilter then
	    presetDetails.InputFilterBlock.InputFilterSummary.Text = "Yes"
    else
	    presetDetails.InputFilterBlock.InputFilterSummary.Text = "No"
    end

    cueDetails.SequenceUpdateModeBlock.SequenceUpdateModeSummary.Text = settings.UpdateModeCues
    local cueOperationModeSummary = ""
    local cueOpMode = settings.UpdateCueOperationMode
    if cueOpMode == Enums.CueOperationMode["Cue Only"] then
	    cueOperationModeSummary = "Cue Only"
    else
	    cueOperationModeSummary = "Tracking"
    end
    local ts = settings:Get("UIUpdateTrackingShield", Enums.Roles.Display)
    if  ts ~= "Off" then
	    cueOperationModeSummary = cueOperationModeSummary..", TS: "..ts
    end
    if settings.UpdateDimmerCueOnly == true then
	    cueOperationModeSummary = cueOperationModeSummary.."\nDimmer Cue Only"
    end
    cueDetails.CueUpdateOptionsBlock.CueUpdateOptionsSummary.Text = cueOperationModeSummary
end

local function CueUpdatesChanged(cueUpdates, dummy, ui)
    local cueDetails = ui.MainDlg.CueLayoutGrid.CueHeader.CueHeaderDetails
    cueDetails.SequenceModeBlock.SequenceModeSummary.Text = cueUpdates.FilterMode
end

signalTable.OnLoad = function(caller)
	LoadStorePreferencesFromProfile();
	local cmdline=CmdObj();
	local temp    =CmdObj().TempStoreSettings;
	HookObjectChange(signalTable.UpdateListsChanged,cmdline.PresetUpdates,my_handle:Parent(), caller);
	HookObjectChange(signalTable.UpdateListsChanged,cmdline.CueUpdates   ,my_handle:Parent(), caller);
	HookObjectChange(OnUserProfileChanged,CurrentProfile()   ,my_handle:Parent(), caller);
	OnUserProfileChanged(CurrentProfile(), nil, caller)
	HookObjectChange(TempStoreSetttingsChanged,temp   ,my_handle:Parent(), caller);
	TempStoreSetttingsChanged(temp, nil, caller)
	HookObjectChange(CueUpdatesChanged,cmdline.CueUpdates   ,my_handle:Parent(), caller);
	CueUpdatesChanged(cmdline.CueUpdates, nil, caller)
end

signalTable.UpdateListsChanged = function(caller,dummy,Overlay)
	local cueGrid = Overlay.MainDlg.CueLayoutGrid.CueGrid;
	signalTable.SetCueTargets(cueGrid);
	cueGrid:Changed(); -- needed to clear old entries
end

local function HideDatapoolIfNotNecessary(dbObjectGrid)
	local filters = dbObjectGrid.Internals.GridBase.GridSettings["Column Filters"][1]
	if #ShowData().DataPools:Children() == 1 then
		if filters.DataPoolNo.Visible == true then
			filters.DataPoolNo.Visible=false
			filters.DataPoolName.Visible=false
			dbObjectGrid.AutoFitColumn = dbObjectGrid.AutoFitColumn - 2
		end
	end
end

signalTable.SetPresetTargets = function(caller)
	local collectPresetUpdates = CmdObj().PresetUpdates;
	local collectCueUpdates    = CmdObj().CueUpdates;
	caller.TargetObject=collectPresetUpdates;
	if(collectPresetUpdates:Count()>0 and collectCueUpdates:Count()==0) then
		caller.Focus="InitialFocus";
	end
	HideDatapoolIfNotNecessary(caller)
end

signalTable.SetCueTargets = function(caller)
	local progCueUpdate = CmdObj().CueUpdates;
    local MainDlgUpdateMenu = caller:GetOverlay();
	caller.TargetObject  = progCueUpdate;

	if(progCueUpdate:Count()>0) then
		caller.Focus="InitialFocus";
	end
	
	signalTable.ScrollToSelectedCue(caller)
	HideDatapoolIfNotNecessary(caller)
end

signalTable.ScrollToSelectedCue = function(cueGrid)
	local MainDlgUpdateMenu = cueGrid:GetOverlay();
	local progCueUpdate = CmdObj().CueUpdates;
    local cueTable = progCueUpdate.objectlist;
	local selectedCue = MainDlgUpdateMenu.CurrentUpdateObject;

    for i = 1, #cueTable do
		if cueTable[i] == HandleToInt(selectedCue) then
            cueGrid:ScrollToRow(i);
        end
    end
end

signalTable.SetTargetCueUpdates = function(caller)
	caller.Target = CmdObj().CueUpdates
end

signalTable.OnObjectUpdated = function(caller)
	caller:GetOverlay().CheckAutoClose();
end
