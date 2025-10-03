local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	local keyboards = Root().KeyboardLayouts;
	if (keyboards) then
		Echo("UserLanguagePopupLoaded");
		for _,keyboard in ipairs(keyboards:Children()) do
			caller:AddListStringItem(keyboard.ShortName, keyboard.ShortName);
		end
	end
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
