local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	local FixtureTypes=Patch().FixtureTypes;
	for i,fixture_type in ipairs(FixtureTypes:Children()) do
		caller:AddListObjectItem(fixture_type);
	end
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end