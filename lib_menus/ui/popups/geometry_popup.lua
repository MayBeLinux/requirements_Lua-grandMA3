local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
	local fixtureType = FixtureType();
    caller:AddListStringItem("None","");
	Echo("Val: "..caller.Value);
	if (fixtureType) then
		local geometries = fixtureType.Geometries;
		if (geometries) then
            for _,geometry in ipairs(geometries:Children()) do
                local geometryName = geometry.Name;
				if(not caller.Context:HasParent(geometry) and geometry.Type ~= "GeometryReference") then
					caller:AddListObjectItem(geometry);
				end
			end
		end
		caller:SelectListItemByValue(caller.Value);
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
