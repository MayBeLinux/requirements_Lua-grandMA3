local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.TextInputLoaded = function(caller,status,creator)
	local languageButton = caller.Frame.VirtualKeyboard.Language;
	if (languageButton) then
		local currentUser = CurrentUser();
		if (currentUser) then
			local currentKeyboard = currentUser.Keyboard;
			if (currentKeyboard) then
				languageButton.Text = currentKeyboard.Name;
			end
		end
	end
	
	local currentProfile = CurrentProfile();
	if (currentProfile) then
		caller.Frame.VirtualKeyboard.Visible=currentProfile.VKExpanded;
	end
end

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

return Main;