local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	local keyboards = Root().KeyboardLayouts;
	if (keyboards) then
		caller:InputSetEditTitle("keyboard");
		caller:AddListChildren(keyboards);
	end
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
