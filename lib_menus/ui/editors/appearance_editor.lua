local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	-- Appearance Edit Placeholder
	signalTable.RebuildPlaceholder(caller.Frame.AppearanceEditPlaceholder, "AppearanceEditContent");
	caller:Changed();
end

