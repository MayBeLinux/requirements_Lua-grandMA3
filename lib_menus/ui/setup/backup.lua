local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local currentFilterType = Enums.BackupBrowserFilter.Shows;
local NewShowDescriptionText = "";

local FILTER_TO_PATHTYPE = {
    [Enums.BackupBrowserFilter.Shows] = Enums.PathType.Showfiles;
    [Enums.BackupBrowserFilter.Backups] = Enums.PathType.Backupfiles;
    [Enums.BackupBrowserFilter.Demoshows] = Enums.PathType.DemoShowfiles;
    [Enums.BackupBrowserFilter.Templates] = Enums.PathType.TemplateShowfiles;
}

-----------------------------------------------------------
-- Helpers

function signalTable.GetDefaultFileName()
    local curTime = os.time(); 
    return "NewShow_"..os.date('!%Y.%m.%d_%H.%M.%S', curTime) .. "UTC";
end

function signalTable.SetSaveShowName(overlay, text)
    if (overlay.Mode == Enums.ShowfileSelectorMode.Saveas) then
        text = signalTable.CutShowEnding(text)
    else
        text = signalTable.GetDefaultFileName()
    end
    overlay.Frame.HeadContainer.NameInput.Content = text
end

function signalTable.AutoSelectFile(overlay, forceShowfile)
    local filterContent = signalTable.GetFilterContent(overlay)
    if filterContent and filterContent ~= "" then
        -- PRIO A) Filtering
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectFirstFile()
    else
        if forceShowfile then
            -- PRIO B) Forced Showfile (e.g. after saving)
            forceShowfile = signalTable.RebuildShowfileEnding(forceShowfile)
            overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile = forceShowfile;
        else
            local path = signalTable.GetCurrentPath(FILTER_TO_PATHTYPE[currentFilterType])
            local currentShow = signalTable.RebuildShowfileEnding(Root().ManetSocket.Showfile)
            if signalTable.GetSaveShowName(overlay) == Root().ManetSocket.Showfile and FileExists(path.."/"..currentShow) then
                -- PRIO C) current show exists, we select it
                overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile = currentShow;
            else
                -- PRIO D) reset selection
                overlay.Frame.ShowFilesViewContainer.ShowFilesView.ScrollToFirstFile();
                overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile = ""; -- nothing
                --overlay.Frame.ShowFilesViewContainer.ShowFilesView.ClearSelection();
            end
        end
    end
end

-----------------------------------------------------------
-- signalTable.UpdateButtonEnabling

function signalTable.UpdateButtonEnabling(overlay)
    local drive = SelectedDrive()
    if (overlay) then
        local loadBtn = overlay.Frame.ButtonArea.LoadBtn
        local newBtn = overlay.Frame.ButtonArea.NewBtn
        local saveBtn = overlay.Frame.ButtonArea.SaveBtn
        local saveAsBtn = overlay.Frame.ButtonArea.SaveAsBtn
        local deleteBtn = overlay.Frame.ButtonArea.DeleteBtn

        local hasMultiSelection = signalTable.GridHasMultiSelection(overlay)

        if (loadBtn) then
            loadBtn.Enabled = drive.DriveType ~= "Invalid" and not hasMultiSelection and overlay.ShowFileSegmentsMask;
        end

        if (saveBtn) then 
            if ((drive.DriveType == "Internal") or (drive.DriveType == "Removeable") or (drive.DriveType == "RemoteDrive")) and (currentFilterType == Enums.BackupBrowserFilter.Shows) and not hasMultiSelection then
                saveBtn.Enabled = true;
            else
                saveBtn.Enabled = false;
            end
        end

        if (saveAsBtn) then 
            if ((drive.DriveType == "Internal") or (drive.DriveType == "Removeable") or (drive.DriveType == "RemoteDrive")) and (currentFilterType == Enums.BackupBrowserFilter.Shows) and not hasMultiSelection then
                saveAsBtn.Enabled = true;
            else
                saveAsBtn.Enabled = false;
            end
        end

        if (newBtn) then 
            if (overlay.ShowFileSegmentsMask~=0) and (((drive.DriveType == "Internal") or (drive.DriveType == "Removeable") or (drive.DriveType == "RemoteDrive")) and (currentFilterType == Enums.BackupBrowserFilter.Shows)) then
                newBtn.Enabled = true;
            else
                newBtn.Enabled = false;
            end
        end

        if (deleteBtn) then
            if (currentFilterType == Enums.BackupBrowserFilter.Demoshows or currentFilterType == Enums.BackupBrowserFilter.Templates) then
                deleteBtn.Enabled = false;
            else
                deleteBtn.Enabled = true;
            end
        end
    end
end

function signalTable.RefreshMetaData(overlay)
    local path = signalTable.GetCurrentPath(FILTER_TO_PATHTYPE[currentFilterType])
    CmdObj().RefreshMetaData(path);
    overlay.Frame.ShowFilesViewContainer.ShowFilesView:Changed() -- force rebuild
end

-----------------------------------------------------------
-- signalTable.UpdateFilterBtn

function signalTable.UpdateFilterBtn(overlay)
    local filterBtn = overlay.Title.Filter;
    if (filterBtn) then
        if (overlay.Mode == Enums.ShowfileSelectorMode.Premenu) then
            return;
        end

        local function modePossible(m)
            if m == Enums.BackupBrowserFilter.Shows then
                return true;
            elseif m == Enums.BackupBrowserFilter.Backups then
                return overlay.Mode ~= Enums.ShowfileSelectorMode.Saveas;
            elseif m == Enums.BackupBrowserFilter.Demoshows then
                return overlay.Mode == Enums.ShowfileSelectorMode.Load;
            elseif m == Enums.BackupBrowserFilter.Templates then
                return overlay.Mode == Enums.ShowfileSelectorMode.Load;
            end
        end

        filterBtn:ClearList()
        filterBtn:AddListNumericItem("Shows", Enums.BackupBrowserFilter.Shows);
        if modePossible(Enums.BackupBrowserFilter.Backups) then
            filterBtn:AddListNumericItem("Backup Shows", Enums.BackupBrowserFilter.Backups);
        end
        if modePossible(Enums.BackupBrowserFilter.Demoshows) then
            filterBtn:AddListNumericItem("Demo Shows", Enums.BackupBrowserFilter.Demoshows);
        end
        if modePossible(Enums.BackupBrowserFilter.Templates) then
            filterBtn:AddListNumericItem("Template Shows", Enums.BackupBrowserFilter.Templates);
        end

        if not modePossible(currentFilterType) then
            currentFilterType = Enums.BackupBrowserFilter.Shows;
        end

        filterBtn:SelectListItemByValue(currentFilterType);
        signalTable.OnDriveChanged(overlay);
        signalTable.RefreshMetaData(overlay);
    end
end

-----------------------------------------------------------
-- Drive Change Handling

signalTable.OnDriveChanged = function(overlay)
    -- Update FileGrid path:
    local path = signalTable.GetCurrentPath(FILTER_TO_PATHTYPE[currentFilterType])
    overlay.Frame.ShowFilesViewContainer.ShowFilesView.SetPath(path);

    -- Update Bottom Buttons:
    signalTable.UpdateButtonEnabling(overlay);

    -- Update DiskFreeSpace Button:
    signalTable.UpdateDiskStatus(overlay.Frame.HeadContainer.DriveStatus)
    signalTable.UpdateDiskStatus(overlay.PreMenu.ShowFileAndDescription.DriveStatus)

    -- Update FileGrid Metadata and Selection:
    signalTable.RefreshMetaData(overlay)
    signalTable.AutoSelectFile(overlay)

    signalTable.AdjustPremenuButtons(overlay)
end

-----------------------------------------------------------
-- OnLoad

signalTable.BackupLoaded = function(caller,status,creator)
    signalTable.ShowSelectorLoaded(caller)

    caller.Frame.Visible = false

    caller.Frame.History.Visible = Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory
    caller.Frame.ButtonArea.History.Target = caller.Frame.History
    caller.Frame.ButtonArea.Description.Target = caller.Frame.Description
    
    signalTable.SetSaveShowName(caller, Root().ManetSocket.Showfile)

    signalTable.OnDriveChanged(caller);

    HookObjectChange(signalTable.DriveCollectChanged, Root().Temp.DriveCollect, my_handle:Parent(), caller);
    HookObjectChange(signalTable.GridSelectionChanged, caller.Frame.ShowFilesViewContainer.ShowFilesView:GridGetSelection(), my_handle:Parent(), caller);

    signalTable.UpdateFilterBtn(caller)
    signalTable.RefreshMetaData(caller)
    signalTable.AutoSelectFile(caller)

    -- RPU Adjustment
    local d = caller:GetDisplay();
    if d.AbsRect.w <= 1000 or d.AbsRect.h <= 480 then
        -- adjust for small screen:
        caller.PreMenu.ShowFileAndDescription.H="80"
    end

    signalTable.UpdateDescription(caller, caller.Mode ~= Enums.ShowfileSelectorMode.Saveas)

    HookObjectChange(signalTable.BackupMenuChanged, caller, my_handle:Parent(), caller);
    
end

-----------------------------------------------------------
-- Filter Changed (Shows, DemoShows, Backup, ...)

signalTable.SetFilter = function(caller, dummy, handleInt, idx)
    currentFilterType = idx;

    local overlay = caller:GetOverlay();
    local drive   = SelectedDrive()
    
    signalTable.OnDriveChanged(overlay);
    signalTable.RefreshMetaData(overlay)
end

-----------------------------------------------------------
-- LOAD

signalTable.LoadShow = function(caller)    
    local overlay = caller:GetOverlay();
    local fileName = overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile;
    if(fileName ~= "") then
        local path = signalTable.GetCurrentPath(FILTER_TO_PATHTYPE[currentFilterType])
        
        local loadMask = overlay.ShowFileSegmentsMask
        local loadMaskOptionString = ""
        for k,v in pairs(Enums.ShowFileSegmentsMask) do
            if(v ==  Enums.ShowFileSegmentsMask.NoShowData) then
                if (loadMask & v == 0) then
                    loadMaskOptionString = loadMaskOptionString .. " /"..k
                end
            elseif v == Enums.ShowFileSegmentsMask.All then
                if loadMask == v then
                    loadMaskOptionString = " /"..k
                    break
                end
            elseif loadMask & v ~= 0 then
                loadMaskOptionString = loadMaskOptionString .. " /"..k
            end
        end
        signalTable.CloseOverlay(overlay);
        CmdIndirect("LoadShow \""..path.."/"..fileName.."\""..loadMaskOptionString);
        CmdObj().ClearCmd();

        currentFilterType = Enums.BackupBrowserFilter.Shows -- reset to shows again after loading
    else
        MessageBox({title = "No Show Selected", message = "Please select a show to load it.", commands={{value = 1, name = "Ok"}}});
    end
end

-----------------------------------------------------------
-- NEW

signalTable.NewShow = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = overlay.Frame.HeadContainer.NameInput.Content;
    if(fileName ~= "") then
       local loadMask = overlay.ShowFileSegmentsMask
       local loadMaskOptionString = ""

       for k,v in pairs(Enums.ShowFileSegmentsMask) do
            if(v ==  Enums.ShowFileSegmentsMask.NoShowData) then
                if (loadMask & v == 0) then
                    loadMaskOptionString = loadMaskOptionString .. " /"..k
                end
            elseif v == Enums.ShowFileSegmentsMask.All then
                if loadMask == v then
                    loadMaskOptionString = " /"..k
                    break
                end
            elseif loadMask & v ~= 0 then
                loadMaskOptionString = loadMaskOptionString .. " /"..k
            end
       end
        signalTable.CloseOverlay(overlay);
        CmdIndirect("NewShow '"..fileName.."' "..loadMaskOptionString);
        CmdObj().ClearCmd();
        currentFilterType = Enums.BackupBrowserFilter.Shows -- reset to shows again after loading

        if NewShowDescriptionText ~= "" then
            Root().NewShowStartDescription = NewShowDescriptionText;
            NewShowDescriptionText = "";
        end
    else
        MessageBox({title = "No Showname", message = "Please input a showname .", commands={{value = 1, name = "Ok"}}});
    end
end

-----------------------------------------------------------
-- SAVE

signalTable.SaveShow = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = signalTable.CutShowEnding(Root().ManetSocket.Showfile)
    CmdIndirectWait(string.format("SaveShow \"%s\"",fileName))
    signalTable.RefreshMetaData(overlay)
    coroutine.yield({ui=1})
    signalTable.AutoSelectFile(overlay, fileName)
end

-----------------------------------------------------------
-- SAVEAS

signalTable.SaveShowAs = function(caller)
    local overlay = caller:GetOverlay();
    local newName = signalTable.GetSaveShowName(overlay)
    if newName then
        CmdIndirectWait(string.format("SaveShow \"%s\"",newName))

        signalTable.RefreshMetaData(overlay)
        signalTable.GotoPreMenu(caller)
        -- coroutine.yield({ui=1})
    end
end

-----------------------------------------------------------
-- DELETE

signalTable.DeleteShow = function(caller)
    local overlay = caller:GetOverlay()
    local firstSelected = overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile;
    if firstSelected and firstSelected ~= "" then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.DeleteSelectedFiles();
        signalTable.RefreshMetaData(overlay)
        coroutine.yield({ui=1})
        signalTable.AutoSelectFile(overlay)
    end
end

-----------------------------------------------------------
-- Selection changed

signalTable.OnFileSelected = function(caller,dummy,rowid)
    local overlay = caller:GetOverlay()
    signalTable.SetSaveShowName(overlay, caller.SelectedFile)
    signalTable.SelectWholeText(overlay.Frame.HeadContainer.NameInput)
    if (Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory) then
        overlay.Frame.History.ShowHistoryGrid.CurrentSelectedShowFile = caller.SelectedFile;
        overlay.Frame.History.ShowHistoryGrid.ReTriggerInit();
    end
end

signalTable.GridSelectionChanged = function(caller,_,overlay)
    signalTable.UpdateButtonEnabling(overlay)
    signalTable.UpdateDescription(overlay, overlay.Mode ~= Enums.ShowfileSelectorMode.Saveas)
end

-----------------------------------------------------------
-- Filter Textinput Actions

signalTable.OnFilterChanged = function(caller, signal)
    local overlay = caller:GetOverlay()
    
    if(overlay.Frame.ShowFilesViewContainer.ShowFilesView.hasFocus == false) then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.FuzzyFilter = signalTable.GetFilterContent(overlay)
        signalTable.AutoSelectFile(overlay)
    end
end

-----------------------------------------------------------
-- GOTO FUNCTIONS

function signalTable.ChangeModeTo(newMode, overlay)
    overlay.Mode = newMode
    -- Adjustments to mode:
    signalTable.UpdateFilterBtn(overlay)
    signalTable.SetFilterContent(overlay,"")
    signalTable.UpdateDescription(overlay, newMode ~= Enums.ShowfileSelectorMode.Saveas)
    -- Visiblity:
    overlay.PreMenu.Visible = (newMode == Enums.ShowfileSelectorMode.Premenu)
    overlay.Frame.Visible = (newMode ~= Enums.ShowfileSelectorMode.Premenu)
    overlay.Frame.LoadOptionsContainer.Visible = (newMode == Enums.ShowfileSelectorMode.Load or newMode == Enums.ShowfileSelectorMode.Newshow)
    overlay.Frame.ButtonArea.LoadBtn.Visible = (newMode == Enums.ShowfileSelectorMode.Load)
    overlay.Frame.ButtonArea.SaveAsBtn.Visible = (newMode == Enums.ShowfileSelectorMode.Saveas)
    overlay.Frame.ButtonArea.DeleteBtn.Visible = (newMode == Enums.ShowfileSelectorMode.Delete)
    overlay.Frame.ButtonArea.NewBtn.Visible = (newMode == Enums.ShowfileSelectorMode.Newshow)
    overlay.Title.Filter.visible = (newMode ~= Enums.ShowfileSelectorMode.Premenu and newMode ~= Enums.ShowfileSelectorMode.Saveas)
    overlay.Frame.HeadContainer.SearchBar.visible = (newMode ~= (Enums.ShowfileSelectorMode.Saveas or Enums.ShowfileSelectorMode.Newshow))
    overlay.Frame.HeadContainer.Clear.visible     = (newMode ~= (Enums.ShowfileSelectorMode.Saveas or Enums.ShowfileSelectorMode.Newshow))
    overlay.Frame.HeadContainer.NameInput.visible = (newMode == Enums.ShowfileSelectorMode.Saveas or newMode == Enums.ShowfileSelectorMode.Newshow)
    overlay.Frame.HeadContainer.NameClear.visible = (newMode == Enums.ShowfileSelectorMode.Saveas or newMode == Enums.ShowfileSelectorMode.Newshow)
    -- Newshow Specials:
    local newShow = (newMode == Enums.ShowfileSelectorMode.Newshow)
    overlay.Frame.LoadOptionsContainer.ShowData.Text = newShow and "Clear Show Data" or "Show Data"
    overlay.Frame.LoadOptionsContainer.LocalSettings.Text = newShow and "Clear Local Settings" or "Local Settings"
    overlay.Frame.LoadOptionsContainer.OutputStations.Text = newShow and "Clear Output Stations" or "Output Stations"
    overlay.Frame.LoadOptionsContainer.DmxProtocols.Text = newShow and "Clear DMX Protocols" or "DMX Protocols"
    overlay.Frame.ButtonArea.History.Visible = not newShow
    overlay.Frame.ButtonArea.Description.Visible = not newShow
    overlay.Frame.ShowFilesViewContainer.ShowFilesView.Visible = not newShow

    if (newShow) then
        overlay.Frame.Description.visible = true;
        overlay.Frame.History.visible = false;
        signalTable.UpdateDescription(overlay, true);
    end

    -- Focus:
    if (newMode == Enums.ShowfileSelectorMode.Load or newMode == Enums.ShowfileSelectorMode.Delete) then
        FindBestFocus(overlay.Frame.HeadContainer.SearchBar);
    end
    if (newMode == Enums.ShowfileSelectorMode.Saveas or newMode == Enums.ShowfileSelectorMode.Newshow) then
        FindBestFocus(overlay.Frame.HeadContainer.NameInput);
        signalTable.SetSaveShowName(overlay, Root().ManetSocket.Showfile)
        signalTable.SelectWholeText(overlay.Frame.HeadContainer.NameInput)
    end
    if (newMode == Enums.ShowfileSelectorMode.Premenu) then
        FindBestFocus(overlay.PreMenu.CenterButtons.ModeLoad)
    end
    if (newMode == Enums.ShowfileSelectorMode.Delete) then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectionType="MultiRowGridSelection"
    else
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectionType="SingleRowGridSelection"
    end
end

signalTable.GotoLoad = function(caller)
    local overlay = caller:GetOverlay()
    signalTable.ChangeModeTo(Enums.ShowfileSelectorMode.Load, overlay)
end
signalTable.GotoDelete = function(caller)
    local overlay = caller:GetOverlay()
    signalTable.ChangeModeTo(Enums.ShowfileSelectorMode.Delete, overlay)
end
signalTable.GotoSaveAs = function(caller)
    local overlay = caller:GetOverlay()
    signalTable.ChangeModeTo(Enums.ShowfileSelectorMode.Saveas, overlay)
end
signalTable.GotoPreMenu = function(caller)
    local overlay = caller:GetOverlay()
    signalTable.ChangeModeTo(Enums.ShowfileSelectorMode.Premenu, overlay)
end
signalTable.GotoNewShow = function(caller)
    local overlay = caller:GetOverlay()
    signalTable.ChangeModeTo(Enums.ShowfileSelectorMode.Newshow, overlay)
end

-----------------------------------------------------------
-- DO FUNCTIONS

signalTable.DoSave = function(caller)
    signalTable.SaveShow(caller)
end

-----------------------------------------------------------
-- AdjustPremenuButtons

signalTable.AdjustPremenuButtons = function(overlay)
    local drive = SelectedDrive()
    local canSave = drive and drive.DriveType ~= "OldVersion";
    
    local User = CurrentUser();
    local isAdmin = false;
    if (User.rights == 'Admin') then
        isAdmin = true;
    end

    overlay.PreMenu.CenterButtons.ModeSave.enabled = canSave
    overlay.PreMenu.CenterButtons.ModeNewS.enabled = canSave and isAdmin;
    overlay.PreMenu.CenterButtons.ModeSaAs.enabled = canSave
    overlay.PreMenu.CenterButtons.ModeSave.text = not canSave and "Save" or "Save to\n"..drive.name
end

signalTable.UpdateDescriptionForNewShow = function(caller)
    local overlay = caller:GetOverlay()
    
    NewShowDescriptionText = "";
    
    if (overlay.ShowFileSegmentShowData == false) then
        NewShowDescriptionText = NewShowDescriptionText .. " Show Data";
    end

    if (overlay.ShowFileSegmentLocalSettings == false) then
       if NewShowDescriptionText ~= "" then
          NewShowDescriptionText = NewShowDescriptionText .. " /";
       end
       NewShowDescriptionText = NewShowDescriptionText .. " Local Settings";
    end

    if (overlay.ShowFileSegmentOutputStations == false) then
       if NewShowDescriptionText ~= "" then
          NewShowDescriptionText = NewShowDescriptionText .. " /";
       end
       NewShowDescriptionText = NewShowDescriptionText .. " Output Stations";
    end

    if (overlay.ShowFileSegmentDmxProtocols == false) then
       if NewShowDescriptionText ~= "" then
          NewShowDescriptionText = NewShowDescriptionText .. " /";
       end
       NewShowDescriptionText = NewShowDescriptionText .. " DMX Protocols";
    end

    if NewShowDescriptionText ~= "" then
        local fileName = Root().ManetSocket.Showfile
        if fileName ~= "" then
           overlay.Frame.Description.Input.InputField.Text = "This show file contains data from \""..fileName .. "\":\n" .. NewShowDescriptionText;
           NewShowDescriptionText = "This show file contains data from \""..fileName .. "\": " .. NewShowDescriptionText;
        end
    else
        overlay.Frame.Description.Input.InputField.Text = "";
    end    
end


signalTable.BackupMenuChanged = function(caller,_,overlay)
    -- Update Bottom Buttons:
    if(overlay and overlay.Title) then
        signalTable.UpdateButtonEnabling(overlay);
    end

    if (overlay.Mode == Enums.ShowfileSelectorMode.Newshow) then
        signalTable.UpdateDescriptionForNewShow(caller)
    end

end

signalTable.CloseOverlay = function(overlay)
    -- Unhook: Hook was causing access to overlay.Frame, while overlay was about to disappear
    UnhookMultiple(signalTable.DriveCollectChanged);
    UnhookMultiple(signalTable.GridSelectionChanged);
    UnhookMultiple(signalTable.BackupMenuChanged);
    UnhookMultiple(signalTable.LocalSettingsChanged); -- From show_selector_content.lua
    overlay.Close();
end