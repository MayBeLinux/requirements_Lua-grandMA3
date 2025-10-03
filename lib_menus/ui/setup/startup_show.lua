local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local FILTER_TO_PATHTYPE = {
    ["Shows"] = Enums.PathType.Showfiles;
    ["Demo Shows"] = Enums.PathType.DemoShowfiles;
    ["Template Shows"] = Enums.PathType.TemplateShowfiles;
}

local ANSI_GREEN    = string.char(27) .. "[32m"
local ANSI_MAGENTA  = string.char(27) .. "[35m"

-----------------------------------------------------------
-- Drive Change Handling

signalTable.OnDriveChanged = function(overlay)
    -- Update FileGrid path:
    local currentFilterType = Root().StationSettings.LocalSettings.StartupBrowserFilter
    local path = signalTable.GetCurrentPath(FILTER_TO_PATHTYPE[currentFilterType])
    overlay.Frame.ShowFilesViewContainer.ShowFilesView.SetPath(path);

    -- Update Selection:
    local fileName = Root().StationSettings.LocalSettings.StartupShowfileName
    if fileName ~= "" then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile = fileName
    end
end

-----------------------------------------------------------
-- OnLoad

signalTable.StartupShowLoaded = function(caller,status,creator)
    signalTable.ShowSelectorLoaded(caller)
    
    Cmd("Select Drive 1")
    
    HookObjectChange(signalTable.DriveCollectChanged, Root().Temp.DriveCollect, my_handle:Parent(), caller);
    HookObjectChange(signalTable.GridSelectionChanged, caller.Frame.ShowFilesViewContainer.ShowFilesView:GridGetSelection(), my_handle:Parent(), caller);
    
    if (Root().StationSettings.LocalSettings.StartupShowfileName == "") then
        Root().StationSettings.LocalSettings.StartupBrowserFilter = Enums.StartupBrowserFilter.Shows
    end

    caller.ShowFileSegmentsMask = Root().StationSettings.LocalSettings.StartupShowfileFilter
    
    caller.Mode = Enums.ShowfileSelectorMode.Startupshow

    -- Adjustments to mode:
    signalTable.OnDriveChanged(caller)
    signalTable.SetFilterContent(caller, "")
    
    -- Visiblity:
    caller.Frame.Visible = true
    
    caller.Frame.History.Visible = false
    caller.Frame.ButtonArea.History.Target = caller.Frame.History
    caller.Frame.ButtonArea.Description.Target = caller.Frame.Description

    caller.Frame.HeadContainer.SearchBar.visible = true
    caller.Frame.HeadContainer.Clear.visible     = true
    caller.Frame.HeadContainer.BackBtn.visible   = false
    caller.Frame.HeadContainer.DriveStatus.visible   = false

    caller.Frame.ButtonArea.History.Visible = 1
    caller.Frame.ButtonArea.Description.Visible = 1
    caller.Frame.ButtonArea.NoShowBtn.Visible = 1
    caller.Frame.ButtonArea.SelectShowBtn.Visible = 1

    caller.Frame.ShowFilesViewContainer.ShowFilesView.Visible = 1
    caller.Frame.ShowFilesViewContainer.ShowFilesView.SelectionType="SingleRowGridSelection"

    FindBestFocus(caller.Frame.HeadContainer.SearchBar);

    if(Root().StationSettings.LocalSettings.StartupShowfileToLoad == "") then
        caller.Title.TitleBtn.Text = "Select Startup Show"
    else
        caller.Title.TitleBtn.Text = 'Selected Startup Show '  .. Root().StationSettings.LocalSettings.StartupShowfileName  ..  ' in Folder ' .. Root().StationSettings.LocalSettings.StartupBrowserFilter
    end
    
    signalTable.UpdateDescription(caller, caller.Mode ~= Enums.ShowfileSelectorMode.Saveas)
end

----------------------------------------------------------
-- SelectShowBtnClicked

signalTable.SelectShowBtnClicked = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile;
    
    local messagetext = "No startup show file selected."

    if(fileName ~= "") then
        Root().StationSettings.LocalSettings.StartupShowfileName = fileName;
        Root().StationSettings.LocalSettings.StartupShowfileFilter = overlay.ShowFileSegmentsMask;

        messagetext = fileName .. " selected"
    end
    
    local titletext = "Startup Show File";

    MessageBox({title = titletext , message = messagetext, commands={{value = 1, name = "Ok"}}});

    local echotext = ANSI_GREEN .. titletext .. ' '.. ANSI_MAGENTA ..'"' .. fileName .. '"'
    echotext = echotext ..ANSI_GREEN ..' from Folder '..  ANSI_MAGENTA ..'"' .. Root().StationSettings.LocalSettings.StartupBrowserFilter .. '"'..  ANSI_GREEN..' selected';

    Echo(echotext)

    overlay.Close();
end 

----------------------------------------------------------
-- NoShowClicked

signalTable.NoShowClicked = function(caller)
    local overlay = caller:GetOverlay();
    Root().StationSettings.LocalSettings.StartupShowfileName = "";

    MessageBox({title = "Startup Show File", message = "No startup show selected.", commands={{value = 1, name = "Ok"}}});

    overlay.Close();
end 

-----------------------------------------------------------
-- Selection changed

signalTable.OnFileSelected = function(caller,dummy,rowid)
    local overlay = caller:GetOverlay()
    signalTable.SelectWholeText(overlay.Frame.HeadContainer.NameInput)
    if (Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory) then
        overlay.Frame.History.ShowHistoryGrid.CurrentSelectedShowFile = caller.SelectedFile;
        overlay.Frame.History.ShowHistoryGrid.ReTriggerInit();
    end
end

signalTable.GridSelectionChanged = function(caller,_,overlay)
    signalTable.UpdateDescription(overlay, overlay.Mode ~= Enums.ShowfileSelectorMode.Saveas)
end

-----------------------------------------------------------
-- Filter Textinput Actions

signalTable.OnFilterChanged = function(caller, signal)
    local overlay = caller:GetOverlay()

    if(overlay.Frame.ShowFilesViewContainer.ShowFilesView.hasFocus == false) then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.FuzzyFilter = signalTable.GetFilterContent(overlay)
    end
end