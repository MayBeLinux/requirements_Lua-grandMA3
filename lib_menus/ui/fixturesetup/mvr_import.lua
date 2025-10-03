local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local initialFilterContent = "";
local initFile = true;

local function GetFilePath(overlay)
    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);
    local path = drive.Path;
    if (drive:Index() == 1) then path = ""; end
    local typeIdx = overlay.Title.TypeSelector:GetListSelectedItemIndex()
    local type = overlay.Title.TypeSelector:GetListItemValueStr(typeIdx)
    if type == "Demo" then 
        type = Enums.PathType.MvrLibrary
    else
        type = Enums.PathType.UserMvr
    end
    return GetPathOverrideFor(type, path);
end

local function UpdateFileView(content)
    local showFilePath = GetFilePath(content:GetOverlay());
    local fileExtension;
	fileExtension = ".mvr";

    content.FilesView.SetPath(showFilePath);

    if (initFile == true) then
        initFile = false;
        if(initialFilterContent) then
            content.FilesView.SelectedFile = initialFilterContent..fileExtension;
            content.FileContainer.FileName.Content = initialFilterContent;
        end
    end
end

signalTable.OnLoaded = function(caller,status,creator)
    initialFilterContent = Root().ManetSocket.Showfile;
    if (caller:WaitInit(1) ~= true) then
        ErrEcho("Failed to wait");
        return;
    end
    local typeSelector = caller.Title.TypeSelector;
    typeSelector:AddListStringItem("User", "User")
    typeSelector:AddListStringItem("Demo", "Demo")
    typeSelector:SelectListItemByValue("User")

    local drive = nil;
    local selDrive = Root().StationSettings.LocalSettings.SelectedDrive;
    for i,d in ipairs(Root().Temp.DriveCollect) do
        if (d.Path == selDrive) then
            caller.Title.DriveSelector:SelectListItemByIndex(i);
            initFile = true;
            drive = d;
            break;
        end
    end
    if (selDrive == "") then --internal
        caller.Title.DriveSelector:SelectListItemByIndex(1);
        initFile = true;
        drive = Root().Temp.DriveCollect[1];
    end
    if (drive) then
        UpdateFileView(caller.Content);
    end

    caller.Content.FilesView.SortByColumn("Desc", 0);
    caller.Content.FileContainer.FileName.SelectAll();
end

signalTable.TypeChange = function(caller)
    local content = caller:GetOverlay().Content;
    UpdateFileView(content);
    FindBestFocus(content.FileContainer.FileName);
end

signalTable.DriveChange = function(caller,status,driveH,index)
    local drive = IntToHandle(driveH);
    local content = caller:GetOverlay().Content;
    UpdateFileView(content, drive);
    FindBestFocus(content.FileContainer.FileName);
end

signalTable.Import = function(caller)
    local overlay = caller:GetOverlay();
    local fileName = overlay.Content.FileContainer.FileName.Content;
    local filePath = GetFilePath(overlay);

	if (fileName == "") then
		MessageBox({title = "Cannot import MVR", message = "Select MVR file to import!", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
		return;
	end

    overlay.Close();
    WaitObjectDelete(overlay);
	Cmd("Library"); -- clean previous library
    local command = "Addon 'MVR' \"MVRIMPORT";
	command = command.. " file='"..filePath..GetPathSeparator()..fileName.."'";
	command = command .. "\"";
    CmdIndirect(command);
end

signalTable.Delete = function(caller)
    local overlay = caller:GetOverlay();
    local fname = overlay.Content.FilesView.SelectedFile;

    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);
    
    local path = drive.Path;    
    if (drive:Index() == 1) then path = ""; end
    local filePath = GetFilePath(overlay);
    if (FileExists(filePath.."/"..fname) == true) then
        if (Confirm('Delete MVR File "'..fname..'"', 'Do you really want to delete "'..fname..'"?') == true) then
            os.remove(filePath.."/"..fname);
            overlay.Content.FilesView.BaseFilter = "*.mvr";
        end
    end
end

signalTable.OnFileSelected = function(caller,dummy,rowid)
    if (caller.HasFocus == true) then
        local overlay = caller:GetOverlay();
        local fileNameEdit = overlay.Content.FileContainer.FileName;
        local fname = caller.SelectedFile:gsub(".mvr$", "");
        fileNameEdit.SetText(fname);
        fileNameEdit.SelectAll();
        initialFilterContent = fname;
    end
end

signalTable.OnFilterChanged = function(caller,dummy)
    local overlay = caller:GetOverlay();
    local fileBrowser = overlay.Content.FilesView;
    local fileNameEdit = overlay.Content.FileContainer.FileName;
    local currentFuzzy = fileBrowser.FuzzyFilter;
    local cnt = fileNameEdit.Content;
    if (currentFuzzy ~= cnt and cnt ~= initialFilterContent) then
        initialFilterContent = nil;
        fileBrowser.FuzzyFilter = cnt;
        fileBrowser.SelectedFile = cnt;
    end
end

