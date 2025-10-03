local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.OnAddNew =  function(caller)
	local v = TextInput("a name of the new layer", "", x, y);
	if (v ~= nil and v:len() > 0) then
		local p = Patch();
		local newLayer = p.Layers:Append();
		newLayer.Name = v;
		v = newLayer;
	end
	return caller, v;
end


signalTable.GetPool = function()
	return Patch().Layers;
end
