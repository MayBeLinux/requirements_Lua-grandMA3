-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
-- The 'GetPool' function called by 'signalTable.OnLoaded' from the 'generic_popup.lua'
signalTable.GetPool = function()
	return ShowData().Datapools;
end
signalTable.GetEmptyText = function()
	return "All DataPools";
end
signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end

signalTable.OnLoaded = function(caller, status, creator)
	caller:ClearList();
	caller:AddListNumericItem("<Link Selected>", -1);
	caller:AddListNumericItem("All DataPools", -2);
	local pool = signalTable.GetPool(caller);
	local addArgs = caller.AdditionalArgs;
	if(pool)then
		caller:AddListChildren(pool, signalTable.GetRole());
		local render_opts = signalTable.GetRenderOptions();
		signalTable.ApplyRenderOptions(caller, render_opts);

		if(caller.Context.SelectedDataPool:sub(1, 1) == "<") then
			caller:SelectListItemByIndex(1);		
		elseif(caller.Context.SelectedDataPool == "All DataPools") then
			caller:SelectListItemByIndex(2);
		else
			caller:SelectListItemByName(caller.Value);
		end

		caller:Changed();
	end
end

signalTable.GetPopupItemListValidOnly = function(caller)
	caller:ClearList();
	caller:AddListNumericItem("<Link Selected>", -1);
	caller:AddListNumericItem("All DataPools", -2);
	local pool = signalTable.GetPool(caller);
	if(pool)then
		caller:AddListChildren(pool, signalTable.GetRole());
	end
end

signalTable.OnAddNew = nil