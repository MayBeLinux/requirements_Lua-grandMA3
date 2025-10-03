local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnWindowManagerLoad = function(caller)
	local addArgs = caller.AdditionalArgs;
	local insertType = addArgs.InsertType;

	if (addArgs.Mode == "Save") then
		-- caller.DialogFrame.ImportBtn.Enabled = false;
		caller.DialogFrame.LoadSaveBtn.Text = "Save";
	elseif (addArgs.Mode == "Load") then
		-- caller.DialogFrame.ExportBtn.Enabled = false;
		caller.DialogFrame.InsertBtn.Enabled = false;
		caller.DialogFrame.DeleteBtn.Enabled = false;
		caller.DialogFrame.LoadSaveBtn.Text = "Load";
	end

	-- Set InsertType
	if insertType then
		if insertType == "GenericPoolSettings" then insertType = "PoolSettings" end
		caller.DialogFrame.ObjectGrid.InsertType = insertType;
		caller.DialogFrame.InsertBtn.SignalValue = "Insert Type "..insertType.." UIGridSelection";
	end
end

signalTable.OnSelectedPreference = function(caller)
	local Overlay  = caller:GetOverlay();
	local ObjectGrid=Overlay.DialogFrame.ObjectGrid;
	local Selected  =IntToHandle(ObjectGrid.SelectedRow);

	if (Selected == nil) then
		local o = ObjectGrid.TargetObject;
		local addArgs = caller:GetOverlay().AdditionalArgs;
		if (o and (addArgs.Mode ~= "Load")) then
			Selected = o:Append(ObjectGrid.InsertType);
		end
	end

	Overlay.Value=HandleToStr(Selected);
	Overlay:Close();
end