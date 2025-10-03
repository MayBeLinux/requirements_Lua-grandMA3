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


	local lib = CmdObj().Library
	lib:Changed()
	coroutine.yield()
	Frame.LeftArea.SoundGrid.TargetObject = CmdObj().Library;
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

	--signalTable.Preview=Frame.LeftArea.Preview;

	Frame.LeftArea.SoundGrid.SortByColumn("Asc", 0);

	Frame.LeftArea.FilterSwitches.FilterName.Target = caller;
	caller.FilterComposed = lastState.filterSettings.name;
	local filter = caller.FilterComposed;
	Echo("Loaded filter: "..filter);
	caller.Frame.LeftArea.SoundGrid.Internals.GridBase.GridSettings.GridObjectContentFilter.Filter.Filter = filter;

	signalTable:UpdateLibrary();

	local sf = ShowData().MediaPools.Sounds
	local s = sf.MemoryFootprint
        local i = 1;
        local units = { "B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" };
        while s > 1024 do
            s = s // 1024;
            i = i + 1;
	end
	caller.Frame.PlayerBlock.TooBigError.Text = "Importing the selected audio file would violate the sound pool maximum content size boundary (used "..s..units[i].." of 100MB) "
end

-- -----------------------------------------------------------------------------------
signalTable.UpdateLibrary = function()
	-- creating XML-Files if necessary
	local currentPool    = Root().ShowData.MediaPools.Sounds
	local libraryCollect = CmdObj().Library;
	-- currentPool.AppendWhenCreateXML = false;
	Cmd("UpdateContent Sound");
	RefreshLibrary(currentPool);
end


-- -----------------------------------------------------------------------------------
signalTable.SoundGridOnChar = function(caller,dummy,keyCode)
	if (keyCode == Enums.KeyboardCodes.Enter) then--\n
		signalTable.DoImportSound(caller,dummy);
	end
end

-- -----------------------------------------------------------------------------------
signalTable.DriveChange = function(caller,status,driveH,index)
	signalTable:UpdateLibrary();
end

-- -----------------------------------------------------------------------------------
signalTable.DoImportSound = function(caller,dummy)
	local o = caller:GetOverlay();
	local gr = o.Frame.LeftArea.SoundGrid;
	local LibraryFile = IntToHandle(gr.SelectedRow);
	if ((LibraryFile ~= nil) and (LibraryFile.FileName ~= nil)) then
		local grSel = gr:GridGetSelection();
		local selectedItems = grSel.SelectedItems;
		local selCount = #selectedItems;
		local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(CmdObj());

		local cmdStr = "";
		if selCount > 1 and frameSelectionIndex > 0 then
			cmdStr = string.format("Import _FrameSelection %d At Sound %d Thru %d /nc", frameSelectionIndex, Global_CurrentSoundPoolElementNo, Global_CurrentSoundPoolElementNo + selCount - 1);
		else
			cmdStr = string.format("Import Sound %d  /File \"%s\" /Path \"%s\" /nc",Global_CurrentSoundPoolElementNo,LibraryFile.FileName,LibraryFile.Path);
		end
		
		CmdIndirectWait(cmdStr);
	end
	o.Close();
end

-- signalTable.OnDoubleClicked = function(caller,dummy)
-- 	local o = caller:GetOverlay();
-- 	local gr = o.Frame.LeftArea.SoundGrid;
-- 	local LibraryFile = IntToHandle(gr.SelectedRow);
-- 	if ((LibraryFile ~= nil) and (LibraryFile.FileName ~= nil)) then
-- 		local grSel = gr:GridGetSelection();
-- 		local selectedItems = grSel.SelectedItems;
-- 		local selCount = #selectedItems;
		
-- 		local cmdStr = "";
-- 		if selCount > 0 then
-- 			cmdStr = string.format("Import Sound %d  /File \"%s\" /Path \"%s\" /nc",Global_CurrentSoundPoolElementNo,LibraryFile.FileName,LibraryFile.Path);
-- 		end
		
-- 		CmdIndirectWait(cmdStr);
-- 	end
-- 	o.Close();
-- end

-- -----------------------------------------------------------------------------------
signalTable.OnSelected = function(caller,status,col_id,row_id)
	local o = caller:GetOverlay();
	local gr = o.Frame.LeftArea.SoundGrid;
	local LibraryFile = IntToHandle(gr.SelectedRow);
	if ((LibraryFile ~= nil) and (LibraryFile.CachedObjFileName ~= nil) and (LibraryFile.CachedObjFileName ~= "")) then
		o.Frame.Preview.TargetPath = LibraryFile.Path.."/"..LibraryFile.CachedObjFileName
		o.Frame.PlayerBlock.TooBigError.Visible = LibraryFile.TooBig
	end
end

-- -----------------------------------------------------------------------------------
signalTable.SoundFilterChanged = function(caller, newFilter)
	Echo("Filter changed: "..newFilter);
        caller.Frame.LeftArea.SoundGrid.Internals.GridBase.GridSettings.GridObjectContentFilter.Filter.Filter = newFilter;

	lastState.filterSettings.name = caller.FilterByName;
end

-- -----------------------------------------------------------------------------------
signalTable.ClearFilters = function(caller,dummy)
	local o = caller:GetOverlay();
	o.Frame.LeftArea.FilterBlock.FilterEdit.Clear();
end
