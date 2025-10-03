local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnAddNew = nil;


signalTable.FilterSupport = function()
	return true
end

signalTable.FilterDefaultVisible = function()
	return true
end

signalTable.GetPool = function(caller, dataPool)
	local indexTemporaryWindowSettings  = 10;
	local temporaryWindowSettings = CurrentProfile():Ptr(indexTemporaryWindowSettings);
	return temporaryWindowSettings["PSRPatchSheetSettings"].LayerFilterList;
end

signalTable.GetPopupItemListValidOnly = function(caller, list)
	local EmptyText=nil;
	local EmptyTextAppearance=nil;
	local EmptyTextOpts=nil;

	local addArgs = caller.AdditionalArgs
	if (addArgs and addArgs.AddEmpty) then
		EmptyText = addArgs.AddEmpty
	else
		if (signalTable.GetEmptyText) then
			EmptyText, EmptyTextAppearance, EmptyTextOpts = signalTable.GetEmptyText();
		end
	end

	if(EmptyText) then
		list:AddListStringItem(EmptyText,EmptyText, EmptyTextAppearance, EmptyTextOpts);
	end


	local pool = signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller));
	for i = 1, #pool do
	    list:AddListStringItem(pool[i],pool[i]);
    end
end

signalTable.SelectListItemBySomething = function(caller)
    caller:SelectListItemByValue(caller.Context.LayerFilter);
end
