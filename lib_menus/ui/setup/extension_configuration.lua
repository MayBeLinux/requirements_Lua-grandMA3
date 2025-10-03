local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.onLoad = function(caller, dummy, handleInt, idx)
    --setting column filter swipe button's target property to a GridColumnFilterCollect object in the settings
    caller.Content.ExtensionsGrid:WaitInit(1);
    caller.TitleBar.TitleButtons.ColumnsFilters.Target = caller.Content.ExtensionsGrid:GridGetSettings():Ptr(1);
end
