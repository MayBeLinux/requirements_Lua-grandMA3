local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnTabLoad = function(caller,status,creator)
	if (ReleaseType() == "Alpha") then
		caller:AddListStringItem("Raw Settings", "RawSettings");
		caller:Changed();
	end 
	if(caller:GetListItemsCount() == 1) then
		caller.Visible = false;
	end
end

signalTable.OnResetColors = function(caller)
	local contextEditor = caller:GetOverlay();
	local ViewWidget = contextEditor.EditTarget;
	local Window = ViewWidget.UIWindow;
	local PoolSettings=ViewWidget:Ptr(1);
	Window:Changed();
	ViewWidget:Changed();
	PoolSettings.PoolColor   ="00000000";
	PoolSettings.EmptyColor  ="00000000";
	PoolSettings.ForAllColor ="00000000";
	PoolSettings.ForSomeColor="00000000";
	PoolSettings.ForNoneColor="00000000";
end

signalTable.TitleButtonLoaded = function(caller,status,creator)
	local contextEditor = caller:GetOverlay();
	local ViewWidget = contextEditor.EditTarget;
	local PoolWindow = ViewWidget.UIWindow
	caller.Text = PoolWindow.Text .. " Pool Settings"
end

-- **************************************************************************************************
-- load & save preferences functions 
-- **************************************************************************************************

signalTable.LoadPrefClicked = function(caller,value)
    local ContextEditor             = caller:GetOverlay();
    local ViewWidget                = ContextEditor.EditTarget;
	local WindowSettings            = ViewWidget:Ptr(1);
	local Preferences               = CurrentProfile().StorePreferences.Views[value];
	local InsertType                = value.."Settings"

	local manager_plugin=Root().Menus.ContextWindowManager;
	if(manager_plugin) then
		local manager_overlay=manager_plugin:CommandCall(caller);
		if(manager_overlay) then
			manager_overlay:InputSetTitle("Load Preference");
			manager_overlay:InputSetAdditionalParameter("Mode", "Load");
			manager_overlay:InputSetAdditionalParameter("InsertType", InsertType);
			local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
			ObjectGrid.AllowAddNewLine = false;
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
	local InsertType                = value.."Settings"

	local manager_plugin=Root().Menus.ContextWindowManager;
	if(manager_plugin) then
		local manager_overlay=manager_plugin:CommandCall(caller);
		if(manager_overlay) then
			manager_overlay:InputSetTitle("Save Preference");
			manager_overlay:InputSetAdditionalParameter("Mode", "Save");
			manager_overlay:InputSetAdditionalParameter("InsertType", InsertType);
			local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
			ObjectGrid.AllowAddNewLine = true;
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

signalTable.SetDatapoolVisibility = function(caller)
    local ContextEditor = caller:GetOverlay();
    local ViewWidget    = ContextEditor.EditTarget;
	local TargetPool    = ViewWidget.UIWindow.PoolObject

	caller.visible = (TargetPool:FindParent("Pool") ~= nil)
end