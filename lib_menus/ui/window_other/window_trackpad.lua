local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local SettingsObj;

local function OnSettingsChanged(settings, dummy, ctx)
    
	if (ctx) then 		

		local isPanTilt = settings.TrackpadMode == "Pan/Tilt";
	
		if (isPanTilt) then
		    ctx.Title.TitleButtons.ResolutionPT.Visible = "Yes"
			ctx.Title.TitleButtons.PanTiltInvertBtn.Visible = "Yes"
			ctx.Title.TitleButtons.PanTiltModeBtn.Visible = "Yes"
			ctx.Title.TitleButtons.TapForClickBtn.Visible = "No"
			ctx.Title.TitleButtons.ResetVirtualMouseBtn.Visible = "No"
			ctx.Title.TitleButtons.Resolution.Visible = "No"
		else 
			ctx.Title.TitleButtons.PanTiltInvertBtn.Visible = "No"
			ctx.Title.TitleButtons.PanTiltModeBtn.Visible = "No"
			ctx.Title.TitleButtons.ResolutionPT.Visible = "No"
			ctx.Title.TitleButtons.TapForClickBtn.Visible = "Yes"
			ctx.Title.TitleButtons.ResetVirtualMouseBtn.Visible = "Yes"
			ctx.Title.TitleButtons.Resolution.Visible = "Yes"
		end
	end
end

-- ------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	SettingsObj = window.WindowSettings;
	HookObjectChange(OnSettingsChanged, SettingsObj, my_handle:Parent(), window);
	OnSettingsChanged(SettingsObj, nil, window);
end

-- ------------------------------------------
signalTable.SetTarget = function(caller)
	caller.Target=SettingsObj
end

