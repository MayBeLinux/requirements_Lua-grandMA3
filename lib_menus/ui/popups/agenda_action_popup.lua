local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	-- rebuild with <Default> as second entry
	local previousItems = {}
	for i=2, caller:GetListItemsCount() do
		previousItems[i] = {
			caller:GetListItemName(i), caller:GetListItemValueStr(i)
		}
	end

	caller:ClearList()
	caller:AddListStringItem("None","Empty")
	caller:AddListStringItems(previousItems)

	local isNumber = type(caller.Context.Action) == "number";
	if(isNumber) then
		local Name = GetTokenNameByIndex(caller.Context.Action);
		caller:SelectListItemByName(Name);
	else
		if(caller.Context.Action == "None") then
			caller:SelectListItemByIndex(1);
		else -- Default action
			caller:SelectListItemByIndex(2);
		end
	end
end