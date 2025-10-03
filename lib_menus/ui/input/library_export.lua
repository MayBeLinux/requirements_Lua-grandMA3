local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local initialFilterContent = "";
local initFile = true;
local pathType = nil;

local function GetFilePath(overlay)
    local drive = IntToHandle(overlay.TitleBar.DriveSelector.SelectedItemValueI64);
    local path = drive.Path;
    if (drive:Index() == 1) then path = ""; end

    return GetPathOverrideFor(pathType, path);
end

local function UpdateFileView(content)
    local showFilePath = GetFilePath(content:GetOverlay());
    local fileExtension = ".xml";

    content.FilesView.SetPath(showFilePath);

    if (initFile == true) then
        initFile = false;
        if(initialFilterContent) then
            content.FilesView.SelectedFile = initialFilterContent..fileExtension;
            content.FileContainer.FileName.Content = initialFilterContent;
        end
    end
end

signalTable.OnMenuLoaded = function(caller)
    initialFilterContent = "";
    if (caller:WaitInit(1) ~= true) then
        ErrEcho("Failed to wait");
        return;
    end
	local dest = caller.Context;
	local addArgs = caller.AdditionalArgs;
	if (dest ~= nil) then
		initialFilterContent = dest:GetExportFileName();
		pathType = GetPathType(dest, Enums.PathContentType.User);
	else
		pathType = addArgs.PathType;
		if (pathType == nil or pathType == "") then pathType = Enums.PathType.Library; end
	end

    local helpText = addArgs.HelpText;
    if (helpText ~= nil) then
        caller.Content.ActionButtons.HelpText.Text = helpText
        caller.Content.ActionButtons.HelpText.Visible = true
    end

    local SaveInsteadOfExport = addArgs.SaveInsteadOfExport
    if (SaveInsteadOfExport) then
        caller.Content.ActionButtons.ExportButton.Text = "Save"
    end

    local drive = nil;
    local selDrive = Root().StationSettings.LocalSettings.SelectedDrive;
    for i,d in ipairs(Root().Temp.DriveCollect) do
        if (d.Path == selDrive) then
            caller.TitleBar.DriveSelector:SelectListItemByIndex(i);
            initFile = true;
            drive = d;
            break;
        end
    end
    if (selDrive == "") then --internal
        caller.TitleBar.DriveSelector:SelectListItemByIndex(1);
        initFile = true;
        drive = Root().Temp.DriveCollect[1];
    end
    if (drive) then
        UpdateFileView(caller.Content);
    end

    caller.Content.FilesView.SortByColumn("Desc", 0);
    caller.Content.FileContainer.FileName.SelectAll();
end

signalTable.DriveChange = function(caller,status,driveH,index)
    local drive = IntToHandle(driveH);
    local content = caller:GetOverlay().Content;
    UpdateFileView(content, drive);
    FindBestFocus(content.FileContainer.FileName);
end

signalTable.OnFileSelected = function(caller,signal,row)
    local overlay = caller:GetOverlay();
    overlay.Content.FileContainer.FileName.Content = caller.SelectedFile
end

signalTable.Export = function(caller)
    local overlay = caller:GetOverlay();
    local drive = IntToHandle(overlay.TitleBar.DriveSelector.SelectedItemValueI64);
    local fileName = overlay.Content.FileContainer.FileName.Content;
    local xml = true;

	local dest = overlay.Context;
	local destStr = "UIGridSelection";

	if (dest ~= nil) then
		destStr = dest:ToAddr();
	end

	local command = "Export";
	local addOpt = "";
	local path = drive.Path;
	if (drive:Index() == 1) then path = "" end;
	if xml then
		command = command.." "..destStr;
	end
	if (fileName~="") then
		command = command.. " /File '"..fileName.."'";
	end
	command = command .. addOpt;
	Cmd(command);
    overlay.Close();
end
