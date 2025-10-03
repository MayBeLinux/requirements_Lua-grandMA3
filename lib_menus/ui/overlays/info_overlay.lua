local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.OnLoad = function(window,status,creator)
    window:WaitInit();
end

signalTable.OnCharInput = function(caller, signal)
    local refContainer = caller:FindParent("ShadedOverlay").DialogFrame.RefContainer;
    refContainer:OnNoteCharInput(signal);
end