local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnGridLoaded = function(caller,status,creator)
	caller.TargetObject=Root().ColorTheme.ColorGroups;
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local color_ref=IntToHandle(row_id);
	if(color_ref:IsValid()) then
		local addr = color_ref:AddrNative(Root().ColorTheme.ColorGroups);
		Echo("Color addr: "..addr);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
end