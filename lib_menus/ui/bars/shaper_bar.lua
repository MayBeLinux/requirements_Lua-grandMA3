local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function toggleInsRotEncodersVisibility(parent, visibility)
	if (parent ~= nil) then
		parent.ShaperEncoder1Ins.Visible = visibility;
		parent.ShaperEncoder1Rot.Visible = visibility;
		parent.ShaperEncoder2Ins.Visible = visibility;
		parent.ShaperEncoder2Rot.Visible = visibility;
		parent.ShaperEncoder3Ins.Visible = visibility;
		parent.ShaperEncoder3Rot.Visible = visibility;
		parent.ShaperEncoder4Ins.Visible = visibility;
		parent.ShaperEncoder4Rot.Visible = visibility;
	end
end

local function toggleABEncodersVisibility(parent, visibility)
	if (parent ~= nil) then
		parent.ShaperEncoder1A.Visible = visibility;
		parent.ShaperEncoder1B.Visible = visibility;
		parent.ShaperEncoder2A.Visible = visibility;
		parent.ShaperEncoder2B.Visible = visibility;
		parent.ShaperEncoder3A.Visible = visibility;
		parent.ShaperEncoder3B.Visible = visibility;
		parent.ShaperEncoder4A.Visible = visibility;
		parent.ShaperEncoder4B.Visible = visibility;
	end
end

signalTable.BarLoaded = function(caller,status,context)
	local sel = Selection();

	if (context:GetClass() == "SpecialWindow") then
		caller.LinkedObject = context;

		local settings = context.WindowSettings.ShaperWindowSettings;
		HookObjectChange(signalTable.OnShaperSettingsChanged, settings, my_handle:Parent(), caller);
		signalTable.OnShaperSettingsChanged(settings, my_handle:Parent(), caller);

		caller.Lower:SetChildren("Target", sel);
		caller.Upper:SetChildren("Target", settings);
	end
end

signalTable.OnShaperSettingsChanged = function(settings, signal, caller)
	if IsObjectValid(caller) then
		if (settings.BarMode == "Blades") then
			if (settings.ControlMode == "Ins+Rot") then
				toggleInsRotEncodersVisibility(caller.Lower, true);
				toggleABEncodersVisibility(caller.Lower, false);
			else
				toggleInsRotEncodersVisibility(caller.Lower, false);
				toggleABEncodersVisibility(caller.Lower, true);
			end
		else
			toggleInsRotEncodersVisibility(caller.Lower, false);
			toggleABEncodersVisibility(caller.Lower, false);
		end
	end
end

signalTable.OnResetBlade1 = function(caller)
	local context = caller:Parent():Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetBlade(1);
		end
	end
end

signalTable.OnResetBlade2 = function(caller)
	local context = caller:Parent():Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetBlade(2);
		end
	end
end

signalTable.OnResetBlade3 = function(caller)
	local context = caller:Parent():Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetBlade(3);
		end
	end
end

signalTable.OnResetBlade4 = function(caller)
	local context = caller:Parent():Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetBlade(4);
		end
	end
end

signalTable.OnResetRotation = function (caller)
	local context = caller:Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetRotation();
		end
	end
end

signalTable.OnResetShaper = function (caller)
	local context = caller:Parent():Parent().LinkedObject;
	if (context ~= nil) then
		local settings = context.WindowSettings.ShaperWindowSettings
		if (settings ~= nil) then
			settings:ResetShaper();
		end
	end
end