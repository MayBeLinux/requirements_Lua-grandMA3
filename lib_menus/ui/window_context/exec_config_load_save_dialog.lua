local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller)
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
		caller.DialogFrame.ObjectGrid.InsertType = insertType;
		caller.DialogFrame.InsertBtn.SignalValue = "Insert Type "..insertType.." UIGridSelection";
	end
end

signalTable.OnConfigDatapoolLoad = function(caller)
	caller:WaitInit(1)
	for i = 1, caller:GetListItemsCount() do
		local intHandle = caller:GetListItemValueI64(i);
		if (intHandle == HandleToInt(DataPool())) then
			caller:SelectListItemByIndex(i);
		end
	end
end

signalTable.OnSelectedPreference = function(caller)
	local Overlay  = caller:GetOverlay();
	local ObjectGrid=Overlay.DialogFrame.ObjectGrid;
	local Selected  =IntToHandle(ObjectGrid.SelectedRow);
	local mode = caller.SignalValue

	Overlay:InputSetAdditionalParameter("Mode", mode)

	if (Selected == nil) then
		local o = ObjectGrid.TargetObject;
		local mode = caller.SignalValue;
		if (o and (mode ~= "Load")) then
			Selected = o:Append(ObjectGrid.InsertType);
		end
	end

	Overlay.Value=HandleToStr(Selected);
	Overlay:Close();
end

signalTable.OnDataPoolChanged = function(caller)
	local selectedDataPool = caller.SelectedItemIdx
	local dialog = caller:GetOverlay()
	local datapool = IntToHandle(caller.SelectedItemValueI64)
	local grid = dialog.DialogFrame.ObjectGrid
	grid.TargetObject = datapool.Configurations
end

signalTable.OnListReference = function(caller)
	local Overlay  = caller:GetOverlay();
	local ObjectGrid = Overlay.DialogFrame.ObjectGrid;
	local Selected  = IntToHandle(ObjectGrid.SelectedRow);

	local addr = ToAddr(Selected)
	if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.OnRecast = function(caller)
	local Overlay  = caller:GetOverlay();
	local ObjectGrid = Overlay.DialogFrame.ObjectGrid;
	local Selected  = IntToHandle(ObjectGrid.SelectedRow);

	local addr = ToAddr(Selected)
	if(addr) then CmdIndirect("Recast "..addr); end
end