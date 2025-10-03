local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.RebuildPlaceholder = function(ph, menu)
    if (menu) then
        if Root().Menus[menu] then
            Root().Menus[menu]:CommandCall(ph, false);
        else
            ErrEcho("RebuildPlaceholder: Menu %s not found!", menu)
        end
    else
        local child = ph:GetUIChild(1);
        if child then
            child:CommandDelete();
        end
    end
end