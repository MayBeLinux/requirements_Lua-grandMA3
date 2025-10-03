local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function AdjustToEmbeddedLayout(o)
	o.w = "100%"
	o.h = "100%"
	local OverlRows = o:Ptr(1)
	local FrameRows = o.Frame:Ptr(1)
	OverlRows[2].SizePolicy = "Stretch"
	FrameRows[2].SizePolicy = "Stretch"
	o.Frame.VirtualKeyboard.H="100%"
end

signalTable.TextInputLoaded = function(caller,status,creator)
	local addArgs = caller.AdditionalArgs;
	if ((addArgs ~= nil) and (addArgs.Filter ~= nil)) then caller.Frame.InputField.Filter = addArgs.Filter; end;
	local VKforced = true;
	local ClearVis = true;
	local Embedded = false;
	if ((addArgs ~= nil) and (addArgs.VKForced ~= nil)) then VKforced = addArgs.VKForced; end;
	if ((addArgs ~= nil) and (addArgs.ShowClear ~= nil)) then ClearVis=(addArgs.ShowClear == "1"); end;
	if ((addArgs ~= nil) and (addArgs.Embedded ~= nil)) then Embedded = (addArgs.Embedded == "Yes"); end;
	caller.Frame.VirtualKeyboard.Clear.Visible = ClearVis;

	if Embedded then
		AdjustToEmbeddedLayout(caller)
	end

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
	
	if (VKforced == nil) then
		local currentProfile = CurrentProfile();
		if (currentProfile) then
			caller.Frame.VirtualKeyboard.Visible=currentProfile.VKExpanded;
		end
	else
		caller.Frame.VirtualKeyboard.Visible = VKforced;
		caller.TitleBar.VK.Visible = false;
		caller.TitleBar.Title.Texture = Root().GraphicsRoot.TextureCollect.Textures["corner1"];
	end
	
	local shiftPleaseDown = nil;
	local f = caller.Frame.InputField.Filter;
	local periodVisible = false;
	local commaOrSlashVisible = false;
	if (f:find("%.") ~= nil) then 
		caller.Frame.VirtualKeyboard.Period.Visible = true; 
		periodVisible = true;
		shiftPleaseDown = true;
	end
	if (f:find(",") ~= nil) then
		caller.Frame.VirtualKeyboard.Comma.Visible = true; 
		commaOrSlashVisible = true;
		shiftPleaseDown = true;
	elseif (f:find("/") ~= nil) then
		caller.Frame.VirtualKeyboard.Slash.Visible = true; 
		commaOrSlashVisible = true;
		shiftPleaseDown = true;
	end
	if (ClearVis == true) then
		shiftPleaseDown = true;
	end

	if (shiftPleaseDown == true) then
		caller.Frame.VirtualKeyboard.Please.Anchors = {left=1,top=5,right=2,bottom=5};
		caller.Frame.VirtualKeyboard.Please.Texture = Root().GraphicsRoot.TextureCollect.Textures["corner12"];
		caller.Frame.VirtualKeyboard.Please.H = 50;

		if (not periodVisible) then
			caller.Frame.VirtualKeyboard.Clear.Anchors = caller.Frame.VirtualKeyboard.Period.Anchors;
			caller.Frame.VirtualKeyboard.Clear.Texture = caller.Frame.VirtualKeyboard.Period.Texture;
		elseif (not commaOrSlashVisible) then
			caller.Frame.VirtualKeyboard.Clear.Anchors = caller.Frame.VirtualKeyboard.Comma.Anchors;
			caller.Frame.VirtualKeyboard.Clear.Texture = caller.Frame.VirtualKeyboard.Comma.Texture;
		else
			caller.Frame.VirtualKeyboard.Clear.Anchors = {left=0,top=5,right=0,bottom=5};
			caller.Frame.VirtualKeyboard.Clear.Texture = Root().GraphicsRoot.TextureCollect.Textures["corner4"];
			caller.Frame.VirtualKeyboard.Clear.H = 50;
		end
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