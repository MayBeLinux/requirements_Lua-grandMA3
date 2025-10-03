local pluginName = select(1, ...);
local componentName = select(2, ...);
local signalTable = select(3, ...);
local my_handle = select(4, ...);


signalTable.FocusToContext = function(caller,dummy,keyCode,shift,ctrl,alt)
	--require 'gma3_debug'()
	local shiftOnly = shift and not ctrl and not alt;

	Echo("The following keycode was pressed:" .. keyCode)
	if ((keyCode == Enums.KeyboardCodes.Right) or (keyCode == Enums.KeyboardCodes.Left)) then
		if (IsObjectValid(caller)) then 
			FindBestFocus(caller);
		end
	elseif (keyCode == Enums.KeyboardCodes.Up) then
		FindNextFocus(true);--back
	elseif ((keyCode == Enums.KeyboardCodes.Down) or (keyCode == Enums.KeyboardCodes.Enter)) then
		FindNextFocus();
	elseif (keyCode == Enums.KeyboardCodes.Escape) then
		caller:GetOverlay().CloseCancel();
	end
end

signalTable.LineEditSelectAll = function(caller)
    if (IsObjectValid(caller)) then caller.SelectAll(); end
end

signalTable.LineEditDeSelect = function(caller, dummy, newFocus)

    if (IsObjectValid(caller)) then caller.DeSelect(); end
end
