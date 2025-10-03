-- ***************************************************************************************************
-- View3D Lua
-- ***************************************************************************************************

local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local settings;

signalTable.View3DLoaded = function(caller,status,creator)
	settings = caller.WindowSettings;
	caller.TitleBar.TitleButton.Settings = settings;
end

signalTable.SetTarget = function(caller)
	caller.Target=settings;
end

signalTable.SetTargetDev = function(caller)
	if (DevMode3d()=="No") then
		caller.Visible=0;
	else
		caller.Visible=1;
	end
end

signalTable.OnTitlebuttonLoaded = function(caller)
	local function OnSettingsChanged(settings, dummy, ctx)
		if (ctx) then
			if ctx.ShowSelectionCount ~= settings.ShowSelection then
				ctx.ShowSelectionCount = settings.ShowSelection;
			end
		end
	end

	local settings = caller:FindParent("Window").WindowSettings
	HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
	OnSettingsChanged(settings,nil,caller)
end