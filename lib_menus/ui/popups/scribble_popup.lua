local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
	return ShowData().Scribbles;
end

signalTable.GetRenderOptions = function()
	return {left_icon=false, number=false, right_icon=false, left_scribble=true, right_scribble=false};
end

signalTable.HasOwnEditor = function(caller)
	local CallingDialog = caller:FindParent("TextInput");
	local FromTextInput = false;
	if(CallingDialog and CallingDialog:IsClass("TextInput")) then
		FromTextInput = true;
		CallingDialog.IsScribbleNew = true;
	end
	return FromTextInput;
end