local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


function signalTable:OnInputLoad(caller,status,creator)
	local dialog=caller.DialogContent;
	local target=caller.Context;

	dialog.EncoderClickToken.Target   = target;
	dialog.MAEncoderClickToken.Target = target;

	dialog.EncoderClick.Target   = target;
	dialog.MAEncoderClick.Target   = target;
end
