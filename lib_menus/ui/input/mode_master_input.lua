local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnGridLoaded = function(caller,status,creator)
	local input = caller:Parent():Parent();
	local channelFunction = input.Context;
    Echo("channelFunction: "..tostring(channelFunction));
	if (channelFunction) then
		caller.TargetObject=channelFunction:Parent():Parent():Parent();
	end
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local cf=IntToHandle(row_id);
	if(cf:IsValid() and (cf:GetClass() == "ChannelFunction")) then
		local addr = cf:AddrNative(caller.TargetObject);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
	if(cf:IsValid() and (cf:GetClass() == "DMXChannel")) then
		local addr = cf:AddrNative(caller.TargetObject);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
end

signalTable.RemoveMaster = function(caller,status,col_id,row_id)
	local o = caller:GetOverlay();
	o.Value = "";
	o:Close();
end