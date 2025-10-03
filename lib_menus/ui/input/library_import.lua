local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetLibraryToken(o)
	local addArgs = o.AdditionalArgs;
	local l = addArgs.Library;
	if ((l == nil) or (l == "")) then l = "Library"; end

	return l;
end

local function RefreshLibrary(o)
	Cmd(GetLibraryToken(o));
end

signalTable.OnMenuLoaded = function(caller)
	local currentDrive = Root().StationSettings.LocalSettings.SelectedDrive;
	local driveFound = false;
	for i,d in ipairs(Root().Temp.DriveCollect) do
		if (d.Path == currentDrive) then
			caller.TitleBar.DriveSelector:SelectListItemByIndex(i);
			driveFound = true;
			break;
		end
	end
	if ((currentDrive == "") or (driveFound ~= true)) then --internal
		caller.TitleBar.DriveSelector:SelectListItemByIndex(1);
	end

	RefreshLibrary(caller);
	local addArgs = caller.AdditionalArgs;
	local singleImport = true;
	if (addArgs ~= nil and addArgs.Destination ~= nil and addArgs.Destination ~= "" and addArgs.TargetIndex ~= nil and addArgs.ReturnFileName ~= "Yes") then
		singleImport = false;
	end

	local gr = caller.Frame.LibraryGrid;
	local importBtn = caller.Frame.ActionButtons.ImportBtn;
	if singleImport then
		--gr.OnSelectedItem = "ImportSingle";
		gr.SelectionType = "SingleRowGridSelection";
		importBtn.Clicked = "ImportSingleBtn";
	else
		--gr.OnSelectedItem = "";
		gr.SelectionType = "ColumnGridSelection";
		importBtn.Clicked = "ImportSelection";
	end

	local helpText = addArgs.HelpText;
    if (helpText ~= nil) then
        caller.Frame.ActionButtons.HelpText.Text = helpText
        caller.Frame.ActionButtons.HelpText.Visible = true
    end

	local LoadInsteadOfImport = addArgs.LoadInsteadOfImport
    if (LoadInsteadOfImport) then
        caller.Frame.ActionButtons.ImportBtn.Text = "Load"
    end
end

signalTable.OnGridLoaded = function(caller,status,creator)
	caller.TargetObject=CmdObj().Library;
end

signalTable.LibraryHandleSelect = function(caller,status,col_id,row_id,active_select)
	if active_select == true then
		local o = caller:GetOverlay();
		local importBtn = o.Frame.ActionButtons.ImportBtn;
		importBtn.Clicked(dummy)
	end
end


signalTable.ImportSingleBtn = function(caller)
	local o = caller:GetOverlay();
	local addArgs = o.AdditionalArgs;
	local cmdO = CmdObj();
	local dest = cmdO.Destination;
	local nextIndex = dest:Count() + 1;
	local gr = caller:Parent():Parent().LibraryGrid;
	local grSel = gr:GridGetSelection();
	local selectedItems = grSel.SelectedItems;
	local selCount = #selectedItems;
	if selCount > 0 then
		signalTable.ImportSingle(caller, nil, nil, selectedItems[1].row);
	end
end

signalTable.ImportSingle = function(caller,status,col_id,row_id)
	local library_file=IntToHandle(row_id);
	if(library_file:IsValid()) then
		local o = caller:GetOverlay();
		local addArgs = o.AdditionalArgs;
		local cmdO = CmdObj();
		local dest = cmdO.Destination;
		local nextIndex = dest:Count() + 1;
		local cmd = "Import "..GetLibraryToken(o).." " .. library_file:Index();
		local destTgt = nil;
		if (addArgs) then destTgt = addArgs.Destination; end
		if (destTgt ~= nil and destTgt ~= "") then cmd = cmd .. " At "..destTgt; end;
		cmd = cmd .. " /NoConfirm";

		if addArgs and addArgs.ImportOptions ~= nil then cmd = cmd .. " "..addArgs.ImportOptions end

		if (addArgs.ReturnFileName == "Yes") then
			o.Value = library_file.FileName;
		end

		Cmd(cmd);

		if (not(destTgt ~= nil and destTgt ~= "")) then
			local importedObject = dest:Ptr(nextIndex);
			if (importedObject) then
				if (addArgs.ReturnFileName ~= "Yes") then
					o.Value = importedObject:AddrNative(nil);
				end
			end
		end
		o:Close();
	end

end

signalTable.ImportSelection = function(caller,status)
	local o = caller:GetOverlay();
	local addArgs = o.AdditionalArgs;
	local cmdO = CmdObj();
	local dest = cmdO.Destination;
	local nextIndex = dest:Count() + 1;
	local gr = caller:Parent():Parent().LibraryGrid;
	local grSel = gr:GridGetSelection();
	local selectedItems = grSel.SelectedItems;
	local selCount = #selectedItems;
	local frameSelectionIndex = gr:GridGetData().CreateFrameSelection(cmdO);
	if frameSelectionIndex > 0 then
		local cmd = "Import _FrameSelection "..tostring(frameSelectionIndex);
		local destTgt = nil;
		if (addArgs) then destTgt = addArgs.Destination; end
		if (destTgt ~= nil and destTgt ~= "") then 
			cmd = cmd .. " At "..destTgt; 
			if selCount > 1 and addArgs.TargetIndex ~= nil then
				cmd = cmd .. " Thru " .. tostring(tonumber(addArgs.TargetIndex) + selCount - 1);
			end
		end;
		cmd = cmd .. " /NoConfirm";

		if addArgs and addArgs.ImportOptions ~= nil then cmd = cmd .. " "..addArgs.ImportOptions end

		Cmd(cmd);

		o:Close();
	end
end

signalTable.DriveChange = function(caller,status,driveH,index)
	RefreshLibrary(caller:GetOverlay());
end

signalTable.JumpToGrid = function(caller)
	local o = caller:GetOverlay();
	FindNextFocus();
end

