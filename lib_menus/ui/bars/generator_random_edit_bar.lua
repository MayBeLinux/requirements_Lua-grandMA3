local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(caller,status,editor)
    if caller.Lower:SetChildren("Target",editor.EditTarget)~=true then
        ErrEcho("Random Generator Editor BarLoaded : Target not found")
    end
end

