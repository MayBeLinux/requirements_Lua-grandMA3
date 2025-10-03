local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local function CreateNewKey(caller, arg)
	local KeyRegistry=Root().KeyRegistry;
	local result =KeyRegistry:Append(); 
	return caller, result;
end

signalTable.OnLoaded = function(caller,status,creator)
	caller:AddListLuaItem("New key", "CreateNewKey", CreateNewKey);
    caller:AddListChildren(Root().KeyRegistry);
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
