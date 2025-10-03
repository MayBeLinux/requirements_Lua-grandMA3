local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function SelectSubAttribute(caller, attr, x, y)
	if (attr ~= nil) then
		local wheel = caller.Context;
		local selectedSA = wheel.SubAttribute;
		local selectedA = nil;
		if (selectedSA ~= nil) then selectedA = selectedSA:Parent(); end;
		local itemList = {};
		for _,sa in ipairs(attr:Children()) do
			local saName = sa.Name;
			local saAddr = sa:AddrNative(attr:Parent());
			local stringItem = {"str", saName, saAddr};
			itemList[#itemList + 1] = stringItem;
		end
		local selIndex;
		selIndex, resultValue = PopupInput({title="SubAttribute", caller=caller, items=itemList, selectedValue=caller.Value, x=x, y=y});
		if (selIndex == nil) then return; end;
		return caller, resultValue;
	else
		ErrEcho("Failed to get an attribute object to run popup for");
	end
end

signalTable.OnLoaded = function(caller,status,creator)
    caller:AddListStringItem("None","");
	local p = Patch();
	local ad = p.AttributeDefinitions;
	local attrs = ad.Attributes;
	local wheel = caller.Context;
	local selectedSA = wheel.SubAttribute;
	local selectedA = nil;
	if (selectedSA ~= nil) then selectedA = selectedSA:Parent(); end;
    if(attrs) then
		local selIdx = nil;
		for i,v in ipairs(attrs:Children()) do
			caller:AddListLuaItem(v.Name.." >>>", "SelectSubAttribute", SelectSubAttribute, v);
			if (v == selectedA) then selIdx = i; end;
		end
		if (selIdx ~= nil) then caller:SelectListItemByIndex(selIdx); end;
    end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
