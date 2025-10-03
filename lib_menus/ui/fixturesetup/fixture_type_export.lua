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
    return GetPathOverrideFor(Enums.PathType.UserFixtures, path);
end

local function UpdateFileView(content)
    local showFilePath = GetFilePath(content:GetOverlay());
    local fileExtension;
    if (content.LibraryType:GetListSelectedItemIndex() == 1) then
        fileExtension = ".xml";
    else
        fileExtension = ".gdtf";
    end

    content.FilesView.SetPath(showFilePath);

    if (initFile == true) then
        initFile = false;
        if(initialFilterContent) then
            content.FilesView.SelectedFile = initialFilterContent..fileExtension;
            content.FileContainer.FileName.Content = initialFilterContent;
        end
    end
end

local function CanExportAsGDTF()
    local ObjectList = ObjectList("UIGridSelection")
    for k,v in ipairs(ObjectList) do
        if v.source == "grandMA2" then
            return false
        end
    end
    return true
end

signalTable.OnLoaded = function(caller,status,creator)
    initialFilterContent = "<Default>";
    if (caller:WaitInit(1) ~= true) then
        ErrEcho("Failed to wait");
        return;
    end
    local typeSelector = caller.Content.LibraryType;
    typeSelector:AddListStringItem("User",".xml");

    if (CanExportAsGDTF()) then
        typeSelector:AddListStringItem("GDTF",".gdtf");
    end
    typeSelector:SelectListItemByIndex(1);

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

signalTable.OnLibraryTypeChanged= function(caller, status, index)
    local overlay = caller:GetOverlay();
    initFile = true;
    UpdateFileView(overlay.Content);
    FindBestFocus(overlay.Content.FileContainer.FileName);
end

signalTable.DriveChange = function(caller,status,driveH,index)
    local drive = IntToHandle(driveH);
    local content = caller:GetOverlay().Content;
    UpdateFileView(content, drive);
    FindBestFocus(content.FileContainer.FileName);
end

FIXTURE_TYPE_EXPORT_IN_PROGRESS = {}
local function CheckAlreadyInProgress(overlay)
    --cleanup
    for k,v in pairs(FIXTURE_TYPE_EXPORT_IN_PROGRESS) do
        if not IsObjectValid(k) then
            FIXTURE_TYPE_EXPORT_IN_PROGRESS[k] = nil
        end
    end
    --check
    if FIXTURE_TYPE_EXPORT_IN_PROGRESS[overlay] == true then
        return false;
    end
    --add
    FIXTURE_TYPE_EXPORT_IN_PROGRESS[overlay] = true;
    return true
end

signalTable.Export = function(caller)
    local overlay = caller:GetOverlay();

    if not CheckAlreadyInProgress(overlay) then return; end

    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);
    local fileName = overlay.Content.FileContainer.FileName.Content;
    local xml = overlay.Content.LibraryType:GetListSelectedItemIndex() == 1;

    local command = "Export";
	local addOpt = "";
	local path = drive.Path;
	if (drive:Index() == 1) then path = "" end;
    if xml then
        command = command.." UIGridSelection If Drive "..drive:Index();
    else
        command = command .." UIGridSelection";
		command = command .. " /Path '" ..GetPathOverrideFor(Enums.PathType.UserFixtures, path, true).. "'";
		addOpt = " /GDTF";
    end
    if (fileName~="" and fileName~="<Default>") then
        command = command.. " /File '"..fileName.."'";
    end
	command = command .. addOpt;

    local progBar = StartProgress("Export FixtureType")
	SetProgressRange(progBar,0,1)
	SetProgress(progBar, 1)
	Cmd("Select Drive 1");--reset drive to internal
	coroutine.yield({ui=3})
    Cmd(command);
    StopProgress(progBar);
    overlay.Close();
end

signalTable.Delete = function(caller)
    local overlay = caller:GetOverlay();
    local fname = overlay.Content.FilesView.SelectedFile;

    local drive = IntToHandle(overlay.Title.DriveSelector.SelectedItemValueI64);
    
    local path = drive.Path;    
    if (drive:Index() == 1) then path = ""; end
    local filePath = GetFilePath(overlay);
    if (FileExists(filePath.."/"..fname) == true) then
        if (Confirm('Delete Fixture Type File "'..fname..'"', "Do you really want to delete '"..fname.."'?") == true) then
            os.remove(filePath.."/"..fname);
            overlay.Content.FilesView.BaseFilter = "*.xml,*.gdtf";
        end
    end
end

signalTable.OnFileSelected = function(caller,dummy,rowid)
    if (caller.HasFocus == true) then
        local overlay = caller:GetOverlay();
        local fileNameEdit = overlay.Content.FileContainer.FileName;
        local fileExtension;
        if (overlay.Content.LibraryType:GetListSelectedItemIndex() == 1) then
            fileExtension = ".xml$";
        else
            fileExtension = ".gdtf$";
        end
        local fname = caller.SelectedFile:gsub(fileExtension, "");
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

