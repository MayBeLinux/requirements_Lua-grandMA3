local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


function signalTable:OnInputLoad(caller,status,creator)
	local dialog=caller.DialogContent;
	local target=caller.Context;

	dialog.EncoderRightToken.Target   = target;
	dialog.MAEncoderRightToken.Target = target;

	dialog.EncoderRight.Target   = target;
	dialog.MAEncoderRight.Target   = target;
end
