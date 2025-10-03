local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame:SetChildren("Target",target);
end

signalTable.ImportMaterial = function(caller,dummy,target)
	local o = caller:GetOverlay();
	local libImport = Root().Menus.LibraryImport;
	if (libImport) then
		local et = o.EditTarget;
		if (et ~= nil) then
			local targetAddr = "Root "..et:Addr();
			local libImportUI = libImport:CommandCall(caller,false);
			if (libImportUI) then
				libImportUI:InputSetAdditionalParameter("Destination", targetAddr);
				libImportUI:InputSetAdditionalParameter("Library", "Material Library");
				libImportUI:InputSetTitle("Import material from:");
				libImportUI:InputRun();

				libImportUI:Parent():Remove(libImportUI:Index());
				WaitObjectDelete(libImportUI, 1);
				FindNextFocus();
			end
		end
	end
end


