local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	Echo("RenderQualityEditor:OnLoaded");	
end
signalTable.OnSetEditTarget = function(caller,dummy,target)
	--Echo("RenderQualityEditor:OnSetEditTarget");
	caller.Frame.MainDialogContainer:SetChildren("Target",target);
	caller.Frame.MainDialogContainer.Quality.ButtonGrid.PropertyButtons.target = target;
	caller.Frame.MainDialogContainer.Quality.FaderGrid.LightScale.Target=target;
	caller.Frame.MainDialogContainer.Quality.FaderGrid.ResolutionScale3D.Target=target;
	caller.Frame.MainDialogContainer.Quality.FaderGrid.NativeColors.Target=target;
	caller.Frame.MainDialogContainer.Quality.FaderGrid.DilutionScale.Target=target;

	caller.Frame.MainDialogContainer.Haze.Buttons.HazeEnabled.Target=target;

	caller.Frame.MainDialogContainer.Haze.HazeParticleQuality.Target=target;
	caller.Frame.MainDialogContainer.Haze.HazeParticleSize.Target=target;
	caller.Frame.MainDialogContainer.Haze.HazeScale.Target=target;
	caller.Frame.MainDialogContainer.Haze.HazeLayers.Target=target;
	caller.Frame.MainDialogContainer.Haze.HazeBlend.Target=target;
	caller.Frame.MainDialogContainer.Haze.HazeAnimationSpeed.Target=target;
end

signalTable.SetTarget = function(caller)
	--Echo("RenderQualityEditor:SetTarget");
	local o = caller:GetOverlay();
	caller.Target=o.Content.Timecode:GridGetSettings();
end


signalTable.ImportRenderQuality= function(caller,dummy,target)
	local o = caller:GetOverlay();
	local libImport = Root().Menus.LibraryImport;
	if (libImport) then
		local et = o.EditTarget;
		if (et ~= nil) then
			local targetAddr = "Root "..et:Addr();
			local libImportUI = libImport:CommandCall(caller,false);
			if (libImportUI) then
				libImportUI:InputSetAdditionalParameter("Destination", targetAddr);
				libImportUI:InputSetAdditionalParameter("Library", "RenderQuality Library");
				libImportUI:InputSetTitle("Import RenderQuality from:");
				libImportUI:InputRun();

				libImportUI:Parent():Remove(libImportUI:Index());
				WaitObjectDelete(libImportUI, 1);
				FindNextFocus();
			end
		end
	end
end
