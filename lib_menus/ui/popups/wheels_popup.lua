local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    caller:AddListStringItem("None","");
	local channelFunction = caller.Context;
    if(channelFunction) then
        local logicalChannel = channelFunction:Parent();
		local dmxChannel = logicalChannel:Parent();
		local dmxChannelCollect = dmxChannel:Parent();
		local dmxMode  = dmxChannelCollect:Parent();
		local dmxModeCollect = dmxMode:Parent();
		local ft = dmxModeCollect:Parent();
		caller:AddListChildren(ft.Wheels);
        caller:SelectListItemByValue(caller.Value);
    end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
