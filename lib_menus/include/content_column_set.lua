local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetWindowSettings(caller)
	local overlay = caller:GetOverlay(); -- ContextMenu or ColumnSetEditor
	local EditTarget = overlay.EditTarget;

	if IsClassDerivedFrom(EditTarget:GetClass(), "GridColumnConfiguration") then
		local collect = EditTarget:FindParent("GridColumnConfigurationCollect")
		return collect:Parent();
	end

	if IsClassDerivedFrom(EditTarget:GetClass(), "ViewWidget") then
		return EditTarget:Ptr(1); -- WindowSettings of ViewWidget Content
	end

	if IsClassDerivedFrom(EditTarget:GetClass(), "WindowSettings") then
		return EditTarget;
	end

	error("GetWindowSettings failed.")
end

local function GetSelectedConfig(caller)
	local WindowSettings      = GetWindowSettings(caller)
	local ColumnConfiguration = WindowSettings.SelectedColumnConfiguration

	if not ColumnConfiguration then
		ErrEcho("Column Configuration not found!");
	end

	return ColumnConfiguration
end

signalTable.OnColumnConfigLoaded = function(caller)
	local WindowSettings = GetWindowSettings(caller)
	HookObjectChange(signalTable.SheetSettingsHook,  WindowSettings, my_handle:Parent(), caller);
	signalTable.SheetSettingsHook(WindowSettings, nil, caller);
end

signalTable.SheetSettingsHook = function(settings, dummy, caller)
	local SelectedConfig = settings.SelectedColumnConfiguration

	local overlay = caller:GetOverlay()
	if overlay.name == "ColumnSetEditor" then
		if overlay.EditTarget ~= SelectedConfig then
			overlay.EditTarget = SelectedConfig;
		end
	end

	if SelectedConfig:Count() == 0 then
		-- give time to build up grid and initialize configuration
		coroutine.yield({ui=2})
	end

	if (caller.CCLeft.ColConfigGrid.TargetObject ~= SelectedConfig) then
		caller.CCLeft.ColConfigGrid.TargetObject = SelectedConfig
		
		UnhookMultiple(signalTable.ColConfigHook, nil, caller);
		HookObjectChange(signalTable.ColConfigHook,  SelectedConfig, my_handle:Parent(), caller);
		signalTable.ColConfigHook(SelectedConfig, nil, caller);
	end
end

signalTable.ColConfigHook = function(config, dummy, caller)
	if IsObjectValid(config) then
		caller.CCRight.Buttons.SetAllVisibleBtn.Enabled = not config.AllColumnsVisible
		caller.CCRight.Buttons.SetAllInvisibleBtn.Enabled = not config.AllColumnsInvisible
		caller.CCRight.ResetOrderBtn.Enabled = config.UserChangedSorting
		caller.CCRight.LabelDeleteButtons.DeleteBtn.Enabled = config:Index() ~= 1
	end
end

signalTable.OnLoadedColumnsButton = function(caller)
	local WindowSettings = GetWindowSettings(caller)
	caller.Target = WindowSettings;

	local overlay = caller:GetOverlay()
	if overlay.name == "ColumnSetEditor" then
		caller.IndirectEdit = false
	end
end

local function move(caller, steps)
	local grid = caller:Parent():Parent().ColConfigGrid
	local cells = grid:GridGetSelectedCells();
	local header_offset = 2;

	if steps < 0 then
		table.sort(cells, function(a,b) return a.r < b.r end)
	else
		table.sort(cells, function(a,b) return a.r > b.r end)
	end

	for k,v in ipairs(cells) do
		local startI = v.r - header_offset
		local endI = startI + steps

		if not grid.TargetObject.MoveColumns(startI,endI,1,1) then
			return;
		end
	end
	-- grid:ScrollVertical(steps)
	grid:GridMoveSelection(0,steps)
end

signalTable.OnClickedColConfigUp = function(caller)
	move(caller, -1)
end

signalTable.OnClickedColConfigDown = function(caller)
	move(caller, 1)
end

signalTable.OnClickedAllColumnsVisible = function(caller)
	local WindowSettings = GetWindowSettings(caller)
	WindowSettings.SetAllVisible();
end

signalTable.OnClickedAllColumnsInvisible = function(caller)
	local WindowSettings = GetWindowSettings(caller)
	WindowSettings.SetAllInvisible();
end

signalTable.OnClickedColConfigResetOrder = function(caller)
	local WindowSettings = GetWindowSettings(caller)
	WindowSettings.ResetColumnOrder();
end

signalTable.OnClickedDeleteSet = function(caller)
	local SelectedConfig = GetSelectedConfig(caller)
	Cmd("Delete "..SelectedConfig)
end

signalTable.OnClickedLabelSet = function(caller)
	local SelectedConfig = GetSelectedConfig(caller)
	CmdIndirect("Label "..SelectedConfig)
end

signalTable.OnClickedNewSet = function(caller)
	local settings = GetWindowSettings(caller)
	local collect = settings.GridColumnConfigurationCollect
	local current = settings.SelectedColumnConfiguration
	local type    = settings.GridColumnConfigurationType
	
	local newObj = collect:Acquire(type)
	if(newObj) then
		newObj:Copy(current);
		newObj.name = "";
	end

	settings.SelectedColumnConfiguration = newObj
end
