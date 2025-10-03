local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    caller:AddListStringItem("None","");

	local target = caller.Context
	-- in case of ChannelFunction: .. logicalChannel .. dmxChannel .. dmxChannelCollect .. dmxMode .. dmxModeCollect .. fixtureType
	local ft = target:FindParent("FixtureType")
	local physDescr = ft.PhysicalDescriptions;
	local gamutCollect = physDescr.GamutCollect;
	caller:AddListChildren(gamutCollect);
	caller:SelectListItemByValue(caller.Value);

    
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
