local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function keyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

signalTable.initWindowModeBtn = function(windowModeBtn, settings)
    windowModeBtn:ClearList();

    local targetName = settings.TargetName;
    local childName = settings.ChildName;

    -- Target name, if it exists
    if (targetName ~= "" and childName ~= "") then
        windowModeBtn:AddListNumericItem(targetName, Enums.InfoWindowMode.Object);
        windowModeBtn:AddListNumericItem("Current " .. childName, Enums.InfoWindowMode.CurrentChild);
        windowModeBtn:AddListNumericItem("Next " .. childName, Enums.InfoWindowMode.NextChild);
        windowModeBtn:AddListNumericItem("All " .. childName .. "s", Enums.InfoWindowMode.AllChildren);
        windowModeBtn:AddListNumericItem(targetName .. " and " .. childName .. "s", Enums.InfoWindowMode.ObjectAndChildren);
    else
        windowModeBtn:AddListNumericItem("Fixed", Enums.InfoWindowMode.Object);
    end

    local currentWindowMode = Enums.InfoWindowMode[settings.WindowMode];
    windowModeBtn:SelectListItemByIndex(currentWindowMode + 1);
end

signalTable.initLinkModeBtn = function(linkModeBtn, settings)
    linkModeBtn:ClearList();
    linkModeBtn:AddListNumericItem("Fixed", Enums.InfoLinkMode.None);
    linkModeBtn:AddListNumericItem("Selected Sequence", Enums.InfoLinkMode.SelectedSequence);

    local currentLinkMode = Enums.InfoLinkMode[settings.LinkMode];
    linkModeBtn:SelectListItemByIndex(currentLinkMode + 1);
end

signalTable.OnWindowModeChanged = function(caller, signal, window, idx)
    -- Called from window, overlay or context?
    local contextWindow = caller:FindParent("GenericContext");
    local infoWindow = caller:FindParent("WindowInfo");

    local settings = nil;
    if (contextWindow ~= nil) then
        settings = contextWindow.WindowSettings;
    elseif (infoWindow ~= nil) then
        settings = infoWindow.WindowSettings;
    end;

    if (settings ~= nil) then
        local currentWindowMode = Enums.InfoWindowMode[settings.WindowMode];
        if (currentWindowMode ~= idx) then
            settings.WindowMode = keyOf(Enums.InfoWindowMode, idx);
            settings:ChangeWindowMode();
        end
    end
end

signalTable.OnLinkModeChanged = function(caller, signal, window, idx)
    -- Called from window, overlay or context?
    local contextWindow = caller:FindParent("GenericContext");
    local infoWindow = caller:FindParent("WindowInfo");

    local settings = nil;
    if (contextWindow ~= nil) then
        settings = contextWindow.WindowSettings;
    elseif (infoWindow ~= nil) then
        settings = infoWindow.WindowSettings;
    end;

    if (settings ~= nil) then
        local currentLinkMode = Enums.InfoLinkMode[settings.LinkMode];
        if (currentLinkMode ~= idx) then
            settings.LinkMode = keyOf(Enums.InfoLinkMode, idx);
            settings:ChangeLinkMode();
        end
    end

    -- Enable/Disable ListRef button if autolistref is set
    if (infoWindow ~= nil) then
        infoWindow.TitleBar.RefMode.enabled = (idx == Enums.InfoLinkMode.None);
    end
end