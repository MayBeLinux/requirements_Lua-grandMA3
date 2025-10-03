local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function Main(display_handle)
	local plugin     =my_handle:Parent();
	plugin[2]:CommandCall(display_handle);
	signalTable.CreateEncoderBar(display_handle);
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.CreateEncoderBar = function(display_handle)
	local plugin     =my_handle:Parent();
    local plugin_pool=plugin:Parent();
	local isConsole = HostType() == "Console";
	local subType = HostSubType();
	local isLightOrFull = (subType == "FullSizeCRV") or (subType == "FullSize") or (subType == "Light") or (subType == "LightCRV");
	display_handle.EncoderBarContainer.EncoderBarGrid.EncoderBarBase.Visible = true; -- copy from console_ui.lua
	plugin[3]:CommandCall(display_handle);
	local Bars	= {"PresetBar", "ExecutorBar", "ExecutorBarXKeys"};
	local Index	= 1;

    if(display_handle:Index()==8) then
		if (isConsole and isLightOrFull) then
			Index = 1;--always preset bar. according to testers it makes no sense on these types
		else
			Index = (tonumber(CurrentProfile().ShowUserEncoder) or 0) + 1; -- +1 for lua tables starts with 1 instead of 0
		end
    else
		Index = 2;
    end

	display_handle.EditEncoderBar = Bars[Index];
	plugin_pool[Bars[Index]]:CommandCall(display_handle);

end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.DisplayLoaded = function(display)
	signalTable.BarLoaded(display.EncoderBarContainer.EncoderBarGrid.EncoderBarBase)	
end

return Main;
