local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function Main(display_handle)
    local plugin          = my_handle:Parent();
	local display_collect = Root().GraphicsRoot.DisplayCollect;
	local display_count   = display_collect:Count();
    for i = 1, display_count do
        local display = display_collect[i];
        if display then
		    plugin[2]:CommandCall(display);
		end
	end
end

signalTable.OnKeyDown = function(caller,signalvalue,keycode)

        if(HostOS()=="Mac") then
		if(keycode==297) then -- F8
			Main(); -- desklock uixml is set to toggle, so it will close everything
		end
	else
		if(keycode==284) then -- Pause key
			Main(); -- desklock uixml is set to toggle, so it will close everything
		end
	end
end

return Main;
