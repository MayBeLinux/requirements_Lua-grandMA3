local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- ******************************************************************************************
--
-- ******************************************************************************************

function SetFilterSettingsTarget(target, ui)
	local container=ui;
	ui.TargetObject = target
end
