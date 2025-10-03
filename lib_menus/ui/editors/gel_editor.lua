local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)	
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	local editor = caller:GetOverlay();
	local target = editor.EditTarget;
	editor.TitleBar:SetChildren("Target", target);
	editor.Frame:SetChildren("Target", target);
end

signalTable.ImportGel = function(caller,dummy,target)
	local overlay = caller:GetOverlay();
	local libImport = Root().Menus.LibraryImport;
	if (libImport) then
		local target = overlay.EditTarget;
		if (target ~= nil) then
			local targetAddr = "Root " .. target:Addr();
			local libImportUI = libImport:CommandCall(caller,false);
			if (libImportUI) then
				libImportUI:InputSetAdditionalParameter("Destination", targetAddr);
				libImportUI:InputSetAdditionalParameter("Library", "Gel Library");
				libImportUI:InputSetTitle("Import Gel from:");
				libImportUI:InputRun();

				libImportUI:Parent():Remove(libImportUI:Index());
				WaitObjectDelete(libImportUI, 1);
				FindNextFocus();
			end
		end
	end
end

signalTable.ExportGel = function(caller,dummy,target)
	local overlay = caller:GetOverlay();
	local libExport = Root().Menus.LibraryExport;
	if (libExport) then
		local target = overlay.EditTarget;
		if (target ~= nil) then
			local libExportUI = libExport:CommandCall(caller,false);
			if (libExportUI) then
				libExportUI.Context = target;
				libExportUI:InputSetTitle("Export Gel to:");
				libExportUI:InputRun();

				libExportUI:Parent():Remove(libExportUI:Index());
				WaitObjectDelete(libExportUI, 1);
				FindNextFocus();
			end
		end
	end
end

signalTable.LoadImportExportButton = function(caller)
	if IsObjectValid(caller) then
		local editor = caller:GetOverlay();
		local target = editor.EditTarget;
		if target and (target:Parent().Lock == "Yes") then
		    caller.Enabled = false;
			caller.AutoEnabled = false;			
        end
	end
end