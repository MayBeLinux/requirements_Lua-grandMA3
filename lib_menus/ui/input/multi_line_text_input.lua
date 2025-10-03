local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

function StringToCapitalFirstLetter(str)
	str = string.lower(str);
	local firstLetter = string.sub(str, 1, 1);
	local rest = string.sub(str, 2);
	return string.upper(firstLetter) .. rest;
end

signalTable.MultiLineTextInputLoaded = function(caller,status,creator)
	-- Virtual Keyboard placeholder
	signalTable.RebuildPlaceholder(caller.Frame.VirtualKeyboardPlaceholder, "VirtualKeyboardContent");
	caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.TargetObject = caller.Frame.InputField;
	caller.Frame.VirtualKeyboardPlaceholder:Changed();

	local languageButton = caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.Language;
	if (languageButton) then
		local currentUser = CmdObj().User;	
		if (currentUser) then
			caller.Frame.VirtualKeyboardPlaceholder.Visible=currentUser.VKExpanded;
			local currentKeyboard = currentUser.Keyboard;
			if (currentKeyboard) then
				languageButton.Text = currentKeyboard.Name;
			end
		end
	end			

	local undoBtn = caller.TitleBar.Undo;
	local redoBtn = caller.TitleBar.Redo;

	if (undoBtn) then
		undoBtn.ToolTip = "Undo last change (0 available)";
	end

	if (redoBtn) then
		redoBtn.ToolTip = "Redo last undo (0 available)";
	end

	local currentProfile = CurrentProfile();
	if (currentProfile) then
		caller.Frame.VirtualKeyboardPlaceholder.Visible=currentProfile.VKExpanded;
		signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);	
	end

	local targetInfo = caller.Context:Get("Name",Enums.Roles.Display);

	-- "Note Cue" returns Cue as target name instead of Part, except if part specified
	local object = caller.Target;
	local prop = StringToCapitalFirstLetter(caller.StrContext);
	if (IsObjectValid(object)) then
		local cueObj = nil;
		local partObj = nil;
		if (object:IsClass("Part") ) then
			cueObj = object:Parent();
			partObj = object;
		elseif (object:IsClass("Cue")) then
			cueObj = object;
			partObj = object:Ptr(1);
		end

		if (cueObj and partObj) then
			-- Naming scheme "Cue 1 : Part 1" or with custom labels "Cue 1 'MyCue' : Part 1 'MyPart'"
			local cueNameFromObject = cueObj.Name;
			local partNameFromObject = partObj.Name;
			local cueNameFromIndex = "Cue " .. cueObj.index;
			local partNameFromIndex = "Part " .. partObj.index;

			if (cueNameFromObject == "CueZero" or cueNameFromObject == "OffCue") then
				caller.TitleBar.Title.Text = prop .. " " .. cueNameFromObject;
			elseif (partObj.Part == 0) then -- Selection is cue
				if (cueNameFromObject == cueNameFromIndex) then
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex;
				else
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "'";
				end
			else
				if (cueNameFromObject == cueNameFromIndex and partNameFromObject == partNameFromIndex) then
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex .. " : " .. partNameFromIndex;
				elseif (cueNameFromObject == cueNameFromIndex and partNameFromObject ~= partNameFromIndex) then
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex .. " : " .. partNameFromIndex .. " '" .. partNameFromObject .. "'";
				elseif (cueNameFromObject ~= cueNameFromIndex and partNameFromObject == partNameFromIndex) then
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex;
				else
					caller.TitleBar.Title.Text =  prop .. " " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex .. " '" .. partNameFromObject .. "'";
				end
			end
		elseif (object:IsClass("ShowMetaData")) then -- Exception for show description
			caller.TitleBar.Title.Text = "Show Description";
		else
			caller.TitleBar.Title.Text = prop .. " " .. targetInfo;
		end
	else
		caller.TitleBar.Title.Text = prop .. " " .. targetInfo;
	end

	local disp = caller:GetDisplay();
	-- Width
	if (disp.AbsRect.w > 1920) then
		caller.W = 1200;
	elseif (disp.AbsRect.w > 1440) then
		caller.W = 1000;
	else
		caller.W = math.ceil(disp.AbsRect.w * 0.6);
	end

	-- Height
	if (disp.AbsRect.h > 1080) then
		caller.H = 800;
	elseif (disp.AbsRect.h > 720) then
		caller.H = 600;
	else
		caller.H = math.ceil(disp.AbsRect.h * 0.6);
	end

	-- Small displays
	if (disp.AbsRect.w <= 800 and disp.AbsRect.h <= 480 ) then
		caller.W = disp.AbsRect.w;
		caller.H = disp.AbsRect.h;
	end

	-- after all adjustments, make it visible:
	caller.Visible = true;
	FindBestFocus(caller.Frame.InputField);
end

signalTable.UndoRedoChanged = function(caller,dummy,undosCount,redosCount)
	local overlay = caller:GetOverlay();

	local undoBtn = overlay.TitleBar.Undo;
	local redoBtn = overlay.TitleBar.Redo;

	if (undoBtn) then
		if (undosCount > 0) then
			undoBtn.State = true;
		else
			undoBtn.State = false;
		end
		undoBtn.ToolTip = "Undo last change ("..undosCount.." available)";
	end

	if (redoBtn) then
		if (redosCount > 0) then
			redoBtn.State = true;
		else
			redoBtn.State = false;
		end
		redoBtn.ToolTip = "Redo last undo ("..redosCount.." available)";
	end
end

signalTable.ToggleVirtualKeyboard = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local currentProfile = CurrentProfile();

		if (status == "" or status == nil) then
			newStatus = not overlay.Frame.VirtualKeyboardPlaceholder.Visible;
		else
			newStatus = status;
		end

		overlay.Frame.VirtualKeyboardPlaceholder.Visible = newStatus;
		overlay.Frame.VirtualKeyboardPlaceholder:Ptr(1):Changed()

		local currentProfile = CurrentProfile();
		if (currentProfile) then
			currentProfile.VKExpanded=newStatus;
		end
		
		-- Icon color
		if (overlay.Frame.VirtualKeyboardPlaceholder.Visible == true) then
			overlay.TitleBar.VK.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
		else
			overlay.TitleBar.VK.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
		end
		
	end
end
