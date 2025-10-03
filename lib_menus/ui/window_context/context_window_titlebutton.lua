local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- fill the following table in the corresponding lua file of the context window
signalTable.CustomNames = {}

-- **************************************************************************************************
-- titlebutton control functions 
-- **************************************************************************************************

signalTable.OnLoadedTitlebuttonContent = function (containerHandle)
	local contextMenu = containerHandle:GetOverlay()
	local MainWindowSettings = contextMenu.WindowSettings
	HookObjectChange(signalTable.UpdateTitleButtonTables,MainWindowSettings,my_handle:Parent(),containerHandle)
	signalTable.UpdateTitleButtonTables(MainWindowSettings, nil, containerHandle)
end

signalTable.UpdateTitleButtonTables = function (mainWindowSettings, status, containerHandle)
	local contextMenu = containerHandle:GetOverlay()
	local targetWindowSettings = contextMenu.SubWindowSettings

	local activeList = containerHandle.ActiveList;
	activeList:ClearList();
	if (targetWindowSettings.VisibleTitlebuttons) then
		for _,v in ipairs(targetWindowSettings.VisibleTitlebuttons) do
			if signalTable.CustomNames[v] then
				activeList:AddListStringItem(signalTable.CustomNames[v],v);
			else
				activeList:AddListStringItem(v,v);
			end
		end
	end
end

signalTable.OnTitleButtonTabVisible = function(caller, status, visible)
	-- force scrollbar update
	caller.ActiveButtons.ScrollV:Changed()
end

signalTable.OnClickedTbDelete = function (buttonHandle)
	-- toggle currently selected active button
	local contextMenu = buttonHandle:GetOverlay()
	local settingsHandle = contextMenu.SubWindowSettings

	local containerHandle = buttonHandle:Parent():Parent()
	local activeList = containerHandle.ActiveList
	local selectedItemIdx = activeList:GetListSelectedItemIndex()
	local selectedItemName = activeList:GetListItemValueStr(selectedItemIdx)

	Cmd("Set %s 'TitleButtonMask' '%s'",settingsHandle:ToAddr(),selectedItemName)
end

local function move(buttonHandle, offset)
	-- modify settings list directly:
	local contextMenu = buttonHandle:GetOverlay()
	local settingsHandle = contextMenu.SubWindowSettings

	local containerHandle = buttonHandle:Parent():Parent()
	local activeList = containerHandle.ActiveList
	local selectedItemIdx = activeList:GetListSelectedItemIndex()
	local selectedItemName = activeList:GetListItemValueStr(selectedItemIdx)

	if (selectedItemName) then
		local newIndex = selectedItemIdx + offset;
	
		local modifiedList = settingsHandle.VisibleTitlebuttons;
		if (newIndex >= 1 and newIndex <= #modifiedList ) then
			table.remove(modifiedList,selectedItemIdx)
			table.insert(modifiedList,newIndex,selectedItemName)
			settingsHandle.VisibleTitlebuttons = modifiedList
		end
	
		activeList:SelectListItemByIndex(newIndex)
	end
end

signalTable.OnClickedTbUp = function (buttonHandle)
	move(buttonHandle,-1)
end

signalTable.OnClickedTbDown = function (buttonHandle)
	move(buttonHandle,1)
end

signalTable.OnClickedTbDefaults = function (buttonHandle)
	local overlayHandle = buttonHandle:GetOverlay()
	overlayHandle.TBLoadDefaults();
end

signalTable.OnClickedTbDeleteAll = function (buttonHandle)
	local overlayHandle = buttonHandle:GetOverlay()
	overlayHandle.TBDeleteAll();
end
