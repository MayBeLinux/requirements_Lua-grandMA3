local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	Echo("Mesh Editor OnLoaded");
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	Echo("Mesh Editor LUA OnSetEditTarget");
	caller.Frame:SetChildren("Target",target);
    caller.Frame.MaterialGrid.TargetObject=target;
	caller.Frame.MessagesLineEdit.Target=target;
	caller.Frame.OrgButtons._OrgVerticesCount.Target=target;
	caller.Frame.OrgButtons._OrgMeshCount.Target=target;
end

signalTable.ImportMesh = function(caller,dummy,target)
	Echo("Mesh Editor OnImportMesh");
	local o = caller:GetOverlay();
	local libImport = Root().Menus.LibraryImport;
	if (libImport) then
		local et = o.EditTarget;
		if (et ~= nil) then
			local targetAddr = "Root "..et:Addr();
			local libImportUI = libImport:CommandCall(caller,false);
			if (libImportUI) then
				libImportUI:InputSetAdditionalParameter("Destination", targetAddr);
				libImportUI:InputSetAdditionalParameter("Library", "Mesh Library");
				libImportUI:InputSetTitle("Import mesh from:");
				libImportUI:InputRun();

				libImportUI:Parent():Remove(libImportUI:Index());
				WaitObjectDelete(libImportUI, 1);
				FindNextFocus();
			end
		end
	end
end


