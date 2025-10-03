local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
	local relation = caller.Context;
	if (relation) then
		caller:AddListStringItem("None","");
		local dmxMode = relation:FindParent("DMXMode");
		if (dmxMode) then
			local dmxChannels = dmxMode.DMXChannels;
			if (dmxChannels) then
				caller:AddListChildrenNames(dmxChannels);
			end
			caller:SelectListItemByValue(caller.Value);
		end
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
