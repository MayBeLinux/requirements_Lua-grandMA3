local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local indexTemporaryWindowSettings  = 10;
local indexCloningWindowSettings    = 14;
local settings = nil;
local DependenciesBtn = nil;

-- Signal
signalTable.OnLoad = function(caller,status,creator)    

    local overlay = nil;
	local window = caller:FindParent("Window");
	if (window) then
	    settings = window.WindowSettings;
	else
	    local temporaryWindowSettings = CurrentProfile():Ptr(indexTemporaryWindowSettings);
	    settings = temporaryWindowSettings:Ptr(indexCloningWindowSettings);

		overlay = caller:FindParent("CloneOverlay");
		if (overlay) then
		    DependenciesBtn = overlay.TitleBar.TitleButtons.DependenciesBtn;
		end

	end

	caller.CloneSourceGrid = caller.DialogFrame.Frame.LeftSide.FixtureAreaLeft.FixtureGridLeft;
	caller.CloneDestinationGrid = caller.DialogFrame.Frame.RightSide.FixtureAreaRight.FixtureGridRight;

	caller.CloneSourceGrid.ScrollBuddy = caller.CloneDestinationGrid;
	caller.CloneDestinationGrid.ScrollBuddy = caller.CloneSourceGrid;

	if (settings) then
        local cloneBtn = caller.DialogFrame.Bottom.Right.Clone;
        HookObjectChange(signalTable.SheetSettingsHookCloneEnabled,  settings, my_handle:Parent(), cloneBtn);
		signalTable.SheetSettingsHookCloneEnabled(settings, nil, cloneBtn);
	    cloneBtn.Enabled = settings.GetEnableClone;
		
		--local fillUpBtn = caller.DialogFrame.Frame.LeftSide.FixtureAreaLeft.LeftBottomToolbar.FillUpLeft;
        --HookObjectChange(signalTable.SheetSettingsHookFillUpLeftEnabled,  settings, my_handle:Parent(), fillUpBtn);
	    --fillUpBtn.Enabled = settings.GetFillUp;
		--fillUpBtn = caller.DialogFrame.Frame.RightSide.FixtureAreaRight.RightBottomToolbar.FillUpRight;
        --HookObjectChange(signalTable.SheetSettingsHookFillUpRightEnabled,  settings, my_handle:Parent(), fillUpBtn);
	    --fillUpBtn.Enabled = settings.GetFillUp;

		--local unifyBtn = caller.DialogFrame.Frame.LeftSide.FixtureAreaLeft.LeftBottomToolbar.UnifyLeft;
        --HookObjectChange(signalTable.SheetSettingsHookUnifyLeftEnabled,  settings, my_handle:Parent(), unifyBtn);
	    --unifyBtn.Enabled = settings.GetUnify;
		--unifyBtn = caller.DialogFrame.Frame.RightSide.FixtureAreaRight.RightBottomToolbar.UnifyRight;
        --HookObjectChange(signalTable.SheetSettingsHookUnifyRightEnabled,  settings, my_handle:Parent(), unifyBtn);
	    --unifyBtn.Enabled = settings.GetUnify;

	    local seqBtn = caller.DialogFrame.Frame.RightSide.Toolbar.Sequences;
	    local groupBtn = caller.DialogFrame.Frame.RightSide.Toolbar.Groups;
	    local presetsBtn = caller.DialogFrame.Frame.RightSide.Toolbar.Presets;
	    local worldsBtn = caller.DialogFrame.Frame.RightSide.Toolbar.Worlds;
	    local layBtn = caller.DialogFrame.Frame.RightSide.Toolbar.Layouts;

	    HookObjectChange(signalTable.SheetSettingsHookSeqFilter,  settings, my_handle:Parent(), seqBtn);
	    HookObjectChange(signalTable.SheetSettingsHookGroupFilter,  settings, my_handle:Parent(), groupBtn);
	    HookObjectChange(signalTable.SheetSettingsHookPresetFilter,  settings, my_handle:Parent(), presetsBtn);
	    HookObjectChange(signalTable.SheetSettingsHookWorldFilter,  settings, my_handle:Parent(), worldsBtn);
	    HookObjectChange(signalTable.SheetSettingsHookLayoutFilter,  settings, my_handle:Parent(), layBtn);

	    signalTable.SheetSettingsHookSeqFilter(settings, nil, seqBtn);
	    signalTable.SheetSettingsHookGroupFilter(settings, nil, groupBtn);
	    signalTable.SheetSettingsHookPresetFilter(settings, nil, presetsBtn);
	    signalTable.SheetSettingsHookWorldFilter(settings, nil, worldsBtn);
	    signalTable.SheetSettingsHookLayoutFilter(settings, nil, layBtn);
	end
	if overlay then
	    overlay:InitFirst();
	end
end

signalTable.SheetSettingsHookCloneEnabled = function(settings, dummy, caller)
    caller.Enabled = settings.GetEnableClone;	
	if settings.HasSequenceFilter or settings.HasGroupFilter or settings.HasPresetFilter or settings.HasWorldFilter or settings.HasLayoutFilter then
	    if settings.AllSequenceItems and settings.AllGroupItems and settings.AllPresetItems and settings.AllWorldItems and settings.AllLayoutItems then
	        caller.ColorIndicator = "CloneUI.All"
			caller.Text = "Clone\nShow"
		else
		    caller.ColorIndicator = "CloneUI.Chosen"
			caller.Text = "Clone\nSelected Objects"
	    end
		if (DependenciesBtn) then
		    DependenciesBtn.Enabled = true;
	    end
	else
	    caller.ColorIndicator = "CloneUI.None"
		caller.Text = "Clone\nProgrammer"
		if (DependenciesBtn) then
		    DependenciesBtn.Enabled = false;
	    end
	end

end

signalTable.SheetSettingsHookUnifyLeftEnabled = function(settings, dummy, caller)
    caller.Enabled = settings.GetEnableUnifyLeft;		
end

signalTable.SheetSettingsHookUnifyRightEnabled = function(settings, dummy, caller)
    caller.Enabled = settings.GetEnableUnifyRight;		
end

signalTable.SheetSettingsHookFillUpLeftEnabled = function(settings, dummy, caller)
    caller.Enabled = settings.GetEnableFillUpLeft;		
end

signalTable.SheetSettingsHookFillUpRightEnabled = function(settings, dummy, caller)
    caller.Enabled = settings.GetEnableFillUpRight;		
end

signalTable.SheetSettingsHookSeqFilter = function(settings, dummy, caller)
    
    if settings.HasSequenceFilter then
	    if settings.AllSequenceItems then
	        caller.Text = "All\nSequences"
			caller.ColorIndicator = "CloneUI.All"
		else
		    caller.Text = "Chosen\nSequences"
			caller.ColorIndicator = "CloneUI.Chosen"
	    end
	else
	    caller.Text = "No\nSequences"
		caller.ColorIndicator = "CloneUI.None"
	end
end

signalTable.SheetSettingsHookGroupFilter = function(settings, dummy, caller)
    
    if settings.HasGroupFilter then
	    if settings.AllGroupItems then
	        caller.Text = "All\nGroups"
			caller.ColorIndicator = "CloneUI.All"
		else
		    caller.Text = "Chosen\nGroups"
			caller.ColorIndicator = "CloneUI.Chosen"
	    end
	else
	    caller.Text = "No\nGroups"
		caller.ColorIndicator = "CloneUI.None"
	end
end

signalTable.SheetSettingsHookPresetFilter = function(settings, dummy, caller)
  
    if settings.HasPresetFilter then
	    if settings.AllPresetItems then
	        caller.Text = "All\nPresets"
			caller.ColorIndicator = "CloneUI.All"
		else
		    caller.Text = "Chosen\nPresets"
			caller.ColorIndicator = "CloneUI.Chosen"
	    end
	else
	    caller.Text = "No\nPresets"
		caller.ColorIndicator = "CloneUI.None"
	end
end

signalTable.SheetSettingsHookWorldFilter = function(settings, dummy, caller)
    
    if settings.HasWorldFilter then
	    if settings.AllWorldItems then
	        caller.Text = "All\nWorlds"
			caller.ColorIndicator = "CloneUI.All"
		else
		    caller.Text = "Chosen\nWorlds"
			caller.ColorIndicator = "CloneUI.Chosen"
	    end
	else
	    caller.Text = "No\nWorlds"
		caller.ColorIndicator = "CloneUI.None"
	end
end

signalTable.SheetSettingsHookLayoutFilter = function(settings, dummy, caller)    

    if settings.HasLayoutFilter then
	    if settings.AllLayoutItems then
	        caller.Text = "All\nLayouts"
			caller.ColorIndicator = "CloneUI.All"
		else
		    caller.Text = "Chosen\nLayouts"
			caller.ColorIndicator = "CloneUI.Chosen"
	    end
	else
	    caller.Text = "No\nLayouts"
		caller.ColorIndicator = "CloneUI.None"
	end
end

signalTable.OnModeChanged = function (caller, dummy, ButtonValue, idx)
	local cloningDialog = caller:FindParent("CloningDialog");
	cloningDialog:ChangeCloningViewMode();
end


--signalTable.OnSheetModeLoaded = function(caller,status,creator)
--  if (settings) then
--	    caller.Target = settings;

--	    if (caller.Name == "WindowModeRight") then
--	        caller.Property="WindowModeRight";
--	    else
--	        caller.Property="WindowModeLeft";
--      end
--	end
--end

signalTable.UseSettingsTarget = function(caller)
	
    if (settings) then
	    caller.Target = settings;
	else
	    local temporaryWindowSettings = CurrentProfile():Ptr(indexTemporaryWindowSettings);
	    caller.Target = temporaryWindowSettings:Ptr(indexCloningWindowSettings);
	end

end

signalTable.DoReset = function(caller)
	
    local cloningOverlay = caller:FindParent("Overlay");
    if cloningOverlay then 
	    cloningOverlay:DoReset();

		cloningOverlay.Content.CloningDialog.DialogFrame.Frame.LeftSide.FixtureAreaLeft.FixtureGridLeft:ReTriggerInit();
	    cloningOverlay.Content.CloningDialog.DialogFrame.Frame.RightSide.FixtureAreaRight.FixtureGridRight:ReTriggerInit();

	end

end


signalTable.OnAddSelection = function(caller)

    local cloningDialog = caller:FindParent("CloningDialog");	
    local grid;	

    if (caller.Name == "AddSelectionLeft") then
	    grid = cloningDialog.CloneSourceGrid
	else
	    grid = cloningDialog.CloneDestinationGrid
	end

	local subfixture_index=SelectionFirst(true);
	local selected = subfixture_index ~= nil;

	if (selected) then
       grid:AddSelectedFixtures();
    end

	grid:ReTriggerInit();
end

signalTable.OnClearList = function(caller)
	
    local cloningDialog = caller:FindParent("CloningDialog");	
    local grid;	

    if (caller.Name == "ClearListLeft") then
	    grid = cloningDialog.CloneSourceGrid
	else
	    grid = cloningDialog.CloneDestinationGrid
	end

	grid:ClearGrid();
	grid:ReTriggerInit();
end


signalTable.OnClone = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:DoClone();
end

signalTable.OnSequenceFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenSequenceFilter();
end

signalTable.OnGroupFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenGroupFilter();
end

signalTable.OnPresetFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenPresetFilter();
end

signalTable.OnWorldFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenWorldFilter();
end

signalTable.OnLayoutFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenLayoutFilter();
end

signalTable.OnCopy = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	grid:GridCopy();

end

signalTable.OnPaste = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	grid:GridPaste();
	grid:ReTriggerInit();
end

signalTable.OnCut = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	grid:GridCut();
	grid:ReTriggerInit();
end

signalTable.OnAdd = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	grid:GridAdd();
	grid:ReTriggerInit();
end

signalTable.OnDelete = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	grid:GridDelete();
	grid:ReTriggerInit();
end

signalTable.OnMoveUp = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	if (grid:GridMoveUp()) then
	    grid:ReTriggerInit();
    end
end

signalTable.OnMoveDown = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (cloningDialog.CloneSourceGrid.HasFocus) then
	    grid = cloningDialog.CloneSourceGrid		
	else
	    grid = cloningDialog.CloneDestinationGrid		
	end

	if (grid:GridMoveDown()) then
	    grid:ReTriggerInit();
    end

end

signalTable.OnAllItemsToAll = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:AllItemsToAll();
end

signalTable.OnAllItemsToNone = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:AllItemsToNone();
end

signalTable.OnUnify = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (caller.Name == "UnifyLeft") then
	    grid = cloningDialog.CloneSourceGrid
	else
	    grid = cloningDialog.CloneDestinationGrid
	end

	grid:GridUnify();	
end

signalTable.OnFillUp = function(caller)	
    
    local cloningDialog = caller:FindParent("CloningDialog");	
	local grid;	

    if (caller.Name == "FillUpLeft") then
	    grid = cloningDialog.CloneSourceGrid
	else
	    grid = cloningDialog.CloneDestinationGrid
	end

	grid:GridFillUp();
	grid:ReTriggerInit();
end

signalTable.OnOverlayVisible = function(caller,status,creator)

    local temporaryWindowSettings = CurrentProfile():Ptr(indexTemporaryWindowSettings);
	local SettingsObj = temporaryWindowSettings:Ptr(indexCloningWindowSettings);
    if SettingsObj then
        local cloningOverlay = caller:FindParent("Overlay");
        if cloningOverlay then 
	         cloningOverlay.Content.CloningDialog:InitTargetList();
	    end
	end
end

signalTable.OnFlipLeftRight = function(caller,status,creator)
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:FlipLeftRight();
end

signalTable.OnFocusSourceGrid = function(caller,status,creator)
    
end

signalTable.OnFocusDestGrid = function(caller,status,creator)
    
end

signalTable.OnAtFilter = function(caller)	
    local cloningDialog = caller:FindParent("CloningDialog");	
	cloningDialog:OpenAtFilter();
end