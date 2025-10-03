local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function()
	return ShowData()["Meshes"];
end

signalTable.OnAddNew =  function(caller)
	local new_obj=signalTable.GetPool(caller):Acquire("UserMesh");
	local IsTextEdit = false;
	if(signalTable.HasOwnEditor ~= nil) then 
	    IsTextEdit = signalTable.HasOwnEditor(caller); 
	end

	if(new_obj and not IsTextEdit) then
		--[[
			performing a delayed 'edit root ...' execution in order to let the Popup to finish it's modal loop and mark itself as closed/closing

			otherwise 'edit' command is executed BEFORE popup is notified about Lua's 'return' values, while popup UIObject is still valid and not closed,
			so that the editor uses it as a placeholder source and is automatically closed with the popup itself few milliseconds later (as the result of 'return'
			 value processing)
		]]
		caller:HookDelete(function()
			if (IsObjectValid(new_obj)) then
				CmdIndirect("EDIT ROOT " .. new_obj:Addr());
			end
		end);
	end
	return caller,new_obj;
end
