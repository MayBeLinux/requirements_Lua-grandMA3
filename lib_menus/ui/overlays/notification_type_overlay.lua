local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)
    local overlay = caller:GetOverlay();

    caller.TitleBar.Title.Text = "Select Notification Type";

    local list = caller.Frame.NotificationTypeList;
    local mask = overlay.context.NotificationVisibilityMask;
    list.Target = overlay.Context;
    list.EnabledItems = ~mask;
end
