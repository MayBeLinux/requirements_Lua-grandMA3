-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
-- The 'GetPool' function called by 'signalTable.OnLoaded' from the 'generic_popup.lua'
signalTable.GetPool = function()
	return ShowData().Datapools;
end
signalTable.GetEmptyText = function()
	return "<Link Selected>";
end
signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end

signalTable.OnAddNew =  function(caller)
	local new_obj=signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller)):Acquire();

	return caller,new_obj;
end