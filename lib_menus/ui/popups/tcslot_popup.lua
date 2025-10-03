-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
-- The 'GetPool' function called by 'signalTable.OnLoaded' from the 'generic_popup.lua'
signalTable.GetPool = function()
	return Root().TimecodeSlots;
end

signalTable.GetPopupItemList = function(caller, list)
	signalTable.GetPopupItemListValidOnly(caller, list);
end

signalTable.GetPopupItemListValidOnly = function(caller, list)
	local pool = signalTable.GetPool(caller);

	list:AddListNumericItem("<Internal>",-1);
	list:AddListNumericItem("<Selected>", 0);

	for i,tcslot in ipairs(pool) do
		list:AddListNumericItem(tcslot.Name, i);
	end
end

