local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    if(caller.IsMainBuddy) then
	   signalTable.BaseInput=caller;
	   local target=CmdObj().TempStoreSettings;
	   target.NewName = "" -- reset
	   local Settings=caller.Frame.Settings;
	   	HookObjectChange(signalTable.OnEnableSettings,    -- 1. function to call
					 target,					-- 2. object to hook
					 my_handle:Parent(),		-- 3. plugin object ( internally needed )
					 Settings);    -- 4. user callback parameter
		signalTable.OnEnableSettings(target,nil,Settings);
	end
end

signalTable.OnEnableSettings = function(target,signal,caller)
	local ImageStoreSource = target.ImageStoreSource;
	caller.DisplayIndex.Visible=(ImageStoreSource=="ScreenShot");
	caller.NDIIndex.Visible    =(ImageStoreSource=="NDI");
end

signalTable.OnPleaseClicked = function(caller,status,creator)

	local target=CmdObj().TempStoreSettings;

	local text={ signalTable.BaseInput.StrContext };

	if(target.NewName~="") then
		table.insert(text,string.format(" '%s'",target.NewName));
	end

	if(target.ImageStoreSource=="ScreenShot") then
		table.insert(text,string.format("/Screen=%s",target.ImageDisplayIndex));
	else
		table.insert(text,string.format("/NDI=%s",target.ImageNDIIndex));
	end
	if(target.ImageResolution~="Full") then
		table.insert(text,string.format("/Xres=%s",target.ImageResolution));
	end
	table.insert(text,"/NC");
	text=table.concat(text," ");
	signalTable.BaseInput.Value=text;
	signalTable.BaseInput.Close();
	coroutine.yield({ui=3})
	CmdIndirect(text);

end
