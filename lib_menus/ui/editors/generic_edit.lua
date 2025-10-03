local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local CurrentUserName = "";

signalTable.OnGenericEditLoaded = function(caller,status,creator)
   HookObjectChange(signalTable.OnUserLoginChanged,  CmdObj(), my_handle:Parent(), caller);
   CurrentUserName = CmdObj().User.Name;      
end

signalTable.OnUserLoginChanged = function(dummy1, dummy2, caller)
    if (CmdObj().User.Name ~= CurrentUserName) then
		CurrentUserName = CmdObj().User.Name;
		caller:GetOverlay().Close();
	end	
end
