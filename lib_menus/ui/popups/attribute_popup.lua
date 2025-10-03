local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
    local Patch=Patch();
    return Patch.AttributeDefinitions.Attributes
end

signalTable.FilterSupport = function()
	return true
end

signalTable.FilterDefaultVisible = function()
	return true
end
