local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local overlay;
local kIllegalIndex = 4294967295;
local UsePool = true;
local ActiveFilter = false;
local DestinationObject = nil;
local progBar = nil;
local hookId = {};


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

-- ---------------------- LOCAL FUNCTIONS ----------------------------
local function UpdateLibrary(o)
    startProg("Update library")
    local cmdO = CmdObj();
    local dest = cmdO.Destination;
    RefreshLibrary(dest);
    endProg()
end

local function CheckOptions()
    local buttons = overlay.Buttons;
    if(buttons ~= nil) then
        local settings = overlay.Settings;
        if(buttons.ButtonsRight.CreateRef) then
            if(settings.ObjectType == "Gobos" or
                    settings.ObjectType == "Images" or
                    settings.ObjectType == "Symbols" or
                    settings.ObjectType == "Videos") then
                buttons.ButtonsRight.CreateRef.Visible = true;
                buttons.ButtonsRight.CreateRef.Text = "Create\nAppearance";
                buttons.ButtonsRight.PlaceholderRight.Anchors="3,1,3,1";
            else
                buttons.ButtonsRight.CreateRef.Visible = false;
                buttons.ButtonsRight.PlaceholderRight.Anchors="2,1,3,1";
            end
        end

        signalTable.OnLocalGridSelected(overlay.Content.LocalArea.Frame.LocalGrid);
    end
end

-- ---------------------- DO IMPORT AND EXPORT ----------------------------

local function GetIndexes()
    local UserProfile=CurrentProfile();

    local selectedIndexString = UserProfile.Collection.Indexes;
    local selectedPairs = string.split(selectedIndexString,",");

    local SelectedIndexes = {};
    for i, currentPair in ipairs(selectedPairs) do
        local splitted = string.split(currentPair,":");
        SelectedIndexes[tonumber(splitted[2])+1] = tonumber(splitted[1]);
    end

    return SelectedIndexes;
end

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

signalTable.DoImport = function(caller)
    local settings = overlay.Settings;
    local cmdO = CmdObj();
    local gr = overlay.Content.HarddriveArea.Frame.LibraryGrid;
    local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);

    if (frameSelectionIndex > 0) then
        local cmd = "Import _FrameSelection "..tostring(frameSelectionIndex);

        local grSel = gr:GridGetSelection();
        local selectedItems = grSel.SelectedItems;
        local selCount = #selectedItems;
        
        if(UsePool) then
            local UserProfile=CurrentProfile();
            local collection = UserProfile.Collection.IndexesSorted;
            if(collection[1] ~= nil) then
                local nElementsLeft = selCount-#collection;
                local lastIdx = 0;
                if(nElementsLeft > 0) then
                    cmd, lastIdx = collectionToCmdString(cmd, collection, selCount);
                    cmd = cmd .. " Thru " .. tostring(lastIdx+nElementsLeft)
                elseif(nElementsLeft < 0) then
                    cmd, lastIdx = collectionToCmdString(cmd, collection, selCount);
                else
                    cmd = cmd .. " At Collection";
                end
            end
        else
            local dest = cmdO.Destination;			
            local destIdx = kIllegalIndex;
            local LocalObj = IntToHandle(overlay.Content.LocalArea.Frame.LocalGrid.SelectedRow);
            if(LocalObj ~= nil) then
                destIdx = LocalObj:Index();
            end
            
            if(destIdx > 0 and destIdx < kIllegalIndex) then
                if((settings.SubPoolSelectorValue ~= kIllegalIndex) or (dest.Name=="Gobos") or (dest.Name=="Images") or (dest.Name=="Symbols")) then
                    cmd = cmd .. " At ".. tostring(ToAddr(dest)) .. "." .. tostring(destIdx); 
                else
                    cmd = cmd .. " At ".. tostring(ToAddr(dest)) .. " " .. tostring(destIdx); 
                end
                if (selCount > 1) then
                    cmd = cmd .. " Thru " .. tostring(destIdx + selCount -1);
                end
            end
        end

        if(settings.CreateReferenceObject == "Yes") then
            cmd = cmd .. " /CreateReferenceObject";
        end

        if(settings.IncludeDependencies == false) then
            cmd = cmd .. " /NoDependencies";
        end

        if(settings.GapsImport == true) then
            cmd = cmd .. " /Gaps 'Yes'";
        else
            cmd = cmd .. " /Gaps 'No'";
        end

        CmdIndirect(cmd);
    end
end

signalTable.DoExport = function(caller)
    local settings = overlay.Settings;
    local cmdO = CmdObj();
    local fileName = overlay.Content.HarddriveArea.Frame.FilterBlock.FilterEdit.Content
    
    local cmd = "Export ";
    if(UsePool == false) then
        local gr = overlay.Content.LocalArea.Frame.LocalGrid;
        local grSel = gr:GridGetSelection();
        local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);
        cmd = cmd .. "_FrameSelection "..tostring(frameSelectionIndex);
    else
        cmd = cmd .. " Collection ";
    end

    if(fileName ~= "") then
        cmd = cmd .. " \'" .. fileName .. "\'"
    end

    if(settings.ObjectType == "Pages" or settings.IncludeDependencies == false) then
        cmd = cmd .. " /NoDependencies";
    end

    if(settings.GapsExport == true) then
        cmd = cmd .. " /Gaps 'Yes'";
    end

    CmdIndirect(cmd);

end

signalTable.ImportExportSelection = function(caller,status)
    startProg(status);

    if(status == "Import") then
        signalTable.DoImport(caller);
    else
        signalTable.DoExport(caller);
    end

    CmdIndirect("Collect");
    endProg();
end


-- ---------------------- GENERAL FUNCTIONS ----------------------------
signalTable.ClearCollection = function(caller)
    local settings = overlay.Settings;
    if(settings.SheetStyle) then
        caller:Parent():Parent().Frame.LocalGrid:ClearSelection()
    else
        CmdIndirect("Collect");
    end
end

signalTable.OnLocalGridSelected = function(caller,status,creator)
    local settings = overlay.Settings;
    local buttons = overlay.Buttons;
    local LocalObj = IntToHandle(caller.SelectedRow);
    local destIdx = 0;
    if(LocalObj ~= nil) then
        destIdx = LocalObj:Index();
    end

    if(settings.ObjectType == "UserProfiles" and destIdx == 1) then
        buttons.ButtonsLeft.ImportBtn.Enabled = false;
    else
        buttons.ButtonsLeft.ImportBtn.Enabled = true;
    end
end


signalTable.OnDriveGridLoaded = function(caller,status,creator)
    caller.TargetObject=CmdObj().Library;
end

signalTable.DriveChange = function(caller,status,driveH,index)
    UpdateLibrary();
end

signalTable.OnMenuLoaded = function(caller)
    --require("gma3_helpers")
    --require"gma3_debug"()
    --debuggee.enterDebugLoop(1)
    DestinationObject = nil;
    caller:WaitInit(1);
    caller:HookDelete(endProg)
    overlay = caller;
    local settings = overlay.Settings;
    settings.GapsImport = true
    settings.GapsExport = false

    signalTable.ChangeObjectTypeVisibility(nil, settings.ObjectTypeValid);
    
    local currentDrive = Root().StationSettings.LocalSettings.SelectedDrive;
    local driveFound = false;
    for i,d in ipairs(Root().Temp.DriveCollect) do
        if (d.Path == currentDrive) then
            caller.Content.HarddriveArea.HarddriveSubTitle.DriveSelector:SelectListItemByIndex(i);
            driveFound = true;
            break;
        end
    end
    if ((currentDrive == "") or (driveFound ~= true)) then --internal
        caller.Content.HarddriveArea.HarddriveSubTitle.DriveSelector:SelectListItemByIndex(1);
    end

    UpdateLibrary();

    local gr = caller.Content.HarddriveArea.Frame.LibraryGrid;
    gr.OnSelectedItem = "";
    gr.SelectionType = "ColumnGridSelection";
    UnhookAll();
    local window = overlay.Content.LocalArea.Frame.PoolWindowPlace.PoolWindow;
    local settingsHookID = HookObjectChange(signalTable.OnSettingsChanged,	settings,	my_handle:Parent());
    local windowHookID = HookObjectChange(signalTable.OnWindowChanged,	window,	my_handle:Parent());
    table.insert(hookId, settingsHookID);
    table.insert(hookId, windowHookID);
    


    signalTable.OnWindowChanged(window);
    signalTable.OnSettingsChanged(settings, true);
end

signalTable.OnSettingsChanged = function(settings, onLoad)
    if(overlay.Content) then
        if(settings.ObjectType == "UserProfiles" or settings.SheetStyle) then
            overlay.Content.LocalArea.Frame.PoolWindowPlace.Visible = false;
            overlay.Content.LocalArea.Frame.LocalGrid.Visible = true;
            UsePool = false;
        else
            overlay.Content.LocalArea.Frame.PoolWindowPlace.Visible = true;
            overlay.Content.LocalArea.Frame.LocalGrid.Visible = false;
            UsePool = true;
        end

        local dep = overlay:FindRecursive("DependenciesBtn", "IndicatorControl")
        if(dep) then
            if (settings.ObjectType == "Pages") then
                dep.Enabled = false;
            else
                dep.Enabled = true;
            end
        end

        if(DestinationObject ~= settings.DestinationObject) then	
            DestinationObject = settings.DestinationObject;
            Cmd("CD Root; CD ".. ToAddr(DestinationObject));
        
            local cmdO = CmdObj();
            local dest = cmdO.Destination;

            signalTable.OnDriveGridLoaded(overlay.Content.HarddriveArea.Frame.LibraryGrid);
            signalTable.OnLocalGridLoaded(overlay.Content.LocalArea.Frame.LocalGrid);
            
            local newTarget = dest:Parent();
            if(newTarget ~= overlay.Content.SubPoolSelector.Target) then
                overlay.Content.SubPoolSelector.Target = newTarget;
            end

            if(dest:Parent():Parent():FindParent("DataPools")) then -- A DataPool itself doesn't want to show the DataPoolSelector
                overlay.Content.LocalArea.LocalSubTitle.DataPoolSelector.Visible = "Yes";
                overlay.Content.LocalArea.LocalSubTitle.HideDataPoolSelector.Visible = "No";		
            else
                overlay.Content.LocalArea.LocalSubTitle.DataPoolSelector.Visible = "No";
                overlay.Content.LocalArea.LocalSubTitle.HideDataPoolSelector.Visible = "Yes";
            end

            overlay:OnCheckSubPoolSelector();
            UpdateLibrary();
            CheckOptions();
            local type = settings.ObjectType;
            if(DestinationObject ~= nil and DestinationObject.Name ~= type) then
                type = type .. "." .. DestinationObject.Name;
            end
            if(overlay.TitleBar ~= nil) then
                overlay.TitleBar.Title.Text = overlay.Name .. " " .. type;
            end
        end
    end

    signalTable.ChangeObjectTypeVisibility(nil, settings.ObjectTypeValid);
end

signalTable.DepBtnUseSettingsTarget = function(caller)
    caller:WaitInit(1);
    caller.Target = overlay.Settings;
    caller.Target.IncludeDependencies = true;
end

signalTable.GapsBtnUseSettingsTarget = function(caller)
    caller:WaitInit(1);
    caller.Target = overlay.Settings;

end

signalTable.UseSettingsTarget = function(caller)
    caller:WaitInit(1);
    caller.Target = overlay.Settings;
end

signalTable.UseOverlayTarget = function(caller)
    caller.Target = overlay;
end
 
signalTable.JumpToGrid = function(caller)
    FindNextFocus();
end

-- ---------------------- DRIVE SELECTOR ----------------------------
signalTable.DriveChange = function(caller,status,driveH,index)
    UpdateLibrary();
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

-- ---------------------- ObjectType SELECTOR ----------------------------
signalTable.initObjectTypeSelector = function(caller,status,creator)	
    caller:WaitInit(1);
    caller.Target = overlay.Settings;
end

signalTable.OnObjectTypeSelectorClicked = function(caller, forceVisible)
-- forceVisible: Nil = noForce, true = normalDialog, false = ObjectTypeSelection
    local typeArea = overlay.Content.ObjectTypeArea;
    if(typeArea ~= nil) then
        local visibleBefore = overlay.Content.ObjectTypeArea.Visible;
        if(visibleBefore) then
            overlay.Settings.ObjectTypeValid = true;
        end
    end
    CmdIndirect("Collect");
    signalTable.ChangeObjectTypeVisibility(caller, forceVisible);
end

signalTable.ChangeObjectTypeVisibility = function(caller, forceVisible)
-- forceVisible: Nil = noForce, true = normalDialog, false = ObjectTypeSelection
    if(overlay == nil or overlay.Content == nil) then
        return;
    end

    local typeArea = overlay.Content.ObjectTypeArea;
    if(typeArea == nil) then
        return;
    end

    local visibleBefore = overlay.Content.ObjectTypeArea.Visible;
    if(forceVisible ~= nil and (forceVisible == false or forceVisible == true)) then
        visibleBefore = forceVisible;
    end

    overlay.Content.ObjectTypeArea.Visible = not visibleBefore;
    overlay.Content.LocalArea.Visible = visibleBefore;
    overlay.Content.HarddriveArea.Visible = visibleBefore;
    --overlay.Content.SubPoolSelector.Visible = visibleBefore;
    if(visibleBefore) then
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeButton.Icon = "triangle_right";
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeControl.Texture = "corner3";
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeButton.Texture = "corner12";
        overlay.Content.ObjectTypeArea.Visible = false;
    else
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeButton.Icon = "triangle_left";
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeControl.Texture = "corner1";
        overlay.Content.ObjectTypeButtonContainer.ObjectTypeButton.Texture = "corner4";
        overlay.Content.ObjectTypeArea.Visible = true;
    end
end

-- ---------------------- SUBPOOL SELECTOR ----------------------------
signalTable.OnSubPoolChanged = function(caller,status,creator)
    local settings = overlay.Settings;
    settings.SubPoolSelectorValue = status;
    settings.SubPoolSelectorIndex = caller.SelectedItemIdx;
    CmdIndirect("Collect");
end

-- ---------------------- LOCAL GRID ----------------------------
signalTable.OnLocalGridLoaded = function(caller,status,creator)
    caller.TargetObject=CmdObj().Destination;
end


signalTable.OnLocalGridSelectionChanged = function(grid)
    local window = grid:Parent().Frame.PoolWindowPlace.PoolWindow;
    window.AllIndexesCollected = false;
    overlay.Content.LocalArea.LocalSubTitle.CollectAll.Text = "Collect\nall";
end

-- ---------------------- DATAPOOL SELECTOR ----------------------------
signalTable.OnDataPoolLoaded = function(caller,status,creator)
    caller.Target=Root().ShowData.DataPools;
end

signalTable.OnDataPoolChanged = function(caller,status,creator)
    overlay:OnSelectDataPool();
    signalTable.OnSettingsChanged(overlay.Settings);
end
