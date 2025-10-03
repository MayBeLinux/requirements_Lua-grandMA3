local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)    
	local settings = caller.Settings;
	HookObjectChange(signalTable.OnSettingsChanged,	settings,	my_handle:Parent(), caller);
	signalTable.OnSettingsChanged(settings, caller, caller);
	local root=Root();
	caller.ImportDialogContent.PSRArea.LocalSubTitle.Title.Text = "PSR: " ..root.Temp.ConvertTask.ShowfileName;
	caller.ImportDialogContent.LocalArea.LocalSubTitle.Title.Text = "Local Running: " .. root.ManetSocket.Showfile .. ".show";
end

signalTable.OnRunImport = function()    
	Root().Temp.ConvertTask:OnRunImport();
end

signalTable.OnCleanup = function()    
	Root().Temp.ConvertTask:OnCleanup();
end

signalTable.OnClosePSR = function(caller)
	Root().Temp.ConvertTask:OnClosePSR();

	local overlay = caller:GetOverlay()
	overlay.Close()
end

signalTable.UseSettingsTarget = function(caller)
	caller.Target = caller:GetOverlay().Settings;
end

signalTable.OnSettingsChanged = function(settings, dummy, overlay)
	if(overlay.ImportDialogContent) then
		if(settings.SheetStyle or not settings.ObjectTypeValid) then
			overlay.ImportDialogContent.LocalArea.Frame.PoolWindowPlace.Visible = false;
			overlay.ImportDialogContent.LocalArea.Frame.LocalGrid.Visible = true;
		else
			overlay.ImportDialogContent.LocalArea.Frame.PoolWindowPlace.Visible = true;
			overlay.ImportDialogContent.LocalArea.Frame.LocalGrid.Visible = false;
		end
	end
end

signalTable.PoolWindowLoaded = function(caller,status,creator)	
	local overlay = caller:GetOverlay()
	caller.WindowSettings = overlay.Settings
end

--signalTable.OnDataPoolChanged = function(caller,status,creator)
--	overlay:OnSelectDataPool();
--	signalTable.OnSettingsChanged(overlay.Settings);
--end
