local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnGridLoaded = function(caller,status,creator)
	caller.TargetObject=Root().ColorTheme.ColorDefCollect;
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local color_def=IntToHandle(row_id);
	if(color_def:IsValid()) then
		local addr = color_def:AddrNative(Root().ColorTheme.ColorDefCollect);
		Echo("Color addr: "..addr);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
end

signalTable.DeleteDefRef = function(caller,status,creator)
	caller:GetOverlay().Value = "";
	caller:GetOverlay():Close();
end