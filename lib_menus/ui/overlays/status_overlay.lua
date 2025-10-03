local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)
    local overlay = caller:GetOverlay();

    local visibilityList = caller.Frame.VisibilityList;
    local visibilityMask = overlay.context.StatusVisibilityMask;
    visibilityList.Target = overlay.Context;
    visibilityList.EnabledItems = ~visibilityMask;

    -- Source
    local localonly = overlay.context.localonly;
    caller.TitleBar.Title.Text = "Select Display Mode";
    if (localonly) then
        caller.Frame.SourceTitle.Visible = false;
        caller.Frame.SourceList.Visible = false;
        caller.Frame.VisibilityList.W = 260;
    else
        caller.Frame.SourceList.Target = overlay.Context;
        caller.Frame.SourceTitle.W = 200;
        caller.Frame.SourceList.W = 200;
        caller.Frame.VisibilityList.W = 200;
    end
end
