local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.OnLoad = function(window,status,creator)
    window:WaitInit();

    -- Enable/Disable ListRef button if autolistref is set
    local settings = window.WindowSettings;
    local currentLinkMode = Enums.InfoLinkMode[settings.LinkMode];
    window.TitleBar.RefMode.enabled = (currentLinkMode == Enums.InfoLinkMode.None);

    window.TitleBar.Buttons:SetChildren("Target", settings);;

    HookObjectChange(signalTable.SettingsChanged,settings, my_handle:Parent(), window);
	signalTable.SettingsChanged(settings, nil, window)

end

signalTable.SettingsChanged = function(settings, dummy, window)
    signalTable.initWindowModeBtn(window.TitleBar.Buttons.WindowMode, settings);
    signalTable.initLinkModeBtn(window.TitleBar.Buttons.LinkMode, settings);

    window.DialogFrame.RefContainer.ListContainer.NotesGrid.EditToolbar.Visible = settings.EditMode;
end

signalTable.OnListRefDone = function(caller, signal)
    local window = caller:FindParent("WindowInfo");
    signalTable.SettingsChanged(window.WindowSettings, nil, window)
end

signalTable.SetTarget = function(caller)
    local win = caller:FindParent("WindowInfo")
    caller.Target = win.WindowSettings
    signalTable.UpdateEditBar(caller);
end

signalTable.UndoTextEdit =  function(caller)
    -- Is focus inside our window?
    local win = caller:FindParent("WindowInfo");
    if (win ~= nil) then
        local noteInput = signalTable.GetFocusObjectInsideCaller(win);
        if (noteInput ~= nil) then
            noteInput:Undo();
        end
    end
end

signalTable.RedoTextEdit =  function(caller)
    -- Is focus inside our window?
    local win = caller:FindParent("WindowInfo");
    if (win ~= nil) then
        local noteInput = signalTable.GetFocusObjectInsideCaller(win);
        if (noteInput ~= nil) then
            noteInput:Redo();
        end
    end
end

signalTable.UndoRedoChanged = function(caller,dummy,undosCount,redosCount)
    signalTable.UpdateEditBar(caller);
end

signalTable.OnFocus = function(caller)
    signalTable.UpdateEditBar(caller);
end

signalTable.UpdateEditBar = function(caller)
	local win = caller:FindParent("WindowInfo");
    if (win ~= nil) then
        local noteInput = signalTable.GetFocusObjectInsideCaller(win);
        local a = win:GetClass();
        if (noteInput ~= nil and noteInput:GetClass() == "NoteTextEdit") then
            local undoBtn = win.TitleBar.Undo;
            local redoBtn = win.TitleBar.Redo;

            if (undoBtn) then
                if (noteInput.UndoCount > 0) then
                    undoBtn.State = true;
                else
                    undoBtn.State = false;
                end
                undoBtn.ToolTip = "Undo last change ("..noteInput.UndoCount.." available)";
            end

            if (redoBtn) then
                if (noteInput.RedoCount > 0) then
                    redoBtn.State = true;
                else
                    redoBtn.State = false;
                end
                redoBtn.ToolTip = "Redo last undo ("..noteInput.RedoCount.." available)";
            end
        end
    end
end

signalTable.GetFocusObjectInsideCaller = function(caller)
    local focusedObject = GetFocus();
    if (focusedObject ~= nil) then
        local parentCheck = focusedObject:FindParent(caller:GetClass());
        if (parentCheck ~= nil) then
            return focusedObject;
        end
    end

    return nil;
end