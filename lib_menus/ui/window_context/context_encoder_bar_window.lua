local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.EncoderBarWindowLoaded = function(caller)    
    local frame = caller.Frame;
    local display = frame.Container.Display;
	local settings = display.EncoderToggle.Target;
	if (settings) then

				HookObjectChange(signalTable.GreyOutShowEncoderLabel,  -- 1. function to call
				settings,							-- 2. object to hook
				my_handle:Parent(),				-- 3. plugin object ( internally needed )
				caller);							-- 4. user callback parameter 	
				signalTable.GreyOutShowEncoderLabel(settings, nil, caller);
	end
end 

signalTable.GreyOutShowEncoderLabel = function(settings, dummy, caller)

	local display = caller.Frame.Container.Display;
	if(settings.FadeEncoder) then
		display.EncoderLabel.Enabled = true;
	else
		display.EncoderLabel.Enabled = false;
	end
end

