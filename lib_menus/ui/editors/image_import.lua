local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local lastState = {
	filterSettings = {
	   name = true
	}
};
-- -----------------------------------------------------------------------------------
signalTable.ImporterLoaded = function(caller,status,creator)
	local Title=caller.Title;
	local Frame=caller.Frame;

	CmdObj().ClearCmd();

	local lib = CmdObj().Library;
	lib:Changed()
	coroutine.yield()

	Frame.LeftArea.ImageGrid.TargetObject = lib;
	local currentDrive = Root().StationSettings.LocalSettings.SelectedDrive;
	local driveFound = false;
	for i,d in ipairs(Root().Temp.DriveCollect) do
		if (d.Path == currentDrive) then
			Title.DriveSelector:SelectListItemByIndex(i);
			driveFound = true;
			break;
		end
	end
	if ((currentDrive == "") or (driveFound ~= true)) then --internal
		Title.DriveSelector:SelectListItemByIndex(1);
	end

	signalTable.Preview=Frame.Preview;

	signalTable.Preview.Appearance = CmdObj():Ptr(5);
	Frame.LeftArea.ImageGrid.SortByColumn("Asc", 0);

	Frame.LeftArea.FilterSwitches.FilterName.Target = caller;
	caller.FilterByName = lastState.filterSettings.name;
	local filter = caller.FilterComposed;
	Echo("Loaded filter: "..filter);
    caller.Frame.LeftArea.ImageGrid.Internals.GridBase.GridSettings.GridContentFilter.Filter.Columns = filter;

	signalTable:UpdateLibrary();

	local mediaPool = nil
	local tooBigMsg = nil
	local poolLimitMB = nil
	if Global_CurrentImagePoolName == "Videos" then
		mediaPool = ShowData().MediaPools.Videos
		poolLimitMB = 100
		tooBigMsg = "Importing the selected video file would violate the video pool maximum content size boundary "
	elseif Global_CurrentImagePoolName == "Images" then
		mediaPool = ShowData().MediaPools.Images
		poolLimitMB = 50
		tooBigMsg = "Importing the selected image file would violate the image pool maximum content size boundary "
	end
	if mediaPool then
		local sf = mediaPool
		local s = sf.MemoryFootprint
		local i = 1;
		local units = { "B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" };
		while s > 1024 do
		    s = s // 1024;
		    i = i + 1;
		end
		caller.Frame.TooBigError.Text = tooBigMsg.." (used "..s..units[i].." of "..poolLimitMB.."MB) "
	end
end

-- -----------------------------------------------------------------------------------
signalTable.UpdateLibrary = function()	
	-- creating XML-Files if necessary
	local currentPool    = Root().ShowData.MediaPools[Global_CurrentImagePoolName];
	local libraryCollect = CmdObj().Library;
	-- currentPool.AppendWhenCreateXML = false;
	Cmd("UpdateContent Image "..Global_CurrentImagePoolName);
	RefreshLibrary(currentPool);
end


-- -----------------------------------------------------------------------------------
signalTable.ImageGridOnChar = function(caller,dummy,keyCode)
	if (keyCode == Enums.KeyboardCodes.Enter) then--\n
		signalTable.DoImportImage(caller,dummy);
	end
end

-- -----------------------------------------------------------------------------------
signalTable.DriveChange = function(caller,status,driveH,index)
	signalTable:UpdateLibrary();
end

-- -----------------------------------------------------------------------------------
signalTable.DoImportImage = function(caller,dummy)
	local o = caller:GetOverlay();
	local gr = o.Frame.LeftArea.ImageGrid;
	local LibraryFile = IntToHandle(gr.SelectedRow);
	if ((LibraryFile ~= nil) and (LibraryFile.FileName ~= nil)) then
		local grSel = gr:GridGetSelection();
		local selectedItems = grSel.SelectedItems;
		local selCount = #selectedItems;
		local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(CmdObj());

		local cmdStr = "";
		if selCount > 1 and frameSelectionIndex > 0 then
			cmdStr = string.format("Import _FrameSelection %d At Image '%s'.%d Thru %d /nc", frameSelectionIndex, Global_CurrentImagePoolName,Global_CurrentImagePoolElementNo, Global_CurrentImagePoolElementNo + selCount - 1);
		else
			cmdStr = string.format("Import Image '%s'.%d  /File \"%s\" /Path \"%s\" /nc",Global_CurrentImagePoolName,Global_CurrentImagePoolElementNo,LibraryFile.FileName,LibraryFile.Path);
		end

		Cmd(cmdStr);
	end
	o.Close();
end

-- signalTable.OnDoubleClicked = function(caller,dummy)
-- 	local o = caller:GetOverlay();
-- 	local gr = o.Frame.LeftArea.ImageGrid;
-- 	local LibraryFile = IntToHandle(gr.SelectedRow);
-- 	if ((LibraryFile ~= nil) and (LibraryFile.FileName ~= nil)) then
-- 		local grSel = gr:GridGetSelection();
-- 		local selectedItems = grSel.SelectedItems;
-- 		local selCount = #selectedItems;
-- 		
-- 		local cmdStr = "";
-- 		if selCount > 0 then
-- 			cmdStr = string.format("Import Image '%s'.%d  /File \"%s\" /Path \"%s\" /nc",Global_CurrentImagePoolName,Global_CurrentImagePoolElementNo,LibraryFile.FileName,LibraryFile.Path);
-- 		end

-- 		Cmd(cmdStr);
-- 	end
-- 	o.Close();
-- end

-- -----------------------------------------------------------------------------------
signalTable.OnSelected = function(caller,status,col_id,row_id)
	local o = caller:GetOverlay();
	local gr = o.Frame.LeftArea.ImageGrid;
	local LibraryFile = IntToHandle(gr.SelectedRow);
	if ((LibraryFile ~= nil) and (LibraryFile.FileName ~= nil)) then
		o.SelectedRow=LibraryFile
	end
	
	if ((LibraryFile ~= nil) and (LibraryFile.CachedObjFileName ~= nil) and (LibraryFile.CachedObjFileName ~= "")) then
		o.Frame.TooBigError.Visible = LibraryFile.TooBig
	end
end

-- -----------------------------------------------------------------------------------
signalTable.ImageFilterChanged = function(caller, newFilter)
	Echo("Filter changed: "..newFilter);
    caller.Frame.LeftArea.ImageGrid.Internals.GridBase.GridSettings.GridContentFilter.Filter.Columns = newFilter;

	lastState.filterSettings.name = caller.FilterByName;
end

-- -----------------------------------------------------------------------------------
signalTable.ClearFilters = function(caller,dummy)
	local o = caller:GetOverlay();
	o.Frame.LeftArea.FilterBlock.FilterEdit.Clear();
end
