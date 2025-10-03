local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SetPresetPoolTarget = function(caller,status,creator)
	local contextEditor = caller:GetOverlay();
	local editTarget = contextEditor.EditTarget;
	local window = editTarget.UIWindow;
	caller.Target  = window.PoolObject;
	caller.visible = true; -- set only at this point to avoid lua errors with (auto-set) wrong target
end

signalTable.PresetActionTarget = function(caller,status,creator)
    local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local WindowSettings    = ViewWidget:Ptr(1);
	caller.Target           = WindowSettings;	
end

signalTable.TitleButtonLoaded = function(caller, status, creator)
	caller.Text = "Preset Pool Settings"
end

local IndexToPresetPoolType = 
{
	[0] = "PresetDimmerPool",
	[1] = "PresetPositionPool",
	[2] = "PresetGoboPool",
	[3]	= "PresetColorPool",
	[4] = "PresetBeamPool",
	[5] = "PresetFocusPool",
	[6] = "PresetControlPool",
	[7] = "PresetShapersPool",
	[8] = "PresetVideoPool",
	[20] = "PresetAllPool",
	[21] = "PresetAllPool",
	[22] = "PresetAllPool",
	[23] = "PresetAllPool",
	[24] = "PresetAllPool",
	[4294967295] = "PresetDynamicPool",
	["Dynamic"] = "PresetDynamicPool"
}

signalTable.LoadButtonLoaded = function(caller, status, creator)
	local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local value = IndexToPresetPoolType[ViewWidget.PresetPoolType]
	caller.signalValue = value
end

signalTable.SaveButtonLoaded = function(caller, status, creator)
	local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local value = IndexToPresetPoolType[ViewWidget.PresetPoolType]
	caller.signalValue = value
end