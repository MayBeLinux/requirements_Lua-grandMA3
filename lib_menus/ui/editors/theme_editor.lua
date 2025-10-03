local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local TitleButton = nil;

signalTable.OnLoaded = function(caller,status,creator)
	Echo("ThemeEditor:OnLoaded");
end

local function UpdateTitle()
	TitleButton.Text = "Edit Color Theme '"..Root().ColorTheme.FileName.."'"
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	Echo("ThemeEditor:OnSetEditTarget");
	local Content=caller.Content;
	Content.Grid1.TargetObject=target.ColorDefCollect;
	Content.Grid2.TargetObject=target.ColorGroups;
	TitleButton = caller.TitleBar.Title;
	UpdateTitle();
end

signalTable.ExportAsClicked = function(caller,dummy)
	local libExport = Root().Menus.LibraryExport;
	if (libExport) then
		local libExportUI = libExport:CommandCall(caller,false);
		if (libExportUI) then
			libExportUI.Context = Root().ColorTheme;
			libExportUI:InputSetTitle("Export Color Theme as:");
			result = libExportUI:InputRun();
			if (result) then
				local fn = libExportUI.Content.FileContainer.FileName.Content;
				if (fn ~= "") then
					Root().ColorTheme.FileName = fn;
				end
			end

			libExportUI:Parent():Remove(libExportUI:Index());
			WaitObjectDelete(libExportUI, 1);
			FindNextFocus();

			UpdateTitle();
		end
	end
end

signalTable.DeleteClicked = function(caller,dummy)
	local ct = Root().ColorTheme;
	if (string.upper(ct.FileName) ~= string.upper("Default")) then
		if (Confirm("Deleting Color Theme '"..ct.FileName.."'", "The theme file will be removed permanently.\nDo you want to continue ?", caller:GetDisplayIndex())) then
			Cmd("Delete ColorTheme /nc");
			UpdateTitle();
		end
	else
		ErrEcho("Cannot delete a default theme");
	end
end


