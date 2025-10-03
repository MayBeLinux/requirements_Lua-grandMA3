local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.OnLoaded = function(caller,status,creator)
	local Patch = Patch();
	if (Patch) then
		local IDTypes = Patch.IDTypes;
		if (IDTypes) then
			for i,v in ipairs(IDTypes:Children()) do
				caller:AddListStringItem(v.Name, v.Name);
			end
		end
		caller:SelectListItemByValue(caller.Value);
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
