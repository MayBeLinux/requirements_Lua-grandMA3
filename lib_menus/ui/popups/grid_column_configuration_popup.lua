local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetSettings(caller)
	if caller.property == "SelectedColumnConfiguration" then
		return caller.Target;
	else
		return caller:Parent():Parent().Target; -- clickedButton
	end
end

signalTable.GetPool = function(caller)
	local settings = GetSettings(caller)
	return settings.GridColumnConfigurationCollect
end

signalTable.GetEmptyText = function()
	return nil;
end

signalTable.OnAddNew =  function(caller)
	local settings = GetSettings(caller)
	local collect = settings.GridColumnConfigurationCollect
	local current = settings.SelectedColumnConfiguration
	local type    = settings.GridColumnConfigurationType
	
	local newObj = collect:Acquire(type)
	if(newObj) then
		newObj:Copy(current);
		newObj.name = ""
	end

	if caller:FindParent("TitleBar") then
		caller:HookDelete(function()
			if (IsObjectValid(newObj)) then
				CmdIndirect("Edit " .. newObj);
			end
		end);
	end

	return caller,newObj;
end



