local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local overlay = nil;

-- ---------------------- AUTOCREATE FUNCTIONS ----------------------------
signalTable.AutoCreateAllGroups = function(caller)
    signalTable.AutoCreateGroups(caller, true, false);
end

signalTable.AutoCreateSingleGroups = function(caller)
    signalTable.AutoCreateGroups(caller, false, false);
end

signalTable.AutoCreateOddEvenGroups = function(caller)
    signalTable.AutoCreateGroups(caller, true, true);
end


signalTable.AutoCreateGroups = function(caller, useAll, useOddEven)
    local settings = overlay.Settings;
    local cmdO = CmdObj();
    local gr = nil;
    if(settings.Advanced) then
        gr = overlay.Content.FixtureArea.Frame.FixtureGrid;
    else
        gr = overlay.Content.FixtureSourceArea.Frame.FixtureSourceGrid;
    end

    local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);

    if (frameSelectionIndex > 0) then
        local cmd = "";
        local UserProfile=CurrentProfile();
        local collection = UserProfile.Collection.IndexesSorted;
        if(collection[1] ~= nil) then
            cmd = "Autocreate _FrameSelection "..tostring(frameSelectionIndex).." at Collection"
        else
            cmd = "Autocreate _FrameSelection "..tostring(frameSelectionIndex).." at Group *"
        end
        
        if(useOddEven) then
            cmd = cmd .. " /OddEven"
        else
            if(useAll) then
                cmd = cmd .. " /All"
            else
                cmd = cmd .. " /Single"
            end
        end
        CmdIndirect(cmd);
    end
end

-- ---------------------- GENERAL ----------------------------
signalTable.OnCustomMenuLoaded = function(caller)
    overlay = caller;
    signalTable.OnSourceTypeChanged();
    overlay.Content.FixtureSourceArea.Frame.FixtureSourceGrid.LevelLimit="0";
    overlay.Content.FixtureArea.FixtureSubTitle.FixtureGridStyle.Visible = false;
    overlay.Content.FixtureArea.FixtureSubTitle.FixtureGridStyle.W = 0;
    overlay.Content.FixtureArea.FixtureSubTitle.StageSelect.Texture="Corner2";
    overlay.Settings.FixtureGrid = true;
    overlay.TitleBar.Title.Text = "Create Groups";
end

signalTable.AdjustVisibilityAndSize = function()
    local settings = overlay.Settings;

    local columnCount = 2;
    if(overlay.Content.FixtureArea and settings.Advanced) then
        columnCount = 3;
    end

    overlay.Content.FixtureSourceArea.w = (overlay.Content.AbsRect.w ) / columnCount;
    if(settings.Advanced) then
        overlay.Content.FixtureArea.Visible = "Yes";
        overlay.Content.FixtureArea.w = overlay.Content.FixtureSourceArea.w;
    else
        overlay.Content.FixtureArea.Visible = "No";
    end
end

-- ---------------------- LOCAL GRID ----------------------------
signalTable.OnLocalGridLoaded = function(caller,status,creator)
    local newTarget = CurrentProfile().SelectedDataPool.Groups;
    if(caller.TargetObject ~= newTarget) then
        caller.TargetObject=newTarget;
    end
end

-- ---------------------- FIXTURE SOURCE GRID ----------------------------


signalTable.OnSourceTypeChanged = function(caller)
    local value = overlay.Settings.FixtureSourceType;
   
    --require"gma3_debug"();

    if(value == "Fixture\nTypes") then
        overlay.Content.FixtureSourceArea.FixtureSubTitle.Title.Text="Fixture Types"
        overlay.Content.FixtureSourceArea.Frame.FixtureSourceGrid.TargetObject = Patch().FixtureTypes;
    elseif (value == "Classes") then
        overlay.Content.FixtureSourceArea.FixtureSubTitle.Title.Text=value
        local target = Patch().Classes;
        overlay.Content.FixtureSourceArea.Frame.FixtureSourceGrid.TargetObject = target;
    elseif (value == "Layers") then
        overlay.Content.FixtureSourceArea.FixtureSubTitle.Title.Text=value
        local target = Patch().Layers;
        overlay.Content.FixtureSourceArea.Frame.FixtureSourceGrid.TargetObject = target;
    end
end