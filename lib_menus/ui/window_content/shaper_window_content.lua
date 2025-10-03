local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function toggleInsRotFadersVisibility(parent, visibility)
	if (parent ~= nil) then
		if (parent.HeaderIns ~= nil) then
			parent.HeaderIns.Visible = visibility;
			parent.HeaderRot.Visible = visibility;
		end
		parent.ShaperFader1Ins.Visible = visibility;
		parent.ShaperFader1Rot.Visible = visibility;
		parent.ShaperFader2Ins.Visible = visibility;
		parent.ShaperFader2Rot.Visible = visibility;
		parent.ShaperFader3Ins.Visible = visibility;
		parent.ShaperFader3Rot.Visible = visibility;
		parent.ShaperFader4Ins.Visible = visibility;
		parent.ShaperFader4Rot.Visible = visibility;
	end
end

local function toggleABFadersVisibility(parent, visibility)
	if (parent ~= nil) then
		if (parent.HeaderA ~= nil) then
			parent.HeaderA.Visible = visibility;
			parent.HeaderB.Visible = visibility;
		end
		parent.ShaperFader1A.Visible = visibility;
		parent.ShaperFader1B.Visible = visibility;
		parent.ShaperFader2A.Visible = visibility;
		parent.ShaperFader2B.Visible = visibility;
		parent.ShaperFader3A.Visible = visibility;
		parent.ShaperFader3B.Visible = visibility;
		parent.ShaperFader4A.Visible = visibility;
		parent.ShaperFader4B.Visible = visibility;
	end
end

-- Signal
signalTable.OnShaperContentLoaded = function(caller,status,creator)
	-- Hide for loading visibility of elements
	caller.Visible = false;
	caller:WaitInit(1)

	local window = caller:FindParent("Window")
	local shaperWindowSettings = window.WindowSettings.ShaperWindowSettings

	local sel = Selection();
	caller.FrameMiniFaders:SetChildren("Target", sel);
	caller.ShaperMiniFaders:SetChildren("Target", sel);
	caller.BladeMiniFaders:SetChildren("Target", sel);
	caller.BigFaders:SetChildren("Target", sel);

	UnhookMultiple(signalTable.OnWindowSettingsChanged, nil, shaperWindowSettings);
	HookObjectChange(signalTable.OnWindowSettingsChanged,shaperWindowSettings,my_handle:Parent(),caller);
	signalTable.OnWindowSettingsChanged(shaperWindowSettings, my_handle:Parent(), caller);

	-- SHow after everything has been loaded
	caller.Visible = true;
end

signalTable.OnResetBlade1 = function(caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetBlade(1);
	end
end

signalTable.OnResetBlade2 = function(caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetBlade(2);
	end
end

signalTable.OnResetBlade3 = function(caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetBlade(3);
	end
end

signalTable.OnResetBlade4 = function(caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetBlade(4);
	end
end

signalTable.OnResetRotation = function (caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetRotation();
	end
end

signalTable.OnResetPov = function (caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetPov();
	end
end

signalTable.OnResetShaper = function (caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetShaper();
	end
end

signalTable.OnResetAllBlades = function (caller)
	local window = caller:FindParent("Window")
	local settings = window.WindowSettings.ShaperWindowSettings
	if (settings ~= nil) then
		settings:ResetAllBlades();
	end
end

signalTable.OnWindowSettingsChanged = function(settings, signal, caller)
	caller.FrameMiniFaders.Visible = settings.ShowPov;
	if (settings.ViewMode == "Graphical") then
		caller.ViewGrid.Visible = true;

		if (settings.MiniFadersMode == "Full") then
			caller.ShaperMiniFaders.Visible = true;
			caller.BladeMiniFaders.Visible = true;
			if (settings.ControlMode == "Ins+Rot") then
				toggleInsRotFadersVisibility(caller.BladeMiniFaders, true);
				toggleABFadersVisibility(caller.BladeMiniFaders, false);
			else
				toggleInsRotFadersVisibility(caller.BladeMiniFaders, false);
				toggleABFadersVisibility(caller.BladeMiniFaders, true);
			end
		elseif (settings.MiniFadersMode == "Blades") then
			caller.ShaperMiniFaders.Visible = false;
			caller.BladeMiniFaders.Visible = true;
			if (settings.ControlMode == "Ins+Rot") then
				toggleInsRotFadersVisibility(caller.BladeMiniFaders, true);
				toggleABFadersVisibility(caller.BladeMiniFaders, false);
			else
				toggleInsRotFadersVisibility(caller.BladeMiniFaders, false);
				toggleABFadersVisibility(caller.BladeMiniFaders, true);
			end
		elseif (settings.MiniFadersMode == "Rotation") then
			caller.ShaperMiniFaders.Visible = true;
			caller.BladeMiniFaders.Visible = false;

		else
			caller.ShaperMiniFaders.Visible = false;
			caller.BladeMiniFaders.Visible = false;
		end

		caller.BigFaders.Visible = false;

		caller.ResetBarGraphic.Visible = settings.ShowResetBar;
		caller.ResetBarBigFaders.Visible = false;
	else -- big faders
		caller.ViewGrid.Visible = false;
		caller.ShaperMiniFaders.Visible = false;
		caller.BladeMiniFaders.Visible = false;
		caller.BigFaders.Visible = true;

		if (settings.ControlMode == "Ins+Rot") then
			toggleInsRotFadersVisibility(caller.BigFaders, true);
			toggleABFadersVisibility(caller.BigFaders, false);
		else
			toggleInsRotFadersVisibility(caller.BigFaders, false);
			toggleABFadersVisibility(caller.BigFaders, true);
		end

		caller.ResetBarBigFaders.Visible = settings.ShowResetBar;
		caller.ResetBarGraphic.Visible = false;
	end
end
