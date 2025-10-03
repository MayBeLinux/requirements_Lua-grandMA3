local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.CloseNone = function(caller,status)
    local o = caller:GetOverlay();
	caller:Parent().InputField.Clear();
	o.Close();
end
