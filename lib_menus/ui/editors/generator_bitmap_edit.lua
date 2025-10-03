local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnSetEditTarget = function(caller,dummy,target)

	local Frame=caller.Frame;
	local TabData = Frame.TabGrid.TabData;
	local Control  =Frame.Control;

	local config_handle=target.ConfigHandle;

	TabData.Channel.ChannelGrid.TargetObject=target.BitmapChannels;
	TabData.Config.ConfigGrid.TargetObject =target.BitmapConfigs;
	local columnId = GetPropertyColumnId(config_handle, "Content");
	TabData.Config.ConfigGrid.SelectCell('', HandleToInt(config_handle), columnId);

	Frame.TabGrid.Settings:SetChildren("Target",target);
	Control:SetChildren("Target",target);
	caller.FunctionButtons.FunctionButtonsRight.AutoFormat.Target = target;

	signalTable.target   = target;
	signalTable.Frame    = Frame;
	signalTable.Control  = Control;


end

signalTable.OnConfigSelected = function(caller,status,row_id)
	-- local target = IntToHandle(row_id);
	-- if IsObjectValid(target) then
	--   signalTable.Control:SetChildren("Target",target);
	-- end
end

signalTable.OnClickedAt=function()
	signalTable.target.LuaCommand("at");
end

signalTable.OnClickedReset=function(caller)
	signalTable.target.LuaCommand("reset");
end

signalTable.OnClickedResetChannel=function(caller, status)
	signalTable.target.LuaCommand("reset " .. status);
end

signalTable.OnClickedAutoDimension=function()
	signalTable.target.LuaCommand("auto_dimension");
end

signalTable.OnClickedFormatSelection=function()
	signalTable.target.LuaCommand("format_selection");
end

signalTable.ToggleBMC = function(caller)
	if(caller.target.HasActiveBMC) then
		CmdIndirect("Off Fixture " .. caller.target.BMC);
	else
		caller.target:OnActivateBMC();
	end
end


