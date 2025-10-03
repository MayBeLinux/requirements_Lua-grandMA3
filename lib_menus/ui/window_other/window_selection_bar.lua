local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

function signalTable.OnWindowChanged(window)
	if not IsObjectValid(window) then
		UnhookMultiple(signalTable.OnWindowChanged,window)
		return;
	end

	local direction, textmode = signalTable.AnalyseWindowDimensions(window)
	signalTable.ChangeGeneralLayout(window, direction, textmode)

	window.Title.ButtonScroll.Buttons.Direction = direction;
	
	if direction == "Vertical" then
		window.Title.ButtonScroll.Buttons.SideSize = 54
	else
		window.Title.ButtonScroll.Buttons.SideSize = 100
	end
end

signalTable.SelectionBarLoad = function(caller,status,creator)
	caller.Title.ButtonScroll.ExternScrollPos = caller
	HookObjectChange(signalTable.OnWindowChanged, caller, my_handle:Parent(), caller);
	signalTable.OnWindowChanged(caller);
end
