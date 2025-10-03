local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnResetToDefaultsLoad = function(caller,status,creator)
	caller.Enabled = Patch():Index() == 9 --Edit Patch
end