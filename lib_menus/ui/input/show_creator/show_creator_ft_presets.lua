local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local overlay;
local kIllegalIndex = 4294967295;
local ActiveFilter = false;
local progBar = nil;
local hookId = {};
local currentStage = nil;


-- --------------------------------------------------------
--
-- --------------------------------------------------------
local function UnhookAll()
    for _,id in ipairs(hookId) do
        Unhook(id);
    end
    hookId = {};
end

local function endProg()
    if (progBar) then
        StopProgress(progBar);
    end
end

local function startProg(text)
    endProg()
    progBar = StartProgress(" ");
    SetProgressText(progBar, text)
    SetProgressRange(progBar,0,0)
    SetProgress(progBar, 0)
    coroutine.yield()
end

-- ---------------------- AUTOSTORE & AUTOCREATE FUNCTIONS ----------------------------
signalTable.StoreOrCreateFTPresets = function(caller,status)
    if(status == "Store") then
        signalTable.StoreFTPresets(caller);
    else
        signalTable.AutocreateFTPresets(caller);
    end

    -- CmdIndirect("Collect");
end

signalTable.StoreFTPresets = function(caller)
    local settings = overlay.Settings;
    local cmdO = CmdObj();
    local grPreset = overlay.Content.LocalArea.Frame.LocalGrid;
    local frameSelectionIndexPreset = grPreset:GridGetData().CreateFrameSelection(cmdO);
    local gr = overlay.Content.FixtureArea.Frame.FixtureGrid;
    local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);

    if (frameSelectionIndex > 0) then
        local cmd = "";
        if(settings.Advanced) then
            if(settings.SheetStyle and frameSelectionIndexPreset > 0) then
                cmd = "AutoStore _FrameSelection " .. tostring(frameSelectionIndexPreset) .. " at _FrameSelection "..tostring(frameSelectionIndex)
            else
                local UserProfile=CurrentProfile();
                local collection = UserProfile.Collection.IndexesSorted;
                if(collection[1] ~= nil) then
                    cmd = "AutoStore Collection at _FrameSelection "..tostring(frameSelectionIndex)
                else
                    cmd = "AutoStore Preset " .. settings.SubPoolSelectorValue+1 .. ".* at _FrameSelection "..tostring(frameSelectionIndex)
                end
            end
        else
            cmd = "AutoStore _FrameSelection "..tostring(frameSelectionIndex)
        end
        CmdIndirect(cmd);
    end
end

signalTable.AutocreateFTPresets = function(caller)
    local settings = overlay.Settings;
    local cmdO = CmdObj();
    local gr = overlay.Content.FixtureArea.Frame.FixtureGrid;
    if(settings.Advanced) then
        if(settings.UseChannelSet and overlay.Content.ChannelSetArea) then
            gr = overlay.Content.ChannelSetArea.Frame.ChannelSetGrid;
        else
            gr = overlay.Content.FTPresetArea.Frame.FTPresetGrid;
        end
    end

    local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);

    if (frameSelectionIndex > 0) then
        local cmd = "";
        if(settings.Advanced) then
            local UserProfile=CurrentProfile();
            local collection = UserProfile.Collection.IndexesSorted;
            if(collection[1] ~= nil) then
                cmd = "Autocreate _FrameSelection "..tostring(frameSelectionIndex).." at Collection"
            else
                cmd = "Autocreate _FrameSelection "..tostring(frameSelectionIndex).." at Preset *"
            end
        else
            local option = "";
            if(settings.UseChannelSet and overlay.Content.ChannelSetArea) then 
                option = " /ChannelSet"
            end
            cmd = "Autocreate _FrameSelection "..tostring(frameSelectionIndex).." at Preset *" .. option;
        end
        CmdIndirect(cmd);
    end
end
-- ---------------------- GENERAL FUNCTIONS ----------------------------
local function collectionToCmdString(cmd, collection, selCount)
    local lastIdx = 0;
    local colCount = #collection;

    cmd = cmd .. " At "
    for i,d in ipairs(collection) do
        if(i > selCount) then
            break;
        end
        lastIdx = d;
        if(i < colCount and i < selCount) then
            cmd = cmd .. tostring(lastIdx) .. " + "
        else
            cmd = cmd .. tostring(lastIdx)
        end
    end
    return cmd, lastIdx;
end

signalTable.ClearCollection = function(caller)
    local settings = overlay.Settings;
    if(settings.SheetStyle) then
        caller:Parent():Parent().Frame.LocalGrid:ClearSelection()
    else
        CmdIndirect("Collect");
    end
end



signalTable.OnMenuLoaded = function(caller)
    caller:WaitInit(1);
    caller:HookDelete(endProg)
    overlay = caller;
    if(overlay.Content) then
        currentStage = nil;
        local settings = overlay.Settings;
    --	local gr = caller.Content.FixtureArea.Frame.FixtureGrid;
    --	gr.OnSelectedItem = "";	
        UnhookAll();
        local window = overlay.Content.LocalArea.Frame.PoolWindowPlace.PoolWindow;
        local settingsHookID = HookObjectChange(signalTable.OnSettingsChanged,	settings,	my_handle:Parent());
        local windowHookID = HookObjectChange(signalTable.OnWindowChanged,	window,	my_handle:Parent());
        table.insert(hookId, settingsHookID);
        table.insert(hookId, windowHookID);
    
        if(settings.SubPoolSelectorValue == kIllegalIndex) then
            settings.SubPoolSelectorValue = 0;
        end

        signalTable.OnCustomMenuLoaded(overlay);


        signalTable.OnWindowChanged(window);
        signalTable.OnSettingsChanged(settings, true);


        HookObjectChange(signalTable.OnPatchChanged,        -- 1. function to call
            ShowData().LivePatch,	-- 2. object to hook
            my_handle:Parent(),    -- 3. plugin object ( internally needed )
            window);               -- 4. user callback parameter

    end
end

signalTable.OnPatchChanged = function(settings, onLoad)
    signalTable.OnFixtureSelected();
end

signalTable.OnCustomMenuLoaded = function(overlay)
    -- NOTHING
end

signalTable.OnSettingsChanged = function(settings, onLoad)
    if(overlay.Content) then
        if(settings.SheetStyle) then
            overlay.Content.LocalArea.Frame.PoolWindowPlace.Visible = false;
            overlay.Content.LocalArea.Frame.LocalGrid.Visible = true;
        else
            overlay.Content.LocalArea.Frame.PoolWindowPlace.Visible = true;
            overlay.Content.LocalArea.Frame.LocalGrid.Visible = false;
        end

        --overlay.TitleBar.Title.Text = overlay.Name .. " " .. DestinationObject.Name;
        if(overlay.Content.FixtureArea) then
            local stageSelector = overlay.Content.FixtureArea.FixtureSubTitle.StageSelect;
            if(settings.FixtureGrid) then
                stageSelector.Visible = true;
                if(currentStage == nil) then
                    currentStage = Patch().Stages[1];
                end
                overlay.Content.FixtureArea.Frame.FixtureGrid.TargetObject = currentStage.Fixtures;
                overlay.Content.FixtureArea.Frame.FixtureGrid.LevelLimit="255";
            else
                stageSelector.Visible = false;
                overlay.Content.FixtureArea.Frame.FixtureGrid.TargetObject = Patch().FixtureTypes;
                overlay.Content.FixtureArea.Frame.FixtureGrid.LevelLimit="2";
            end

            if(settings.FixtureGrid) then
                overlay.Content.FixtureArea.FixtureSubTitle.Title.Text = "Fixtures";
            else
                overlay.Content.FixtureArea.FixtureSubTitle.Title.Text = "FixtureTypes";
            end
        end

        signalTable.AdjustVisibilityAndSize();


        local type = "";
        if(settings.Advanced) then
            type = "." .. settings.DestinationObject.Name;
        end
        if(overlay.TitleBar) then
            if(settings.LastSelectedTab == "AutoStorePresets") then
                overlay.TitleBar.Title.Text = "Store Presets" .. type .. " to FixtureType";
                overlay.HelpTopic = "sc_fixture_type_presets.html";
            elseif(settings.LastSelectedTab == "AutoCreatePresets") then
                overlay.TitleBar.Title.Text = "Create Presets" .. type .. " from FixtureType";
                overlay.HelpTopic = "sc_autocreate_groups.html";
            end
        end
        signalTable.OnFixtureSelected();
    end
end

signalTable.AdjustVisibilityAndSize = function()
    local settings = overlay.Settings;
    local columnCount = 2;
    if(overlay.Content.FTPresetArea and settings.Advanced) then
        columnCount = 3;
    end

    local gr = overlay.Content.FixtureArea.Frame.FixtureGrid;
    if(settings.Advanced) then
        if(settings.LastSelectedTab ~= "AutoStorePresets") then
            gr.SelectionType = "SingleRowGridSelection";
        end
        overlay.Content.LocalArea.Visible = "Yes";
        overlay.Content.AtFilterArea.Visible = "No";
        if(settings.UseChannelSet and overlay.Content.ChannelSetArea) then        
            overlay.Content.FTPresetArea.Visible="No";
            overlay.Content.ChannelSetArea.Visible="Yes";
        else
            overlay.Content.FTPresetArea.Visible="Yes";
            if(overlay.Content.ChannelSetArea) then
                overlay.Content.ChannelSetArea.Visible="No";
            end
        end
        overlay.Content.LocalArea.w = (overlay.Content.AbsRect.w ) / columnCount;
        overlay.Content.FTPresetArea.w = overlay.Content.LocalArea.w;
        if(overlay.Content.ChannelSetArea) then
            overlay.Content.ChannelSetArea.w = overlay.Content.LocalArea.w;
        end
    else
        gr.SelectionType = "ColumnGridSelection";
        overlay.Content.LocalArea.Visible = "No";
        overlay.Content.AtFilterArea.Visible = "Yes";
        overlay.Content.FTPresetArea.Visible="No";
        if(overlay.Content.ChannelSetArea) then
            overlay.Content.ChannelSetArea.Visible="No";
        end
    end
    overlay:OnCheckSubPoolSelector();
    
    if(overlay.Content) then
        signalTable.OnLocalGridLoaded(overlay.Content.LocalArea.Frame.LocalGrid);
        local atFilterWidth = 300;
        if(settings.ExpandAtFilter) then
            overlay.Content.AtFilterArea.Container.Box.AtFilter.FeatureGroupsOnly = "No";
            overlay.Content.AtFilterArea.FixtureSubTitle.ExpandBtn.Icon = "triangle_left"
            atFilterWidth =  (overlay.Content.AbsRect.w ) / 2;
        else
            overlay.Content.AtFilterArea.Container.Box.AtFilter.FeatureGroupsOnly = "Yes";
            overlay.Content.AtFilterArea.FixtureSubTitle.ExpandBtn.Icon = "triangle_right"
        end

        overlay.Content.AtFilterArea.W = atFilterWidth;
    end
end

signalTable.UseSettingsTarget = function(caller)
    caller:WaitInit(1);
    caller.Target = overlay.Settings;
end

signalTable.LinkSCSettings = function(caller)
    if(caller.Internals.GridBase.ShowCreatorSheetSettings) then
        caller.Internals.GridBase.ShowCreatorSheetSettings.ShowCreatorSettings = overlay.Settings;
    end
end

signalTable.UseOverlayTarget = function(caller)
    caller.Target = overlay;
end
 
signalTable.JumpToGrid = function(caller)
    FindNextFocus();
end

-- ---------------------- POOL WINDOW ----------------------------
--signalTable.PoolWindowLoaded = function(caller,status,creator)	
--	signalTable.OnSettingsChanged(overlay.Settings);
--end

signalTable.OnWindowChanged = function(window)
    if(overlay.Content.LocalArea.LocalSubTitle.CollectAll ~= nil) then
        if(window.AllIndexesCollected) then
            overlay.Content.LocalArea.LocalSubTitle.CollectAll.Text = "Uncollect\nall";
        else
            overlay.Content.LocalArea.LocalSubTitle.CollectAll.Text = "Collect\nall";
        end
    end
end

-- ---------------------- SUBPOOL SELECTOR ----------------------------
signalTable.OnSubPoolChanged = function(caller,status,creator)
    local settings = overlay.Settings;
    settings.SubPoolSelectorValue = status;
    settings.SubPoolSelectorIndex = caller.SelectedItemIdx;
    if(overlay.Content.FTPresetArea) then
        overlay.Content.FTPresetArea.Frame.FTPresetGrid.Internals.GridBase.ShowCreatorSheetSettings.ShowCreatorGridObjectContentFilter.Filter:Changed();
    end
    if(overlay.Content.ChannelSetArea) then
        overlay.Content.ChannelSetArea.Frame.ChannelSetGrid.Internals.GridBase.ShowCreatorSheetSettings.ShowCreatorGridObjectContentFilter.Filter:Changed();
    end
    
    signalTable.AdjustVisibilityAndSize();
    CmdIndirect("Collect");
end

signalTable.SetSubPoolSelectorTarget = function()
    if(overlay.Content.SubPoolSelector) then
        local selectedDataPool = signalTable.GetSelectedDataPool();
        local newTarget = selectedDataPool.PresetPools;
        if(newTarget ~= overlay.Content.SubPoolSelector.Target) then
            overlay.Content.SubPoolSelector.Target = newTarget;
        end
    end
end

-- ---------------------- LOCAL GRID ----------------------------
signalTable.OnLocalGridLoaded = function(caller,status,creator)
    local dataPool = signalTable.GetSelectedDataPool();
    local presetPools = dataPool.PresetPools;
    local newTarget = presetPools[overlay.Settings.SubPoolSelectorValue+1];
    if(caller.TargetObject ~= newTarget) then
        caller.TargetObject=newTarget;
    end
end


signalTable.OnLocalGridSelectionChanged = function(grid)
    local window = grid:Parent().Frame.PoolWindowPlace.PoolWindow;
    window.AllIndexesCollected = false;
    overlay.Content.LocalArea.LocalSubTitle.CollectAll.Text = "Collect\nall";
end

-- ---------------------- DATAPOOL SELECTOR ----------------------------
signalTable.OnDataPoolLoaded = function(caller,status,creator)
    caller.Target=Root().ShowData.DataPools;
    signalTable.SetSubPoolSelectorTarget();
end

signalTable.OnDataPoolChanged = function(caller,status,creator)
    overlay:OnSelectDataPool();
    signalTable.OnSettingsChanged(overlay.Settings);
    signalTable.SetSubPoolSelectorTarget();
end

signalTable.GetSelectedDataPool = function()
    local selectedDataPool;
    if(overlay.Content.LocalArea.LocalSubTitle.DataPoolSelector.SelectedItemValueI64 >= 0) then
        selectedDataPool = IntToHandle(overlay.Content.LocalArea.LocalSubTitle.DataPoolSelector.SelectedItemValueI64)
    else
        selectedDataPool = CurrentProfile().SelectedDataPool;
    end
    return selectedDataPool;
end

-- ---------------------- FIXTURE GRID ----------------------------
signalTable.OnStageChanged = function(caller,status,stageH)
    currentStage = IntToHandle(stageH);
    overlay.Content.FixtureArea.Frame.FixtureGrid.TargetObject=currentStage.Fixtures;
end

signalTable.StageSelectorLoaded = function(caller,status,creator)
    caller.Target=Patch().Stages;
    caller:SelectListItemByIndex(1);
end

signalTable.OnFixtureSelected= function(caller,status,creator)
    if(overlay.Content) then
        if(overlay.Content.FTPresetArea) then
            local FTPresets = StrToHandle(overlay.FTPresetCollect);
            if(FTPresets) then
                overlay:SetFTPresetGridTarget();
                overlay.Content.FTPresetArea.Frame.FTPresetGrid:SelectAllRows();
                overlay.Content.FTPresetArea.FTPresetSubTitle.Title.Text = FTPresets:Parent():Parent():Parent().Name .. ": FixtureType Presets";
            end

        end
        if(overlay.Content.ChannelSetArea) then
            local FTPresets = StrToHandle(overlay.FTPresetCollect);
            if(FTPresets) then
                overlay:SetChannelSetGridTarget();
                overlay.Content.ChannelSetArea.Frame.ChannelSetGrid:SelectAllRows();
                    overlay.Content.ChannelSetArea.ChannelSetSubTitle.Title.Text = FTPresets:Parent():Parent():Parent().Name .. ": ChannelSets";
            end
        end
    end
end