local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function(caller)
	local ExecEditor = caller:Parent():Parent();
	if ExecEditor.name == "ExecutorEditor" then
		local DataPoolButton = ExecEditor.TitleBar.ConfigButtons.ConfigDatapool;
		local selectedDataPool = StrToHandle(DataPoolButton.SelectedItemValueStr)
		if selectedDataPool then
			return selectedDataPool.Configurations;
		end
	end
	return DataPool().Configurations;
end

signalTable.GetEmptyText = function()
	return nil;
end

signalTable.OnAddNew =  function(caller)
	local new_obj=signalTable.GetPool(caller):Acquire();
	if(new_obj) then
		local exec_editor=caller:FindParent("AllExecEditor");
		if(exec_editor) then
		   local exec =exec_editor.EditTarget;
		   local config=exec.Config;
		   new_obj:Copy(config);
		   new_obj.Name="Copy of "..config.Name;
		end
	end
	return caller,new_obj;
end



