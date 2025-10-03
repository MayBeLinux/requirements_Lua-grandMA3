local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function UpdateFileView(content,drive)
    local path = drive.Path;
    if (drive:Index() == 1) then path = ""; end
    local updateFilePath = GetPathOverrideFor("installation_packages", path);
    content.UpdateFilesView.SetPath(updateFilePath);
end

signalTable.SelectUpdateLoaded = function(caller,status,creator)
    if (caller:WaitInit(1) ~= true) then
        ErrEcho("Failed to wait");
        return;
    end

    local drive = nil;
    local selDrive = Root().StationSettings.LocalSettings.SelectedDrive;
    for i,d in ipairs(Root().Temp.DriveCollect) do
        if (d.Path == selDrive) then
            caller.Title.DriveSelector:SelectListItemByIndex(i);
            drive = d;
            break;
        end
    end
    if (selDrive == "") then --internal
        caller.Title.DriveSelector:SelectListItemByIndex(1);
        drive = Root().Temp.DriveCollect[1];
    end
    if (drive) then
        UpdateFileView(caller.Content, drive);
    end

    --caller.Content.UpdateFilesView.SortByColumn("Date", 0);
end

signalTable.DriveChange = function(caller,status,driveH,index)
    local drive = IntToHandle(driveH);
    local content = caller:GetOverlay().Content;
    UpdateFileView(content, drive);
    FindBestFocus(content.UpdateFileContainer.UpdateFileName);
end

signalTable.SelectUpdate = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = overlay.Content.UpdateFileContainer.UpdateFileName.Content;

    if (fileName ~= "") then
        local p = GetPath("installation_packages");
        Echo("Selected update version " .. fileName .. " from drive " .. p);
        overlay.Value = fileName..";"..p;
        overlay.Close();
    end
    --CmdIndirect("LoadUpdate '"..fileName.."'");
end

--[[signalTable.SaveUpdate = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = overlay.Content.UpdateFileContainer.UpdateFileName.Content;
    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);

    local path = drive.Path;
    if (drive:Index() == 1) then path = ""; end
    local showFilePath = GetPathOverrideFor("shows", path);
    local currentUpdateName = Root().ManetSocket.Updatefile;
    if ((currentUpdateName ~= fileName) and FileExists(showFilePath.."/"..fileName..".show") == true) then
        if (Confirm("Overwrite existing show file?", "Update file with name '"..fileName.."' already exists. Overwrite?") ~= true) then
            return;
        end
    end

    overlay.Close();
    CmdIndirect("SaveUpdate '"..fileName.."'");
end]]

--[[signalTable.DeleteUpdate = function(caller)
    local overlay = caller:GetOverlay();
    local fname = overlay.Content.UpdateFilesView.SelectedFile;

    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);

    local path = drive.Path;
    if (drive:Index() == 1) then path = ""; end
    local showFilePath = GetPathOverrideFor("shows", path);
    if (FileExists(showFilePath.."/"..fname) == true) then
        if (Confirm("Are you sure you want to delete?", "Are you sure you want to delete the show file with the name '"..fname.."'?") == true) then
            os.remove(showFilePath.."/"..fname);
            overlay.Content.UpdateFilesView.BaseFilter = "*.show";
        end
    end
end]]

signalTable.OnFileSelected = function(caller,dummy,rowid)
    if (caller.HasFocus == true) then
        local overlay = caller:GetOverlay();
        local fileNameEdit = overlay.Content.UpdateFileContainer.UpdateFileName;
        --local fname = caller.SelectedFile:gsub(".xml$", "");
        --local version = fname:gsub("^release_", "");
        fileNameEdit.SetText(caller.SelectedFile);
        fileNameEdit.SelectAll();
    end
end

signalTable.OnFilterChanged = function(caller,dummy)
    local overlay = caller:GetOverlay();
    local fileBrowser = overlay.Content.UpdateFilesView;
    local fileNameEdit = overlay.Content.UpdateFileContainer.UpdateFileName;
    local currentFuzzy = fileBrowser.FuzzyFilter;
    local cnt = fileNameEdit.Content;
    if (currentFuzzy ~= cnt and cnt ~= initialFilterContent) then
        --initialFilterContent = nil;
        fileBrowser.FuzzyFilter = cnt;
        fileBrowser.SelectedFile = cnt;
    end
end

signalTable.FBGridLoaded = function(caller)
	caller:WaitInit(2);
    local so = caller.GetSortOrder();
	if (so == Enums.GridSortOrder.None) then
		caller.SortByColumnName("Name", Enums.GridSortOrder.Asc);
    end
end

