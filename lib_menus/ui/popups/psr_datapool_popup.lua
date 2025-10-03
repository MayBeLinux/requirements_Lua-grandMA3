local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return ShowData().Datapools;
end

signalTable.GetEmptyText = function()
	return "Original";
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end

signalTable.OnAddNew =  function(caller)
	local new_obj=signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller)):Acquire();

	return caller,new_obj;
end