local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller)
    --local target = caller.Frame.Fader
    --caller.Frame.Speedfactor.Target = target

    --caller.Frame.GroupType.Text = caller.Frame.Fader.Property
end