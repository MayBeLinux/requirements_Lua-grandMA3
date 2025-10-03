local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnGridLoaded = function(caller,status,creator)
	local input = caller:Parent():Parent();
	
	local geometryCollect = FixtureType().Geometries
	Echo(tostring(geometryCollect))
	caller.TargetObject=geometryCollect;
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local geometry=IntToHandle(row_id);
	if geometry:IsValid() then
		local addr = geometry:AddrNative(caller.TargetObject);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
end