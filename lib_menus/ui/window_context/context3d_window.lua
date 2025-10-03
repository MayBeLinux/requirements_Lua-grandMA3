local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- ***************************************************************************************************
-- Inserts RawSettings if in Alpha-version
-- ***************************************************************************************************
signalTable.OnTabLoad = function(caller,status,creator)
    if (not BuildDetails().IsRelease or ReleaseType() == "Alpha" ) then
        caller:AddListStringItem("Raw Settings", "RawSettings");
    end
    if(caller:GetListItemsCount() == 1) then
        caller.Visible = false;
    end
end
signalTable.OnTabLoadDev = function(caller,status,creator)
    if (not BuildDetails().IsRelease ) then
        caller:AddListStringItem("Developer", "Developer");
        return;
    end
    if (DevMode3d() == "Yes") then
        caller:AddListStringItem("Developer", "Developer");
        return;
    end
end

-- ***************************************************************************************************
-- OnSetEditTarget3d
-- ***************************************************************************************************

signalTable.OnSetEditTarget3d = function(caller,dummy,target)
end

-- ***************************************************************************************************
-- Context3dLoaded
-- ***************************************************************************************************

signalTable.Context3dLoaded = function(caller,status,creator)
    --Echo("Context3dLoaded");
    -- The caller is the GenericContext
    local dialogContainer=caller.DialogFrame.MainDialogContainer.DLG3D.DialogContainer3D;
    local uiLayoutGrid=caller.DialogFrame.MainDialogContainer.DLG3D.DialogContainer3D._Major;
    if (uiLayoutGrid) then
        -- Echo("uiLayoutGrid found");
        local window = caller.EditTarget;
        if (window) then
            local faderAmbientIntensity=uiLayoutGrid.AutoLayout.AmbientIntensity;
            if (faderAmbientIntensity) then
                -- Echo("***** faderAmbientIntensity found");
                -- I actually wanted to set the targets of the fader here from lua
                -- Unfortunately, I did not succeed in finding the WindowSettings here
                -- Since the setting of the targets in the c ++ code happens, it is no longer necessary.
                -- So consistently, it seems that not only lua and xml are used
            end
        end
    end
end

-- **************************************************************************************************
-- load & save preferences functions 
-- **************************************************************************************************

signalTable.LoadPrefClicked = function(caller,value)

    local ContextEditor             = caller:GetOverlay();
    local ViewWidget                = ContextEditor.EditTarget;
    local WindowSettings            = ViewWidget:Ptr(1);
    local Preferences               = CurrentProfile().StorePreferences.Views[value];

    local manager_plugin=Root().Menus.ContextWindowManager;
    if(manager_plugin) then
        local manager_overlay=manager_plugin:CommandCall(caller);
        if(manager_overlay) then
            manager_overlay:InputSetTitle("Load Preference");
            manager_overlay:InputSetAdditionalParameter("Mode", "Load");
            local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
            ObjectGrid.TargetObject=Preferences;
            local CurrentPref=WindowSettings.PreferenceHandle;
            if(CurrentPref) then
                local columnId = GetPropertyColumnId(CurrentPref, "Name");
                ObjectGrid.SelectCell('',HandleToInt(CurrentPref),columnId);
            end
            local result=manager_overlay:InputRun();
            if(result) then
                local resultHandle=StrToHandle(result.Value);
                if(resultHandle) then
                    WindowSettings:Copy(resultHandle);
                    WindowSettings.PreferenceHandle=resultHandle;
                end
            end
        end
    end
end

signalTable.SavePrefClicked = function(caller,value)

    local ContextEditor             = caller:GetOverlay();
    local ViewWidget                = ContextEditor.EditTarget;
    local WindowSettings            = ViewWidget:Ptr(1);
    local Preferences               = CurrentProfile().StorePreferences.Views[value];

    local manager_plugin=Root().Menus.ContextWindowManager;
    if(manager_plugin) then
        local manager_overlay=manager_plugin:CommandCall(caller);
        if(manager_overlay) then
            manager_overlay:InputSetTitle("Save Preference");
            manager_overlay:InputSetAdditionalParameter("Mode", "Save");
            local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
            ObjectGrid.TargetObject=Preferences;
            local CurrentPref=WindowSettings.PreferenceHandle;
            if(CurrentPref) then
                local columnId = GetPropertyColumnId(CurrentPref, "Name");
                ObjectGrid.SelectCell('',HandleToInt(CurrentPref),columnId);
            end
            local result=manager_overlay:InputRun();
            if(result) then
                local resultHandle=StrToHandle(result.Value);
                if(resultHandle) then
                    local OldName=resultHandle.Name;
                    resultHandle:Copy(WindowSettings);
                    resultHandle.Name=OldName;
                    WindowSettings.PreferenceHandle=resultHandle;
                end
            end
        end
    end
end