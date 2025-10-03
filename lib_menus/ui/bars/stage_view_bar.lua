local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(caller,status,creator)
	Echo("Stage view bar loaded");    
end

signalTable.SetTarget = function(caller,status,creator)
	local sel=Selection();
	if caller["IsValid"] and caller:IsValid() then
		caller:SetChildren("Target",sel);
	end
end
