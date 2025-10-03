local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local pVars = nil;
local function UpdateColumnFilter(o)
	local filter = GetVar(pVars, "ColumnFilter");
	o.Content.ObjectGrid:WaitInit(2);
	local s = o.Content.ObjectGrid:GridGetSettings();
	local filterCollect = s:Ptr(1);
	filterCollect.SelectedFilter = filter;
end

signalTable.ButtonClicked = function(caller,signal)
	 CmdIndirect("AddOn 'MVR' 'MVRIMPORTPSR'")
	 local o = caller:GetOverlay()
	 o:Close()
end

signalTable.ColumnsFilterSelected = function(caller, dummy, handleInt, idx)
	local filter = caller:GetListItemValueStr(idx + 1);
	local o = caller:GetOverlay();
	SetVar(pVars, "ColumnFilter", filter);

	UpdateColumnFilter(o);
end

signalTable.MvrEditorLoaded = function(caller, str)
	pVars = PluginVars():Ptr(1);
	local colFiltersBtn = caller.TitleBar.TitleButtons.ColumnsFilters;
	colFiltersBtn:ClearList();
	colFiltersBtn:AddListStringItem("Full", "Full");
	colFiltersBtn:AddListStringItem("Condensed", "Condensed");
	
	local selectedFilter = GetVar(pVars, "ColumnFilter");
	if (selectedFilter ~= nil) then
		colFiltersBtn:SelectListItemByValue(selectedFilter);
	else
		colFiltersBtn:SelectListItemByValue("Condensed");
		SetVar(pVars, "ColumnFilter", "Condensed");
	end

	UpdateColumnFilter(caller);
end
