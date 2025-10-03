-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
-- The 'GetPool' function called by 'signalTable.OnLoaded' from the 'generic_popup.lua'
signalTable.GetPool = function()
	return DataPool().Pages;
end

signalTable.GetEmptyText = function()
	return "<Link Selected>", nil, {indirect=true};
end

signalTable.OnLoaded = function(caller,status,creator)
	local pool = signalTable.GetPool(caller);
	if(pool) then
		signalTable.GetPopupItemListValidOnly(caller, caller);
		caller:SelectListItemByValue(caller.Value);
		caller:Changed();
	end
end



