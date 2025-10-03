local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
	return Programmer();
end

-- local function OnAddNew(caller)
--	Cmd("Store Programmer");
--	return caller,CurrentEnvironment().ProgPart;
-- end

signalTable.OnLoaded = function(caller,status,creator)
	local pool = signalTable.GetPool();
	if(pool) then
	    caller:AddListChildren(pool);
		--caller:AddListLuaItem("New","OnAddNew", OnAddNew);
		caller:SelectListItemByValue(caller.Value);
		caller:Changed();
	end
end
