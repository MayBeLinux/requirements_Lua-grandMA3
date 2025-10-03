local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnCueTimingPreferencesLoaded = function(caller,status,creator)
	local user_profile=CurrentProfile();
	if(user_profile) then
		local Preferences=user_profile.StorePreferences;
		if(Preferences) then
			local store_defaults_sequence=Preferences.Sequence;
			if(store_defaults_sequence) then
				caller:SetChildren("Target",store_defaults_sequence);
				local FGCount = ShowData().LivePatch.AttributeDefinitions.FeatureGroups:Count()
				for _,child in ipairs(caller) do
					local sub = string.sub(child.Name, 1, 6)
					if(sub == "Preset") then
						local nr = string.sub(child.Name, 11, string.len(child.Name))
						child.Visible = tonumber(nr) <= FGCount
						if(tonumber(nr) == FGCount) then
							if(string.sub(child.Name, 1, 10) == "PresetFade") then
								child.Texture=Root().GraphicsRoot.TextureCollect.Textures["corner4"];
							else
								child.Texture=Root().GraphicsRoot.TextureCollect.Textures["corner8"];
							end
						end

					end
				end
			else
			   ErrEcho("StorePreferencesSequence not found");
			end
		else
		   ErrEcho("StorePreferences not found");
		end
	else
	   ErrEcho("User Profile not found");
	end
end

signalTable.TimecodeDefaultsLoaded = function(caller,status,creator)
	local user_profile=CurrentProfile();
	if(user_profile) then
		local Preferences=user_profile.StorePreferences;
		if(Preferences) then
			local store_defaults_timecode=Preferences.Timecode;
			if(store_defaults_timecode) then
				caller.target = store_defaults_timecode;
			else
			   ErrEcho("StorePreferencesTimecode not found");
			end
		else
		   ErrEcho("StorePreferences not found");
		end
	else
	   ErrEcho("User Profile not found");
	end
end

signalTable.OnMIBTimingLoaded = function(caller,status,creator)
	local show_settings=ShowSettings();
	if(show_settings) then
		caller:SetChildren("Target",show_settings.DefaultPlaybackSettings);
	end
end

signalTable.OnGlobalLoaded = function(caller,status,creator)
	local show_settings=ShowSettings();
	if(show_settings) then
		caller:SetChildren("Target",show_settings.GlobalSettings);
	end
end

signalTable.OnPlaybackTimingLoaded = function(caller,status,creator)
	local show_settings=ShowSettings();
	if(show_settings) then
		caller:SetChildren("Target",show_settings.DefaultPlaybackSettings);
	end
end

local function GetSequenceDefaultsObject()
	local user_profile=CurrentProfile();
	if(user_profile) then
		local Preferences=user_profile.StorePreferences;
		if(Preferences) then
			local store_defaults_sequence=Preferences.Sequence;
			if(store_defaults_sequence) then
				return store_defaults_sequence;
			else
			   ErrEcho("StorePreferencesSequence not found");
			end
		else
		   ErrEcho("StorePreferences not found");
		end
	else
	   ErrEcho("User Profile not found");
	end
end

local function GetPresetDefaultsObject()
	local user_profile=CurrentProfile();
	if(user_profile) then
		local Preferences=user_profile.StorePreferences;
		if(Preferences) then
			local store_defaults_preset=Preferences.Preset;
			if(store_defaults_preset) then
				return store_defaults_preset;
			else
			   ErrEcho("StorePreferencesPresetnot found");
			end
		else
		   ErrEcho("StorePreferences not found");
		end
	else
	   ErrEcho("User Profile not found");
	end
end

local function UpdateOptions(overlay)
	local tab = overlay.Content.Dialogs.SequenceDefaults;
	if (tab.Visible) then
		local sequenceSettingsUI = nil;
		if (tab.ObjectSettings:GetUIChildrenCount() > 0) then
			sequenceSettingsUI = tab.ObjectSettings:GetUIChild(1);
		else
			local plugin     =my_handle:Parent();
			local plugin_pool=plugin:Parent(); 
			sequenceSettingsUI = plugin_pool.SequenceSettings:CommandCall(overlay);
		end

		if (sequenceSettingsUI) then
			sequenceSettingsUI.Target = GetSequenceDefaultsObject();
			sequenceSettingsUI.ActionBtn.Visible = false;
			sequenceSettingsUI.XFadeModeBtn.Texture = "corner12";
		else
			ErrEcho("Could not import playback settings ui");
		end
	end
end

local function UpdatePresetOptions(overlay)
	local tab = overlay.Content.Dialogs.PresetDefaults;
	if (tab.Visible) then
		local presetSettingsUI = nil;
		if (tab.ObjectSettings:GetUIChildrenCount() > 0) then
			presetSettingsUI = tab.ObjectSettings:GetUIChild(1);
		else
			local plugin     =my_handle:Parent();
			local plugin_pool=plugin:Parent(); 
			presetSettingsUI = plugin_pool.PresetSettings:CommandCall(overlay);
		end

		if (presetSettingsUI) then
			presetSettingsUI.Target = GetPresetDefaultsObject();
		else
			ErrEcho("Could not import preset settings ui");
		end
	end
end

signalTable.OnSequenceDefaultsVisible = function(caller,status,visible)
	if (visible) then
		UpdateOptions(caller:GetOverlay());
	end
end

signalTable.OnPresetDefaultsVisible = function(caller,status,visible)
	if (visible) then
		UpdatePresetOptions(caller:GetOverlay());
	end
end

signalTable.OnVisibleLayoutElementDefaults = function(caller)
	local Profile = CurrentProfile()
	local LECollect = Profile.LayoutElementDefaultsCollect;
    local LED = caller:FindParent("MainDialog").Content.Dialogs.LayoutElementDefaults;
    LED.TargetObject = LECollect;
end

signalTable.OnVisibleEditKeyboardShortcuts = function(caller)
    local overlay = caller:GetOverlay();
	local tab = overlay.Content.Dialogs.EditKeyboardShortcuts;
	if (tab.visible) then
	
       local plugin     =my_handle:Parent();
       local plugin_pool=plugin:Parent();
       plugin_pool.KeyboardShortcutDialog:CommandCall(overlay);
	end
end

signalTable.OnUserLoaded = function(caller,status,creator)
    HookObjectChange(signalTable.OnUserLoginChanged,  CmdObj(), my_handle:Parent(), caller);	
    signalTable.OnUserLoginChanged(nil, nil, caller);
end

signalTable.OnUserLoginChanged = function(dummy1, dummy2, caller)
    if(caller.Name == "UserSelected") then
		local label = "Selected (" .. CurrentUser().Name .. ")";
		caller.Text = label;		
	end
	if(caller.Name == "UserGrand") then
		local label = "Grand (" .. CurrentUser().Name .. ")";
		caller.Text = label;		
	end
end

signalTable.GroupSettingsLoaded = function(caller,status,creator)
	caller.Target = CurrentProfile().StorePreferences.Group
end

signalTable.GroupSettingsLoaded2 = function(caller,status,creator)
	caller.Target = CurrentProfile()
end
