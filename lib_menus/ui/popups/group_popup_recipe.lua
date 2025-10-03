local signalTable   = select(3,...); 

signalTable.BuildItemList = function(caller,status,creator)
	-- build with <From Value> as second entry
	caller:ClearList();
	caller:AddListStringItem("None","None");
	caller:AddListStringItem("<From Value>","<From Value>");
	local pool = signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller));
	local addArgs = caller.AdditionalArgs;
	if(pool) then
		caller:AddListChildren(pool, signalTable.GetRole());
		if ((signalTable.OnAddNew ~= nil) and (addArgs == nil or addArgs.noNew == nil)) then
			caller:AddListLuaItem("New","OnAddNew", signalTable.OnAddNew);
		end

		local render_opts = signalTable.GetRenderOptions();
		signalTable.ApplyRenderOptions(caller, render_opts);

		if(caller.Context.SelectionFromValue == true) then
			caller:SelectListItemByIndex(2);
		else -- Default Appearance
			caller:SelectListItemByValue(caller.Value);
		end
		caller:Changed();
	end
end




