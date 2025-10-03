local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.OnKeyDown = function(caller,signalvalue,keycode)
    if(keycode==298) then -- F9
		caller:GetOverlay().Close();
	else
		if(keycode==284) then -- Pause key
			caller:GetOverlay().Close();
		end	
	end
end

local click_pattern = { 1 , 4, 2, 3 };
local click_history=  { 0 , 0, 0, 0 };
local click_history_index = 0;

signalTable.DeskLockClick = function(caller,signalvalue)
	click_history[click_history_index+1]=tonumber(signalvalue);
	click_history_index=(click_history_index+1)%4;
	-- Echo("Click History Index = %d",click_history_index);
	local equal=true;
	for j=0,3 do
	   local i=(j+click_history_index)%4;
	   -- Echo("Click History [%d] : %d",i,click_history[i+1]);
	   equal = equal and (click_pattern[j+1]==click_history[i+1]);
	end
	if(equal) then
		caller:GetOverlay().Close();
	end
end