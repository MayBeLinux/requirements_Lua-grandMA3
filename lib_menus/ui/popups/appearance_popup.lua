local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
	return ShowData().Appearances;
end

signalTable.GetRole = function()
	return Enums.Roles.Default;
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=true, right_icon=false};
end

signalTable.HasOwnEditor = function(caller)
	local CallingDialog = caller:FindParent("TextInput");
	local FromTextInput = false;
	if(CallingDialog and CallingDialog:IsClass("TextInput")) then
		FromTextInput = true;
		CallingDialog.IsAppearanceNew = true;
	end
	return FromTextInput;
end