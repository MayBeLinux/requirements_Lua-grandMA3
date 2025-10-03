local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnUITabExampleLoad = function(caller,status,creator)
	Echo("OnUITabExampleLoad");
	local tab = caller.Frame.GenericTab;
	local vtab = caller.Frame.TabContents.MyTab4.VGenericTab;
	if (tab) then
		Echo("We have a tab. we init it");
		tab:AddListStringItem("Tab 1", "MyTab1");
		tab:AddListStringItem("Tab 2", "MyTab2");
		tab:AddListStringItem("Tab 3", "MyTab3");
		tab:AddListStringItem("Deepthought", "MyTab4");
		tab:SelectListItemByValue("MyTab1");
	end

	if (vtab) then
		vtab:AddListStringItem("Vert 1", "MyTab1V");
		vtab:AddListStringItem("Vert 2", "MyTab2V");
		vtab:SelectListItemByValue("MyTab2V");
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
	Echo("OnLoad done");
end
