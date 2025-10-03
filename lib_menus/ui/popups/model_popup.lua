local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
	local fixtureType = FixtureType();
    caller:AddListStringItem("None","");
	caller:SetContextSensHelpLink("ft_link_models_geometries.html");

	if (fixtureType) then
		local models = fixtureType.Models;
		if (models) then
            for _,model in ipairs(models:Children()) do
				caller:AddListObjectItem(model);
			end
		end
		caller:SelectListItemByValue(caller.Value);
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
