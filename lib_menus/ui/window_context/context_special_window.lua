local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.MyTabChanged = function(caller,_,tab_id,tab_index)
    local ContextMenu = caller:GetOverlay()
    ContextMenu.ChangedActiveTab(caller);

    -- force hook call of context_window_titlebutton.lua
    ContextMenu.WindowSettings:Changed("Little")
end

signalTable.OnTabLoadSpecial = function(caller,status,creator)
    signalTable.OnTabLoad(caller,status,creator)

    local overlay = caller:GetOverlay()
    local settings = overlay.WindowSettings
    local tab = settings.RememberedTab

    assert(caller:FindListItemByValueStr(tab), "tab '"..tab.."' not found")
    caller:SelectListItemByValue(tab);

    HookObjectChange(signalTable.OnWindowSettingsChanged, settings, my_handle:Parent(), caller);
	signalTable.OnWindowSettingsChanged(settings, my_handle:Parent(), caller);
end

signalTable.OnWindowSettingsChanged = function(settings, signal, caller)
    local window = caller:FindParent("SpecialWindowContext")

    -- ShaperSettings
    window.DialogFrame.DialogContainer.Shapers.MiniFadersMode.Enabled = settings.shaperWindowSettings.ViewMode == "Graphical";
end