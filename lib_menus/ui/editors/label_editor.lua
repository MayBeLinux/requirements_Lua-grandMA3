local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)	
	signalTable.TextInputLoaded(caller, status, creator);
	local targetInfo = caller.Context:Get("Name",Enums.Roles.Display);
	caller.TitleBar.Title.Text = "Label " .. targetInfo;
end

-- Overrides text_input::LoadPlaceholderComponents
signalTable.LoadPlaceholderComponents = function(caller)
	-- Full
	signalTable.InitNameNote(caller);
	signalTable.InitVirtualKeyboard(caller);
	signalTable.InitScribbleEditor(caller);
	signalTable.InitAppearanceEditor(caller);
	signalTable.InitTagsEditor(caller);
end