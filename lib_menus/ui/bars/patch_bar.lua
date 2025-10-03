local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(caller,status,creator)
    caller.Lower.Encoder1.Target=creator;
    caller.Lower.Encoder2.Target=creator;
    caller.Lower.Encoder3.Target=creator;
    caller.Lower.Encoder4.Target=creator;
    caller.Lower.Encoder5.Target=creator;
end

