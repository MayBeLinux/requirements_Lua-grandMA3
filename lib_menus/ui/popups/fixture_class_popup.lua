local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local function Main(display_handle)
end

signalTable.OnAddNew =  function(caller)
	local v = TextInput("a name of the new class", "");
	if (v ~= nil and v:len() > 0) then
		local p = Patch();
		local newClass = p.Classes:Append();
		newClass.Name = v;
		v = newClass;
	end
	return caller, v;
end

signalTable.GetPool = function()
	return Patch().Classes;
end

