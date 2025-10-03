local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BookOnLoad = function(caller,status,creator)
    if(caller.name ~= nil) then
		local gel = Root().ShowData.GelPools:Ptr(1);
		caller.Gels.TargetObject = gel;
		local settings = caller.Gels.GelGridSettings;
		caller.Buttons.GridTypeSelector.Target = settings;
		caller.Buttons.SortTypeSelector.Target = settings;

		local window = caller:FindParent("Window")
		local titlebarContent = window.TitleBar.SpecialDialogTitlebar:GetUIChild(1)
		local titlebuttons = titlebarContent.Titlebuttons

		if(titlebuttons.OverdriveMode.Enabled == true) 
		then
			titlebuttons.OverdriveMode.Enabled = false;
		end

		if(titlebuttons.ColorMixMode.Enabled == true) 
		then
			titlebuttons.ColorMixMode.Enabled = false;
		end
	end
end

signalTable.OnPoolSelected = function(caller,status,col_id,row_id)
    local gelPool=IntToHandle(row_id);
    caller:Parent().Gels.TargetObject = gelPool;
end

signalTable.OnGelSelected = function(caller,status,col_id,row_id)
    local gel=IntToHandle(row_id);

	--local window = caller:Parent():Parent():Parent():Parent():Parent();
	--local settings = window.WindowSettings;
	
	--local const_brightness = false;
	--if(settings.BrightnessOverdriveMode == "On") then
		--const_brightness = true;
	--end
	
    --SetColor("RGB",1,1,1,1,0,const_brightness);
	Cmd("At Gel '" .. gel:Parent().Name .. "'.'" .. gel.Name .. "'");
end
