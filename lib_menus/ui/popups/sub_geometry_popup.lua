local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local IGNORE_GEOMETRY = nil

local function AddGeometry(caller, parent, geometryAddress)
    if (parent) then
        for _,geometry in ipairs(parent:Children()) do
            local geometryName = geometry.Name;
            local address = geometryAddress .. geometryName
            if(geometry.Type ~= "GeometryReference" and geometry ~= IGNORE_GEOMETRY) then
                AddGeometry(caller, geometry, address..".");
                caller:AddListObjectItem(geometry);
            end
        end
    end
end

signalTable.OnLoaded = function(caller,status,creator)
    IGNORE_GEOMETRY = caller.Context
    
    caller:AddListStringItem("None","");
    --caller:SetContextSensHelpLink("ft_link_dmx_modes_to_geometries.html");
    
    local fixtureType = FixtureType();
    if (fixtureType) then
        local geometries = fixtureType.Geometries;
        if (geometries) then
            AddGeometry(caller, geometries, "");
        end
        caller:SelectListItemByValue(caller.Value);
    end
    caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end

