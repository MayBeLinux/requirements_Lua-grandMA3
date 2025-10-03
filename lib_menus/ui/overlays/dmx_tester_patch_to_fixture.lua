local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LoadLiveFixturePatchData = function(caller, str, context)
	caller:WaitInit();

	local patch_settings=CurrentProfile().TemporaryWindowSettings.PatchLiveSettings;
	local stageBtn = caller.TitleBar.TitleButtons.StageControl;
	stageBtn.Property = "SelectedStage";
	stageBtn.Target = patch_settings;

	local unpatchonlyBtn = caller.TitleBar.TitleButtons.UnPatchedOnly;
	unpatchonlyBtn.Property = "ShowUnpatchedOnly";
	unpatchonlyBtn.Target = caller;

	local fix_grid = caller.FixturesGrid
	local gridSettings = fix_grid:GridGetSettings();
	fix_grid.ClearFilter();

	HookObjectChange(signalTable.PatchSettingsChanged, patch_settings, my_handle:Parent(), caller);
	signalTable.PatchSettingsChanged(patch_settings, 0, caller);
end

signalTable.PatchSettingsChanged = function(patchSettings, _, patchToOverlay)
	local livePatch = ShowData().LivePatch;
	local fix_grid = patchToOverlay.FixturesGrid
	local gridSettings = fix_grid:GridGetSettings();

	local currentDest = CmdObj().Destination;
	local selStage = StrToHandle(gridSettings:Get("SelectedStage", Enums.Roles.Edit));
	local shouldBeTarget = nil;
	if (IsObjectValid(selStage) == true) then
		shouldBeTarget = selStage.Fixtures;
		if (changeDir and shouldBeTarget ~= currentDest) then
			Cmd("cd Root "..livePatch:Addr());
			Cmd("cd "..selStage:Addr(livePatch));
            Cmd("cd \"Fixtures\"");
		end
	else--all stages 
		shouldBeTarget = livePatch.Stages;
		if (changeDir and shouldBeTarget ~= currentDest) then
			Cmd("cd Root "..livePatch:Addr());
			Cmd("cd \"Stages\"");
		end
	end

	fix_grid.TargetObject = shouldBeTarget;

	patchSettings.ShowFilterToolbar = "Yes";
	fix_grid.AllowFilterContent = "Yes";
end