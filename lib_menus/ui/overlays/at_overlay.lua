local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.MaskLoaded = function(caller,status,creator)
	local cmdline=CmdObj();
	local max_step=cmdline.MaxStep;
	for i,c in ipairs(caller:UIChildren()) do
		c.Enabled=(i<=max_step);
	end
end

signalTable.ClickedClear = function()
	Echo("Would be nice if At overlays could close automatically");
end

