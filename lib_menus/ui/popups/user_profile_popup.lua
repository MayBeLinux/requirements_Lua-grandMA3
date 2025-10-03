local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function CreateNewProfile(caller, arg)
	local profile=nil;
	local newProfileName = TextInput("a new user profile name");
	if (newProfileName) then
		local cr, objs = Cmd("Store UserProfile '%s'", newProfileName)
		if cr == "OK" then
			profile = objs[1]
		end
	else
		return; --it was canceled
	end

	return caller, profile;
end

signalTable.OnLoaded = function(caller,status,creator)
	local userProfiles = Root().ShowData.UserProfiles;
	if (userProfiles) then
	    caller:AddListChildren(userProfiles);
        caller:AddListLuaItem("New Profile", "CreateNewProfile", CreateNewProfile);
		caller:SelectListItemByValue(caller.Value);
		caller:Changed();
	end
end
