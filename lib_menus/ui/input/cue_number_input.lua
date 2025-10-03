local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.ToggleVirtualKeyboard = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local newVisible = not overlay.Frame.VirtualKeyboard.Visible;
		overlay.Frame.VirtualKeyboard.Visible=newVisible;--not overlay.Frame.VirtualKeyboard.Visible;
		local currentProfile = CurrentProfile();
		if (currentProfile) then
			currentProfile.VKExpanded=overlay.Frame.VirtualKeyboard.Visible;
		end
	end
end



