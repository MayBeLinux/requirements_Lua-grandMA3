local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function(caller)
	local user=caller.Context;
	if(user) then
		local profile=user.Profile;
		if(profile) then
			-- Echo("Get Pool for context ".. user.Name .." : ".. profile.Name);
			return profile.ScreenConfigurations;
		end
	end
end

local function OnAddNew(caller)
	local new_obj=signalTable.GetPool(caller):Acquire();
	return caller,new_obj;
end

signalTable.OnLoaded = function(caller,status,creator)
	local pool = signalTable.GetPool(caller);
	if(pool) then
	    caller:AddListChildren(pool);
		caller:AddListLuaItem("New","OnAddNew", OnAddNew);
		caller:SelectListItemByValue(caller.Value);
		caller:Changed();
	end
end
