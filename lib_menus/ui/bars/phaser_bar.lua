local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local VisibleTable={ };



signalTable.SetChildValues = function(caller,signal,creator)
	for i,child in ipairs(caller) do
		if (Enums.ProgLayer[child.Name]) then
			child.ColorIndicator = "ProgLayer." .. child.Name;
			child.Text			 = child.Name;
			child.Value			 = child.Name;
		end
	end
end