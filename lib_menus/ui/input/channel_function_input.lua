local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnGridLoaded = function(caller,status,creator)
	local input = caller:Parent():Parent();
	local target = input.Context;
	if (target) then
		local dmxMode = target:FindParent("DMXMode")
		caller.TargetObject=dmxMode.DMXChannels;
	end
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local cf=IntToHandle(row_id);
	if(cf:IsValid() and (cf:GetClass() == "ChannelFunction")) then
		local addr = cf:AddrNative(caller.TargetObject);
		caller:GetOverlay().Value = addr;
		caller:GetOverlay():Close();
	end
end