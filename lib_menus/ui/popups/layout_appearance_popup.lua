local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
	return ShowData().Appearances;
end

signalTable.GetRole = function()
	return Enums.Roles.Default;
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=true, right_icon=false};
end

signalTable.OnLoaded = function(caller,status,creator)
	-- build with <Default> as second entry	
	caller:ClearList();
	caller:AddListStringItem("None","None");
	caller:AddListNumericItem("<Default>",-1);
	local pool = signalTable.GetPool(caller);
	local addArgs = caller.AdditionalArgs;
	if(pool) then
		caller:AddListChildren(pool, signalTable.GetRole());
		if ((signalTable.OnAddNew ~= nil) and (addArgs == nil or addArgs.noNew == nil)) then
			caller:AddListLuaItem("New","OnAddNew", signalTable.OnAddNew);
		end

		local render_opts = signalTable.GetRenderOptions();
		signalTable.ApplyRenderOptions(caller, render_opts);

		if(caller.Context.Appearance == "None") then
			caller:SelectListItemByIndex(1);
		elseif(caller.Context.Appearance:sub(1, 1) == "<") then
			caller:SelectListItemByIndex(2);
		else -- Default Appearance
			caller:SelectListItemByValue(caller.Value);
		end
		caller:Changed();
	end

	if signalTable.FilterSupport() == true or addArgs.FilterSupport == "Yes" then
		caller.TitleBar:Ptr(2):Ptr(2).Size="50" --actually visible
		caller.TitleBar.FilterCtrl.Target = caller.Frame.ItemFilterField;
		caller.TitleBar.FilterCtrl.Visible = true;
		HookObjectChange(signalTable.FilterFieldChanged,caller.Frame.ItemFilterField,my_handle:Parent(),caller);
	end
end