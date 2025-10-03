local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.PopupDevLoaded = function(caller,status,creator)
	caller:AddListNumericItem("Item 1", 1000);
	caller:AddListNumericItems({"Item 2", {"Item 3", 90}, {"Item 4", 100}, {"Item 5"}, 300, "Item 6"});
	caller:RemoveListItem("300");
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
