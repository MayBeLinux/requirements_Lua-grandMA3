local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

function CheckControl(ctrl,s)
	if (ctrl) then
		Echo("***** Ctrl '%s' is Valid. His name is:%s",s,ctrl.name);
	else
		Echo("***** Ctrl '%s' is INVALID.",s)
	end
end

signalTable.WindowLoaded = function(caller,status,creator)
	local UserProfile=CurrentProfile();
	if (UserProfile) then
		local settings                           = CurrentProfile().TemporaryWindowSettings.View3DSettings;
		local renderQuality                      = CurrentProfile().TemporaryWindowSettings.RenderQuality;
		-- -------------------------------------------------------------------------------------------------------
		-- Misc
		-- -------------------------------------------------------------------------------------------------------
		local misc                               = caller.DialogFrame.MainDialogContainer.DLG3D.DialogContainer3D.Misc;
		misc.Wireframed.Target                   = settings;
		misc.BeamMode.Target                     = renderQuality;
		misc.BodyQuality3d.Target                = renderQuality;
		-- -------------------------------------------------------------------------------------------------------
		-- Label
		-- -------------------------------------------------------------------------------------------------------
		local label                              = caller.DialogFrame.MainDialogContainer.DLG3D.DialogContainer3D.Label;
		local checkmarksGrid			         = label.CheckmarksGrid;
		local faderGrid							 = label.FaderGrid;
		local misc    							 = label.Misc;
		checkmarksGrid.EnableLabel.Target        = settings;
		checkmarksGrid.ShowLabelOnSpot.Target    = settings;
		checkmarksGrid.ShowLabelFixtureId.Target = settings;
		checkmarksGrid.ShowLabelCID.Target       = settings;
		checkmarksGrid.ShowLabelPatch.Target     = settings;
		checkmarksGrid.ShowLabelName.Target      = settings;

		faderGrid.BackgroundAlpha.Target         = settings;
		faderGrid.TextAlpha.Target               = settings;

		misc.LabelFontSize.Target                = settings;
		misc.LabelMaxCount.Target                = settings;
		misc.LabOnlySelection.Target             = settings;
		misc.LabSelectionPrio.Target             = settings;
		misc.ShowSpotLabelSubFixtureId.Target    = settings;
	end
end

