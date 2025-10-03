local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.ColorInputLoaded = function(caller,status,creator)
	caller.Frame.TopRow.ColorPicker01.Target = caller;
    caller.Frame.TopRow.TopRowRight.ColorView.Target = caller;
    caller.Frame.TopRow.TopRowRight.LineEdit.Target = caller;
	caller.Frame.BottomRow.ColorPicker02.Target = caller;
	caller.Frame.BottomRow.Faders.R.Target = caller;
	caller.Frame.BottomRow.Faders.G.Target = caller;
	caller.Frame.BottomRow.Faders.B.Target = caller;
	caller.Frame.BottomRow.Faders.A.Target = caller;
	caller.Frame.BottomRow.Faders.Hue.Target = caller;
	caller.Frame.BottomRow.Faders.Sat.Target = caller;
	caller.Frame.BottomRow.Faders.Br.Target = caller;
end

return Main;