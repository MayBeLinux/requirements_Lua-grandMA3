local pluginName = select(1, ...);
local componentName = select(2, ...);
local signalTable = select(3, ...);
local my_handle = select(4, ...);

signalTable.OnTitleClick =  function(caller)
    local win = caller:FindParent("NotificationArea");
    if (win ~= nil) then
        win:OnTitleClick();
    end
end
