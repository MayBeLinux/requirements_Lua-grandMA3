local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    -- caller:AddListStringItem("None","");

	local target = caller.Context
	if target:GetClass() == "DMXChannel" then
		local logicalChannels = target:Children()
		for _,v in ipairs(logicalChannels) do
			caller:AddListChildren(v) -- add all ChannelFunctions of LogicalChannel
		end
	end

	if target:GetClass() == "FTMacro" then
		caller:AddListStringItem("None","");
		local mode = target:Parent():Parent() -- DMXMode/FTMacros/FTMacro
		local dmxChannels = mode[1]:Children() -- DMXMode/DmxChannels/...
		for _,dmxChannel in ipairs(dmxChannels) do
			local logicalChannels = dmxChannel:Children()
			for _,logicalChannel in ipairs(logicalChannels) do
				caller:AddListChildren(logicalChannel)
			end
		end
	end
	
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
