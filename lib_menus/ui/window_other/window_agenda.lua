local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

---------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	window:WaitInit();

	-- SETTINGS:
	local windowAgendaSettings = window.WindowSettings;
	window.TitleBar.Buttons.Setup.target = windowAgendaSettings;
	window.TitleBar.Buttons.ViewMode.target = windowAgendaSettings;
	window.TitleBar.Buttons.ColumnConfig.target = windowAgendaSettings;
	window.Content.Grid.Toolbar:SetChildren("Target",windowAgendaSettings);

	HookObjectChange(signalTable.OnSettingsChanged,		-- 1. function to call
					 windowAgendaSettings,				-- 2. object to hook
					 my_handle:Parent(),				-- 3. plugin object ( internally needed )
					 window);							-- 4. user callback parameter 	
	signalTable.OnSettingsChanged(windowAgendaSettings, Enums.ChangeLevel.Full, window);

	local dbObjectGrid = window.Content.Grid.Sheet.Content;
	dbObjectGrid.ExternalSettings = windowAgendaSettings;
end

---------------------------------------------
signalTable.OnSettingsChanged = function(settings, changeLevel, window)
	if (changeLevel >= Enums.ChangeLevel.Little) then
		return;
	end
	local settings = window.WindowSettings;
	local contents = window.Content.Grid:Children();

	local sheetViewModeActive = false;
	-- set content visibility
	window.TitleBar.Buttons.NavigateToday.visible = false; -- only visible if month or week
	window.TitleBar.Buttons.NavigatePrevious.visible = false; -- only visible if month or week
	window.TitleBar.Buttons.NavigateNext.visible = false; -- only visible if month or week
	for i=1,#contents do
		if contents[i]:GetClass() == "UILayoutGrid" then
			if (contents[i].name == settings.ViewMode) then
				contents[i]:Changed(); -- recalculate planned entries
				contents[i].visible = true;
				if settings.ViewMode == "Sheet" then
					sheetViewModeActive = true;
				end
			else
				contents[i].visible = false;
			end
		end
	end

	-- set titlebar visibility
	window.TitleBar.Buttons.NavigateToday.visible = not sheetViewModeActive;
	window.TitleBar.Buttons.NavigatePrevious.visible = not sheetViewModeActive;
	window.TitleBar.Buttons.NavigateNext.visible = not sheetViewModeActive;
	window.TitleBar.Buttons.DeleteOld.visible = settings.Setup;
	window.TitleBar.Buttons.ResetSelection.visible = settings.Setup and not sheetViewModeActive;

	-- set toolbar visibility
	window.Content.Grid.ToolBar.visible = settings.Setup and window.TitleBar.Buttons.Setup.visible;

	-- update title with current date:
	if settings.ViewMode == "Sheet" then
		window.TitleBar.TitleButton.Text = "Agenda";
	else
		window.TitleBar.TitleButton.Text = 'Agenda ('..settings.VisibleDate..')';
	end
end

---------------------------------------------
signalTable.JumpToToday = function(caller)
	local window = caller:FindParent("Window");
	window.WindowSettings:JumpToToday();
end
signalTable.JumpToPrevious = function(caller)
	local window = caller:FindParent("Window");
	window.WindowSettings:JumpToPrevious();
end
signalTable.JumpToNext = function(caller)
	local window = caller:FindParent("Window");
	window.WindowSettings:JumpToNext();
end

---------------------------------------------

signalTable.DeleteOld = function(caller)
	local window = caller:FindParent("Window");
	if Confirm("Confirm Deletion","Do you want to delete outdated agenda entries?") then
		window:DeleteOld();
	end
end

-- ---------------------------------------------
signalTable.OnGridClicked = function(caller)
	local window = caller:FindParent("Window");
	local settings = window.WindowSettings;
	if settings.Setup then
		local targetAction = settings.ToolAction;
		if targetAction ~= "Select" then
			CmdIndirect(string.format("%s UIGridSelection",targetAction));
		end
	end
end

------------------------------------------------

signalTable.DoResetSelection = function(caller)
	local window = caller:FindParent("Window");
	local settings = window.WindowSettings;
	settings:ResetSelectedAgenda();
	settings:ResetSelectedDay();
end