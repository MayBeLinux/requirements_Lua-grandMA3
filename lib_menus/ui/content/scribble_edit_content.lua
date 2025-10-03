local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.ScribbleUndo = function(caller, status, creator)
    Cmd("Oops");
    caller:Parent():Parent():Parent():ApplyScribble();
end