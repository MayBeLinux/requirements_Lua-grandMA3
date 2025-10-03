local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.Switchgma3Target = function(caller,signal)
	signalTable:DoCommand(caller,"switchtograndma3")
end

signalTable.Switchgma2Target = function(caller,signal)
	signalTable:DoCommand(caller,"switchtograndma2")
end

signalTable.RestartTarget = function(caller,signal)
	signalTable:DoCommand(caller,"restart")
end

signalTable.RebootTarget = function(caller,signal)
	signalTable:DoCommand(caller,"reboot")
end

signalTable.DoCommand = function(d, caller,command)
	local grid = caller:GetOverlay().Content.ManetStationGrid;
	local grSel = grid:GridGetSelection();
	local selectedItems = grSel.SelectedItems;

	for i,v in ipairs(selectedItems) do
		local object = IntToHandle(v.row);
		if object~=-1 then
			--CmdIndirect("reboot IP "..object.IP)
			CmdIndirect(command.." IP "..object.IP)
		else
			Echo("remotecommand was not sent")
		end
	end
end
