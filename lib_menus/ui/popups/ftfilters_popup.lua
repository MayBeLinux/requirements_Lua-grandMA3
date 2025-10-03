local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    caller:AddListStringItem("None","");
	local target = caller.Context;
	local ft = target:FindParent("FixtureType");
	local physDescr = ft.PhysicalDescriptions;
	local filterCollect = physDescr.FTFilters;
	caller:AddListChildren(filterCollect);
	caller:SelectListItemByValue(caller.Value);

	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
