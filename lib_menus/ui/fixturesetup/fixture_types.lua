local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function PathSettingsChanged(obj, chLev, ctx)
	if IsObjectValid(ctx) then
		local gr = ctx:FindRecursive("FixtureTypesSetupGrid", "DBObjectGrid")
		local prevMask = gr:GridGetData().FilterMask
		gr:GridGetData().FilterMask = obj.FilterMaskValue;
		if prevMask ~= obj.FilterMaskValue then
			gr:GridGetBase():Changed()
		end
	end
end

signalTable.OnFTListLoaded = function(caller)
	local patch_settings=GetPatchSettings()
	HookObjectChange(PathSettingsChanged, patch_settings, my_handle:Parent(), caller);
	PathSettingsChanged(patch_settings, nil, caller)
	caller.TitleBar.TitleButtons.DMXFullOnly.Target = patch_settings;
end