local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function Main(display_handle)
end

local function isSmallScreen(caller)
	local disp = caller:GetDisplay();
	if (disp.AbsRect.w <= 800 and disp.AbsRect.h <= 600) then
		return true;
	else
		return false;
	end
end

signalTable.ShowWarning = function(caller,status,creator)
	local overlay = caller:GetOverlay();
	overlay.TitleBar.WarningButton.ShowAnimation(status);
end

signalTable.OnLoaded = function(caller,status,creator)
	-- Overwritten by label_editor.lua
	signalTable.TextInputLoaded(caller, status, creator);
end

signalTable.OnLoadedTitle = function(caller,status,creator)
	if caller.Text == "WebView" then
	   caller.Text = "Keyboard";
	   local overlay = caller:GetOverlay();
	   overlay.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.Language.Enabled = false;
	end
end

signalTable.TextInputLoaded = function(caller,status,creator)
	-- Load the content
	signalTable.LoadPlaceholderComponents(caller);

	-- Size and position
	local disp = caller:GetDisplay();
	if (isSmallScreen(caller) == true) then
		caller.W = disp.AbsRect.w;
		caller.H = disp.AbsRect.h;
	else
		if (disp.AbsRect.w >= 1920) then
			caller.W = 1000;
		else
			caller.W = math.ceil(disp.AbsRect.w * 0.6);
		end
	end

	-- Small screens: Default to name/note/keyboard
	if (isSmallScreen(caller)) then
		signalTable.PostInitSmallScreens(caller);
	end

	-- After all adjustments, make it visible:
	caller.Visible = true;

	if (caller.Frame.NameNoteEdit and caller.IsMainBuddy) then
		FindBestFocus(caller.Frame.NameNoteEdit.InputField);
	end
end

signalTable.LoadPlaceholderComponents = function(caller)
	-- By default, only name/note and string
	signalTable.InitNameNote(caller);
	signalTable.InitVirtualKeyboard(caller);
end

signalTable.InitNameNote = function(caller)
	-- Vars
	local currentProfile = CurrentProfile();
	local addArgs = caller.AdditionalArgs;
	local NEforced = nil;

	if ((addArgs ~= nil) and (addArgs.Filter ~= nil)) then caller.Frame.NameNoteEdit.InputField.Filter = addArgs.Filter; end;

	-- Visibility
	if ((addArgs ~= nil) and (addArgs.NEForced ~= nil)) then NEforced = addArgs.NEForced; end;
	if (NEforced == nil) then
		if (currentProfile and caller.Frame.NameNoteEdit) then
			if (caller.IsNoteAvailable) then
				caller.Frame.NameNoteEdit.NFBtn.Visible = true;
				caller.Frame.NameNoteEdit.NoteField.Visible = true;
			else
				-- Visually remove the note, and revert the inputfield to the full width
				caller.Frame.NameNoteEdit.NFBtn.Visible = false;
				caller.Frame.NameNoteEdit.NoteField.Visible = false;

				caller.Frame.NameNoteEdit.IFBtn.Visible = false;
				caller.Frame.NameNoteEdit.InputField.Texture = "corner15";
			end
		end
	else
		if caller.Frame.NameNoteEdit then
			caller.Frame.NameNoteEdit.NFBtn.Visible = NEforced;
			caller.Frame.NameNoteEdit.NoteField.Visible = NEforced;
		end;
	end

	-- Object locked?
	if (caller.Target ~= nil and caller.Target.Lock == "Yes") then
		caller.Frame.NameNoteEdit.Enabled = false;
	end
end

signalTable.InitVirtualKeyboard = function(caller)
	-- Vars
	local currentProfile = CurrentProfile();
	local addArgs = caller.AdditionalArgs;
	local VKforced = nil;

	-- Placeholder
	caller.Frame.VirtualKeyboardPlaceholder.Visible = true;
	signalTable.RebuildPlaceholder(caller.Frame.VirtualKeyboardPlaceholder, "VirtualKeyboardContent");
	caller.Frame.VirtualKeyboardPlaceholder:Changed();
	caller.Frame.VirtualKeyboardPlaceholder:WaitInit(1);

	-- Language button
	local languageButton = caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.Language;
	if (languageButton) then
		local currentUser = CurrentUser();
		if (currentUser) then
			local currentKeyboard = currentUser.Keyboard;
			if (currentKeyboard) then
				languageButton.Text = currentKeyboard.Name;
			end
		end
	end

	-- Visibility
	if ((addArgs ~= nil) and (addArgs.VKForced ~= nil)) then VKforced = addArgs.VKForced; end;
	if (VKforced == nil) then
		if (currentProfile) then
			signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
		end
		caller.TitleBar.VK.Visible = true;
	else
		caller.Frame.VirtualKeyboardPlaceholder.Visible = VKforced;
		caller.TitleBar.Title.Texture = Root().GraphicsRoot.TextureCollect.Textures["corner1"];
	end

	-- Object locked?
	if (caller.Target ~= nil and caller.Target.Lock == "Yes") then
		caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.Enabled = false;
	end
end

signalTable.InitScribbleEditor = function(caller)
	if (caller.IsScribbleAvailable) then
		-- Vars
		local currentProfile = CurrentProfile();
		local addArgs = caller.AdditionalArgs;
		local SCforced = nil;

		-- Placeholder
		caller.Frame.ScribbleEditPlaceholder.Visible = true;
		signalTable.RebuildPlaceholder(caller.Frame.ScribbleEditPlaceholder, "ScribbleEditContent");
		caller.Frame.ScribbleEditPlaceholder:Changed();
		caller.Frame.ScribbleEditPlaceholder:WaitInit(1);
		caller.Frame.ScribbleEditPlaceholder.ScribbleEditContent.ScribbleTarget = caller.Target;

		-- Titlebar menus visibility
		caller.TitleBar.SE.Visible = true;
		caller.TitleBar.Scribble.Target = caller.Target;
		-- Only show the scribble assignment if the target is NOT a scribble
		caller.TitleBar.Scribble.Visible = caller.Target:GetClass() ~= "Scribble";

		-- Visibility
		if (currentProfile) then
			signalTable.ToggleScribbleEditor(caller, currentProfile.TextInputAuxEditor == "Scribble");
		end

		-- Object locked?
		if (caller.Target ~= nil and caller.Target.Lock == "Yes") then
			caller.Frame.ScribbleEditPlaceholder.Enabled = false;
		end
	else
		-- Hide menus and scribble placeholder
		if (caller.TitleBar.SE) then caller.TitleBar.SE.Visible = false; end;
		if (caller.TitleBar.Scribble) then caller.TitleBar.Scribble.Visible = false; end;
		if (caller.Frame.ScribbleEditPlaceholder) then caller.Frame.ScribbleEditPlaceholder.Visible = false; end;
	end
end

signalTable.InitAppearanceEditor = function(caller)
	if (caller.IsAppearanceAvailable) then
		-- Vars
		local currentProfile = CurrentProfile();

		-- Placeholder
		caller.Frame.AppearanceEditPlaceholder.Visible = true;
		signalTable.RebuildPlaceholder(caller.Frame.AppearanceEditPlaceholder, "AppearanceEditContent");
		caller.Frame.AppearanceEditPlaceholder:Changed();
		caller.Frame.AppearanceEditPlaceholder:WaitInit(1);
		caller.Frame.AppearanceEditPlaceholder.AppearanceEditContent.AppearanceTarget = caller.Target;

		-- Titlebar menus visibility
		caller.TitleBar.AE.Visible = true;
		caller.TitleBar.Appearance.Target = caller.Target;
		-- Only show the appearance assignment if the target is NOT an appearance
		caller.TitleBar.Appearance.Visible = caller.Target:GetClass() ~= "Appearance";

		-- Visibility
		if (currentProfile) then
			signalTable.ToggleAppearanceEditor(caller, currentProfile.TextInputAuxEditor == "Appearance");
		end

		-- Object locked?
		if (caller.Target ~= nil and caller.Target.Lock == "Yes") then
			caller.Frame.AppearanceEditPlaceholder.Enabled = false;
		end
	else
		-- Hide menus and appearance placeholder
		if (caller.TitleBar.AE) then caller.TitleBar.AE.Visible = false; end;
		if (caller.TitleBar.Appearance) then caller.TitleBar.Appearance.Visible = false; end;
		if (caller.Frame.AppearanceEditPlaceholder) then caller.Frame.AppearanceEditPlaceholder.Visible = false; end;
	end
end

signalTable.InitTagsEditor = function(caller)
	-- Vars
	local currentProfile = CurrentProfile();

	-- Placeholder
	caller.Frame.TagsEditPlaceholder.Visible = true;
	signalTable.RebuildPlaceholder(caller.Frame.TagsEditPlaceholder, "TagsEditContent");
	caller.Frame.TagsEditPlaceholder:Changed();
	caller.Frame.TagsEditPlaceholder:WaitInit(1);

	local fakeCollect = CmdObj().TagFakeCollect;
	caller.Frame.TagsEditPlaceholder.TagsEditContent.Target = fakeCollect;

	-- Titlebar menus visibility
	caller.TitleBar.TE.Visible = true;

	-- Visibility
	if (currentProfile) then
		signalTable.ToggleTagsEditor(caller, currentProfile.TextInputAuxEditor == "Tags");
	end

	-- Object locked?
	if (caller.Target ~= nil and caller.Target.Lock == "Yes") then
		caller.Frame.TagsEditPlaceholder.Enabled = false;
	end
end

signalTable.ToggleNameNoteEdit = function(caller, status)
	local overlay = caller:GetOverlay();
	if (overlay and overlay.Frame.NameNoteEdit) then
		if (isSmallScreen(caller)) then
		-- Even if small screen overlay.Frame.NameNoteEdit has to be visible because of
		-- focus purpose (look at Bug #31308).
		-- To achieve "Invisibility" the height of the first row is reduced to 0
		-- and only the second row is made invisible.
			if (status == "" or status == nil) then
				status = not overlay.Frame.NameNoteEdit.NoteField.Visible;
			end

			overlay.Frame.NameNoteEdit.NoteField.Visible = status;
			overlay.Frame.NameNoteEdit.NFBtn.Visible = status;
			if status then
			   overlay.Frame.NameNoteEdit.IFBtn.H = 40;
			   overlay.Frame.NameNoteEdit.InputField.H = 40;
			else
			   overlay.Frame.NameNoteEdit.IFBtn.H = 0;
			   overlay.Frame.NameNoteEdit.InputField.H = 0;
			end
		end

		overlay.Frame.NameNoteEdit.Visible = true;
		overlay.Frame.NameNoteEdit:Changed();
	end
end

signalTable.ToggleVirtualKeyboard = function(caller, status)
	local overlay = caller:GetOverlay();
	local newStatus = nil;
	if (overlay) then
		local currentProfile = CurrentProfile();

		if (status == "" or status == nil) then
			newStatus = not overlay.Frame.VirtualKeyboardPlaceholder.Visible;
		else
			newStatus = status;
		end

		overlay.Frame.VirtualKeyboardPlaceholder.Visible = newStatus;
		overlay.Frame.VirtualKeyboardPlaceholder:Ptr(1):Changed()

		-- Small screen: Disable other editors. Only if called from the titlebar
		if (status == "" or status == nil) then
			if (isSmallScreen(caller)) then
				if (newStatus == true) then
					signalTable.ToggleNameNoteEdit(caller, true);
					signalTable.ToggleScribbleEditor(caller, false);
					signalTable.ToggleAppearanceEditor(caller, false);
					signalTable.ToggleTagsEditor(caller, false);
				end
			elseif (currentProfile) then
				signalTable.ToggleNameNoteEdit(caller, true);
			end

			if (currentProfile) then
				currentProfile.VKExpanded = newStatus;
				-- Force small screen tab to name/note if we toggle the keyboard on
				if (newStatus == true) then
					currentProfile.TextInputSmallScreenTab = "NameNote";
				end
			end
		end

		-- Icon color
		if (overlay.Frame.VirtualKeyboardPlaceholder.Visible == true) then
			overlay.TitleBar.VK.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
		else
			overlay.TitleBar.VK.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
		end
	end
end

signalTable.ToggleScribbleEditor = function(caller, status)
	local overlay = caller:GetOverlay();
	local newStatus = nil;
	if (overlay) then
		if (overlay.IsScribbleAvailable and overlay.Frame.ScribbleEditPlaceholder and overlay.Frame.ScribbleEditPlaceholder:Count() > 0) then
			local currentProfile = CurrentProfile();

			if (status == "" or status == nil) then
				newStatus = not overlay.Frame.ScribbleEditPlaceholder.Visible;
			else
				newStatus = status;
			end

			-- If we're disabling this tab, set small screens to name/note.
			if (status == "" and newStatus == false) then
				signalTable.SetDefaultSmallScreenTab(caller);
			else
				overlay.Frame.ScribbleEditPlaceholder.Visible = newStatus;
				overlay.Frame.ScribbleEditPlaceholder:Ptr(1):Changed()
			end

			-- Small screen: Disable other editors. Only if it's called from the titlebar
			if (status == "" or status == nil) then
				if (isSmallScreen(overlay) == true) then
					if (newStatus == true) then
						signalTable.ToggleNameNoteEdit(caller, false);
						signalTable.ToggleVirtualKeyboard(caller, false);
						signalTable.ToggleAppearanceEditor(caller, false);
						signalTable.ToggleTagsEditor(caller, false);
					end
				elseif (currentProfile) then
					signalTable.ToggleNameNoteEdit(caller, true);
					signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
					signalTable.ToggleAppearanceEditor(caller, false);
					signalTable.ToggleTagsEditor(caller, false);
				end

				if (currentProfile and newStatus == true) then
					currentProfile.TextInputAuxEditor = "Scribble";
					currentProfile.TextInputSmallScreenTab = "Scribble";
				elseif (currentProfile) then
					currentProfile.TextInputAuxEditor = "None";
				end
			end

			-- Icon color
			if (newStatus == true) then
				overlay.TitleBar.SE.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
			else
				overlay.TitleBar.SE.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
			end

		end
	end
end

signalTable.ToggleAppearanceEditor = function(caller,status)
	local overlay = caller:GetOverlay();
	local newStatus = nil;
	if (overlay) then
		if (overlay.IsAppearanceAvailable and overlay.Frame.AppearanceEditPlaceholder and overlay.Frame.AppearanceEditPlaceholder:Count() > 0) then
			local currentProfile = CurrentProfile();

			if (status == "" or status == nil) then
				newStatus = not overlay.Frame.AppearanceEditPlaceholder.Visible;
			else
				newStatus = status;
			end

			-- If we're disabling this tab, set small screens to name/note.
			if (status == "" and newStatus == false) then
				signalTable.SetDefaultSmallScreenTab(caller);
			else
				overlay.Frame.AppearanceEditPlaceholder.Visible = newStatus;
				overlay.Frame.AppearanceEditPlaceholder:Ptr(1):Changed()
			end

			-- Small screen: Disable other editors. Only if it's called from the titlebar
			if (status == "" or status == nil) then
				if (isSmallScreen(overlay) == true) then
					if (newStatus == true) then
						signalTable.ToggleNameNoteEdit(caller, false);
						signalTable.ToggleVirtualKeyboard(caller, false);
						signalTable.ToggleScribbleEditor(caller, false);
						signalTable.ToggleTagsEditor(caller, false);
					end
				elseif (currentProfile) then
					signalTable.ToggleNameNoteEdit(caller, true);
					signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
					signalTable.ToggleScribbleEditor(caller, false);
					signalTable.ToggleTagsEditor(caller, false);
				end


				if (currentProfile and newStatus == true) then
					currentProfile.TextInputAuxEditor = "Appearance";
					currentProfile.TextInputSmallScreenTab = "Appearance";
				elseif (currentProfile) then
					currentProfile.TextInputAuxEditor = "None";
				end
			end

			-- Icon color
			if (newStatus == true) then
				overlay.TitleBar.AE.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
			else
				overlay.TitleBar.AE.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
			end

		end
	end
end

signalTable.ToggleTagsEditor = function(caller,status)
	local overlay = caller:GetOverlay();
	local newStatus = nil;
	if (overlay) then
		if (overlay.Frame.TagsEditPlaceholder and overlay.Frame.TagsEditPlaceholder:Count() > 0) then
			local currentProfile = CurrentProfile();

			if (status == "" or status == nil) then
				newStatus = not overlay.Frame.TagsEditPlaceholder.Visible;
			else
				newStatus = status;
			end

			-- If we're disabling this tab, set small screens to name/note.
			if (status == "" and newStatus == false) then
				signalTable.SetDefaultSmallScreenTab(caller);
			else
				overlay.Frame.TagsEditPlaceholder.Visible = newStatus;
				overlay.Frame.TagsEditPlaceholder:Ptr(1):Changed()
			end

			-- Small screen: Disable other editors. Only if it's called from the titlebar
			if (status == "" or status == nil) then
				if (isSmallScreen(overlay) == true) then
					if (newStatus == true) then
						signalTable.ToggleNameNoteEdit(caller, false);
						signalTable.ToggleVirtualKeyboard(caller, false);
						signalTable.ToggleScribbleEditor(caller, false);
						signalTable.ToggleAppearanceEditor(caller, false);
					end
				elseif (currentProfile) then
					signalTable.ToggleNameNoteEdit(caller, true);
					signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
					signalTable.ToggleScribbleEditor(caller, false);
					signalTable.ToggleAppearanceEditor(caller, false);
				end


				if (currentProfile and newStatus == true) then
					currentProfile.TextInputAuxEditor = "Tags";
					currentProfile.TextInputSmallScreenTab = "Tags";
				elseif (currentProfile) then
					currentProfile.TextInputAuxEditor = "None";
				end
			end

			-- Icon color
			if (newStatus == true) then
				overlay.TitleBar.TE.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
			else
				overlay.TitleBar.TE.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
			end

		end
	end
end

signalTable.PostInitSmallScreens = function(caller, status)
	local currentProfile = CurrentProfile();
	if (currentProfile) then
		if (currentProfile.TextInputSmallScreenTab == "Scribble" and not caller.IsScribbleAvailable) then
			currentProfile.TextInputSmallScreenTab = "NameNote";
		elseif (currentProfile.TextInputSmallScreenTab == "Appearance" and not caller.IsAppearanceAvailable) then
			currentProfile.TextInputSmallScreenTab = "NameNote";
		elseif (caller.IsScribbleAvailable or caller.IsAppearanceAvailable) then
			currentProfile.TextInputSmallScreenTab = currentProfile.TextInputAuxEditor;
		end

		if (currentProfile.TextInputSmallScreenTab ~= "None") then
			signalTable.OnUserProfileChanged(caller);
		end
	end
end

signalTable.OnFocusInputField = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		overlay.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.TargetObject = overlay.Frame.NameNoteEdit.InputField;
		FindBestFocus(overlay.Frame.NameNoteEdit.InputField);
	end
end


signalTable.OnFocusNoteField = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		overlay.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.TargetObject = overlay.Frame.NameNoteEdit.NoteField;
		FindBestFocus(overlay.Frame.NameNoteEdit.NoteField);
	end
end

signalTable.OnMouseHoldDown = function(caller, status)
	-- Nothing
end

signalTable.OnScribbleTargetChanged = function(caller, status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		-- Is new scribble? Then change to this tab
		if (overlay.IsScribbleNew) then
			local currentProfile = CurrentProfile();

			signalTable.ToggleScribbleEditor(overlay, true);
			signalTable.ToggleAppearanceEditor(overlay, false);
			signalTable.ToggleTagsEditor(overlay, false);

			if (isSmallScreen(overlay) == true) then
				signalTable.ToggleNameNoteEdit(overlay, false);
				signalTable.ToggleVirtualKeyboard(overlay, false);
			end

			if (currentProfile) then
				currentProfile.TextInputAuxEditor = "Scribble";
				currentProfile.TextInputSmallScreenTab = "Scribble";
			end

			overlay.IsScribbleNew = false;
		end;


		if (overlay.Frame.ScribbleEditPlaceholder:Ptr(1)) then
			overlay.Frame.ScribbleEditPlaceholder:Ptr(1):Changed();
		end
	end
end

signalTable.OnAppearanceTargetChanged = function(caller, status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		-- Is new appearance? Then change to this tab
		if (overlay.IsAppearanceNew) then
			local currentProfile = CurrentProfile();

			signalTable.ToggleAppearanceEditor(overlay, true);
			signalTable.ToggleScribbleEditor(overlay, false);
			signalTable.ToggleTagsEditor(overlay, false);

			if (isSmallScreen(overlay) == true) then
				signalTable.ToggleNameNoteEdit(overlay, false);
				signalTable.ToggleVirtualKeyboard(overlay, false);
			end

			if (currentProfile) then
				currentProfile.TextInputAuxEditor = "Appearance";
				currentProfile.TextInputSmallScreenTab = "Appearance";
			end

			overlay.IsAppearanceNew = false;
		end;

		if (overlay.Frame.AppearanceEditPlaceholder:Ptr(1)) then
			overlay.Frame.AppearanceEditPlaceholder:Ptr(1):Changed();
		end
	end
end

signalTable.OnUserProfileChanged = function(caller)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local currentProfile = CurrentProfile();

		if (isSmallScreen(caller)) then
			signalTable.ToggleNameNoteEdit(caller, currentProfile.TextInputSmallScreenTab == "NameNote");
			signalTable.ToggleVirtualKeyboard(caller, currentProfile.TextInputSmallScreenTab == "NameNote" and currentProfile.VKExpanded);
			signalTable.ToggleScribbleEditor(caller, currentProfile.TextInputSmallScreenTab == "Scribble");
			signalTable.ToggleAppearanceEditor(caller, currentProfile.TextInputSmallScreenTab == "Appearance");
			signalTable.ToggleTagsEditor(caller, currentProfile.TextInputSmallScreenTab == "Tags");
		else
			signalTable.ToggleNameNoteEdit(caller, true);
			signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
			signalTable.ToggleScribbleEditor(caller, currentProfile.TextInputAuxEditor == "Scribble");
			signalTable.ToggleAppearanceEditor(caller, currentProfile.TextInputAuxEditor == "Appearance");
			signalTable.ToggleTagsEditor(caller, currentProfile.TextInputAuxEditor == "Tags");
		end
	end
end

signalTable.SetDefaultSmallScreenTab = function(caller)
	local currentProfile = CurrentProfile();
	currentProfile.TextInputSmallScreenTab = "NameNote";
	if (isSmallScreen(caller)) then
		signalTable.ToggleNameNoteEdit(caller, true);
		signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
		signalTable.ToggleScribbleEditor(caller, false);
		signalTable.ToggleAppearanceEditor(caller, false);
		signalTable.ToggleTagsEditor(caller, false);
	end
end

return Main;