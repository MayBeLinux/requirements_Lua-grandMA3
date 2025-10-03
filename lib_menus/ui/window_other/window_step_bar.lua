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

	signalTable.SetItemCollectLayout(window.Title.Content,direction);
	window.Title.Content.StepScroll.Steps.Direction=direction;

	if direction == "Horizontal" then
		local minSize = window.Title.Content.StepScroll.Steps.MinCellSize;
		local expectedDirection = nil;
		if (window.AbsRect.h > (minSize * 2)) then
			expectedDirection="Vertical";
		else
			expectedDirection="Horizontal";
		end
		window.Title.Content.StepScroll.Steps.Direction=expectedDirection;
	end

	if window.Title.Content.StepScroll.Steps.Direction == "Horizontal" then
		window.Title.Content.StepScroll.Steps.Texture = "corner5"
	else
		window.Title.Content.StepScroll.Steps.Texture = "corner3"
	end

	if direction == "Horizontal" then
		window.Title.Content.SelectAll.Texture = "corner10"
		window.Title.Content.StepScroll.Steps.SideSize = 50
	else
		window.Title.Content.SelectAll.Texture = "corner12"
		window.Title.Content.StepScroll.Steps.SideSize = 54
	end
end

signalTable.StepControlLoad = function(caller,status,creator)
	caller.Title.Content.StepScroll.ExternScrollPos = caller
	HookObjectChange(signalTable.OnWindowChanged, caller, my_handle:Parent(), caller);
	signalTable.OnWindowChanged(caller);
end

