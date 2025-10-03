local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.DialogLoaded = function(dialog)
	local temp    =CmdObj().TempStoreSettings;
	HookObjectChange(signalTable.OnStoreSettingsChanged,
				     temp,
					 my_handle:Parent(),
					 dialog);
	signalTable.OnStoreSettingsChanged(temp,nil,dialog);	
end

local CF_ActiveForSelected = 1;
local CF_AllForSelected    = 2;
local CF_Active            = 4;
local CF_All               = 8;

local CF_Programmer        = CF_ActiveForSelected + CF_AllForSelected + CF_Active + CF_All;
local CF_Output            = CF_AllForSelected + CF_All;
local CF_DMX               = CF_AllForSelected + CF_All;
local CF_Look              = CF_AllForSelected + CF_All;

local StoreSourceMask=
{
	["Programmer"] = CF_Programmer;
	["Output"    ] = CF_Output;
	["DMX"       ] = CF_DMX;
};

signalTable.OnStoreSettingsChanged = function(temp,dummy,dialog)
	
	if(temp.StoreLook) then
		dialog.UseSelectionBlock.ChannelFilter.EnabledItems=CF_Look;
	else
		dialog.UseSelectionBlock.ChannelFilter.EnabledItems=StoreSourceMask[temp.StoreSource];
	end
end

--these couple of functions are intentionally global and are used in other places (update_overlay)
function SaveStorePreferencesToProfile()
	local Preferences=CurrentProfile().StorePreferences;
	local temp       =CmdObj().TempStoreSettings;
	
	-- attention: when changing StorePreferences, the TempStoreSettings are adjusted directly!
	-- this is why we need to copy all before adjusting

	local tempTable = 
	{
		ChannelFilter = temp.ChannelFilter;
		StoreLook = temp.StoreLook;
		StoreMode = temp.StoreMode;
		StoreSource = temp.StoreSource;
		UpdateModePresets = temp.UpdateModePresets;
		UpdateModeCues = temp.UpdateModeCues;
		StoreMatricks = temp.StoreMatricks;
		PresetInputFilter = temp.PresetInputFilter;
		UpdateInputFilter = temp.UpdateInputFilter;
		KeepActivation = temp.KeepActivation;
		PresetMode = temp.PresetMode;
		UpdatePresetMode = temp.UpdatePresetMode;
		CueOnly = temp.CueOnly;
		TrackingShield = temp.TrackingShield;
		UpdateCueOnly = temp.UpdateCueOnly;
		GridMergeMode = temp.GridMergeMode;
		StoreEmbedded = temp.StoreEmbedded;
	}

	for k,v in pairs(tempTable) do
		Preferences[k] = v;
	end

	CurrentProfile().ProgUpdateCueFilter = CmdObj().CueUpdates.FilterMode;
end

function LoadStorePreferencesFromProfile()
	local Preferences=CurrentProfile().StorePreferences;
	local temp    =CmdObj().TempStoreSettings;
	temp.ChannelFilter = Preferences.ChannelFilter;
	temp.StoreLook     = Preferences.StoreLook;
	temp.StoreMode     = Preferences.StoreMode;
	temp.StoreSource   = Preferences.StoreSource;
	temp.UpdateModePresets = Preferences.UpdateModePresets;
	temp.UpdateModeCues = Preferences.UpdateModeCues;
	temp.StoreEmbedded = Preferences.StoreEmbedded;
	temp.StoreMatricks  = Preferences.StoreMatricks;
	temp.PresetInputFilter  = Preferences.PresetInputFilter;
	temp.UpdateInputFilter  = Preferences.UpdateInputFilter;
	temp.KeepActivation = Preferences.KeepActivation;
	temp.PresetMode     = Preferences.PresetMode;
	temp.UpdatePresetMode = Preferences.UpdatePresetMode;
	temp.TrackingShield = Preferences.TrackingShield
	temp.CueOnly        = Preferences.CueOnly
	temp.UpdateCueOnly = Preferences.UpdateCueOnly;
	temp.GridMergeMode  = Preferences.GridMergeMode;
	CmdObj().CueUpdates.FilterMode = CurrentProfile().ProgUpdateCueFilter;
end

signalTable.OnSavePreferences = function(caller)
	SaveStorePreferencesToProfile();
end

signalTable.OnLoadPreferences = function(caller)
	LoadStorePreferencesFromProfile();
end
