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
	
	local contentGrid = window.Title.AlignScroll.ContentGrid

	signalTable.SetItemCollectLayout(contentGrid,direction);

	local buttonsA = contentGrid.Aligns
	local buttonsB = contentGrid.AlignDirections
	local buttonsC = contentGrid.AlignTransitions
	local rows = contentGrid:Ptr(1)
	local columns = contentGrid:Ptr(2)

	buttonsA.Direction = direction
	buttonsB.Direction = direction
	buttonsC.Direction = direction

	if direction == "Vertical" then
		buttonsA.SideSize = 54
		buttonsB.SideSize = 54;
		buttonsC.SideSize = 54
		rows:Ptr(2).Size = 10
		rows:Ptr(4).Size = 10
	else
		buttonsA.SideSize = 100
		buttonsB.SideSize = 100;
		buttonsC.SideSize = 100
		columns:Ptr(2).Size = 49
		columns:Ptr(4).Size = 49
	end
end

signalTable.AlignControlLoad = function(caller,status,creator)
	caller.Title.AlignScroll.ExternScrollPos = caller
	HookObjectChange(signalTable.OnWindowChanged, caller, my_handle:Parent(), caller);
	signalTable.OnWindowChanged(caller);
end
