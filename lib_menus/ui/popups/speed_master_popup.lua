local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return MasterPool().Speed;
end

signalTable.OnAddNew = nil;

signalTable.GetRole = function()
	return Enums.Roles.Default;	
end

signalTable.SelectListItemBySomething = function(caller)
    caller:SelectListItemByName(caller.Value);
end




