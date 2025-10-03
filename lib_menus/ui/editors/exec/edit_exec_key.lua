local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


function signalTable:OnInputLoad(caller,status,creator)
	local dialog=caller.DialogContent;
	local target=caller.Context;

	dialog.KeyToken.Target   = target;
	dialog.MAKeyToken.Target = target;

	dialog.Key.Target   = target;
	dialog.MAKey.Target   = target;

	local Index = target:Index();

	if( (Index >= 91 and Index <= 98) or (Index >= 191 and Index <= 198) ) then -- XKEYS MA-Keys are predefined
	  dialog.MAKeyToken.Visible = false;
	  dialog.MAKey.Visible = false;
	  caller.H=175;
	else
	  dialog.MAKeyToken.Visible = true;
	  dialog.MAKey.Visible = true;
	  caller.H=300;
	end
end
