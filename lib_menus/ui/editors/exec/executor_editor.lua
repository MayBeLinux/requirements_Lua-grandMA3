local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- ***************************************************
-- helpers:
-- ***************************************************

local function IsXKey(t)
	local idx = t.no;
	return ((idx >= 191) and (idx <= 198)) or ((idx >= 291) and (idx <= 298));
end

local function IsXKeyWithEncoder(t)
	local idx = t.no;
	return ((idx >= 291) and (idx <= 298));
end

local function IsSpecialExec(t)
	return (t:GetClass() == "SpecialExecutor");
end

local function ReduceFont(tgt)
	local CurrentDisplay = tgt:GetDisplay();
	local DisplayIndex = CurrentDisplay:Index();

	if (DisplayIndex == 6 or DisplayIndex == 7) then
		for _,child in ipairs(tgt:Children()) do
			if (child:IsClass("PropertyInput")) then
				child.Font = "Regular9";
				child.LabelAreaHeight = 10;
			end
		end
	end
end

local function SetLastTab(idx)
	CurrentProfile().TemporaryWindowSettings.ExecEditorSettings.LastTab = idx;
end

local function GetLastTab()
	return CurrentProfile().TemporaryWindowSettings.ExecEditorSettings.LastTab;
end

-- ***************************************************
-- Update Tab Visibility
-- ***************************************************

local function UpdateTabs(editor)
	local exec = editor.EditTarget;
	if not IsObjectValid(exec) then ErrEcho("Exec not valid"); return; end
	local obj = exec.object;
	local tabs = editor.PrimaryMenu.MainTabs;

	local function setTabEnabled(tabName, value)
		local idx = tabs:FindListItemByName(tabName);
		tabs:SetEnabledListItem(idx,value); 
	end
	local function changeTabValue(tabName,value)
		local idx = tabs:FindListItemByName(tabName);
		tabs:SetListItemValueStr(idx,value); 
	end
	local function toggleTab(tabName, tabValue, value)
		local idx = tabs:FindListItemByName(tabName);
		if idx and not value then
			tabs:RemoveListItem(tabName);
		elseif not idx and value then
			tabs:AddListStringItem(tabName,tabValue)
		end
	end

	if (IsXKey(exec)) then
		changeTabValue("Handle","HandleXKeys")
	elseif(IsSpecialExec(exec)) then
		changeTabValue("Handle","HandleSpecial")
	else
		changeTabValue("Handle","Handle")
	end

	if obj then
		setTabEnabled("Edit\nSetting",true);
		toggleTab("Edit","",obj:HasEditUI());
	else
		setTabEnabled("Edit\nSetting",false);
		toggleTab("Edit","",false);
	end
end

local function GetTabRequest(editor)
	local forcedTab = editor.ForcedInitialTab;
	local tabs = editor.PrimaryMenu.MainTabs;
	if forcedTab and forcedTab ~= "" then
		editor.ForcedInitialTab = ""
		if string.upper(forcedTab) == "LASTTAB" then
			return GetLastTab();
		elseif forcedTab == "EditSetting" then
			return "Edit\nSetting";
		elseif (forcedTab == "Edit" and not tabs:FindListItemByName("Edit")) then
			return "Edit\nSetting";
		end
		return forcedTab;
	end
	return nil
end

local function GetInitialTabName(editor)
	--require 'gma3_debug'()
	local exec = editor.EditTarget;
	local obj = exec.object;
	local tabs = editor.PrimaryMenu.MainTabs;
	local forcedTab = editor.ForcedInitialTab;
	if not obj then
		return "Object";
	end
	if forcedTab and forcedTab ~= "" then
		if string.upper(forcedTab) == "LASTTAB" then
			return GetLastTab();
		elseif forcedTab == "EditSetting" then
			return "Edit\nSetting";
		elseif (forcedTab == "Edit" and not tabs:FindListItemByName("Edit")) then
			return "Edit\nSetting";
		end
		return forcedTab;
	end
	return "Handle";
end

local function SelectTab(editor,tabName)
	local tabs = editor.PrimaryMenu.MainTabs;

	local idx = tabs:FindListItemByName(tabName);
	if idx and tabs:IsListItemEnabled(idx) then
		tabs:SelectListItemByIndex(idx);
		return true;
	else
		ErrEcho("selecting tab "..tostring(tabName).." failed.")
	end
end

local function CheckRefreshHandleContent(editor,exec)
	local tabs = editor.PrimaryMenu.MainTabs;
	local selIdx = tabs:GetListSelectedItemIndex();
	local selTabName = tabs:GetListItemName(selIdx);
	if (selTabName == "Handle") then
		-- force change:
		tabs:SelectListItemByIndex(0);
		SelectTab(editor,"Handle");
	end
end

local function CheckRefreshEditContent(editor,exec)
	local tabs = editor.PrimaryMenu.MainTabs;
	local selIdx = tabs:GetListSelectedItemIndex();
	local selTabName = tabs:GetListItemName(selIdx);
	if (selTabName == "Edit") then
		-- force change:
		tabs:SelectListItemByIndex(0);
		SelectTab(editor,"Edit");
	end
end

-- ***************************************************
-- Update Handles
-- ***************************************************

local function UpdateHandlesXKey(editor)
	local e = editor.EditTarget
	if e then
		local h = editor.Content.Dialogs.OverviewAndEditor.HandleXKeysContainer.HandleXKeys

		local withEncoder = IsXKeyWithEncoder(e);
		h:SetChildren("Target",e);
	end
end

local function UpdateHandlesSpecial(editor)
	local e = editor.EditTarget
	if e then
		local overviewAndEditor = editor.Content.Dialogs.OverviewAndEditor
		local h_special = editor.Content.Dialogs.OverviewAndEditor.HandleSpecialExec;

		overviewAndEditor.ExecRowLabel.Visible = false;
		overviewAndEditor.SpecialExecRowLabel.Visible = true;

		local specialVisibility = 
		{
			[Enums.SpecialExecutor.XFade1] 		= "Fader";
			[Enums.SpecialExecutor.XFade2] 		= "Fader";
			[Enums.SpecialExecutor.XFade1Btn] 	= "KnobAndButton";
			[Enums.SpecialExecutor.XFade2Btn] 	= "KnobAndButton";

			[Enums.SpecialExecutor.GrandKnob] 	= "Encoder";

			[Enums.SpecialExecutor.RateBtn1] 	= "Button";
			[Enums.SpecialExecutor.SpeedBtn1] 	= "Button";
			[Enums.SpecialExecutor.RateBtn2] 	= "WheelAndButton";
			[Enums.SpecialExecutor.SpeedBtn2] 	= "WheelAndButton";
			
			[Enums.SpecialExecutor.ExecEncoder]	= "EncoderAndButtons";
			-- [Enums.SpecialExecutor.ExecKey]		= "EncoderAndButtons";
			[Enums.SpecialExecutor.ExecBtn1] 	= "EncoderAndButtons";
			[Enums.SpecialExecutor.ExecBtn2] 	= "EncoderAndButtons";
			[Enums.SpecialExecutor.ExecBtn3] 	= "EncoderAndButtons";

			[Enums.SpecialExecutor.ProgEncoder]	= "EncoderAndButtons";
			-- [Enums.SpecialExecutor.ProgKey]		= "EncoderAndButtons";
			[Enums.SpecialExecutor.ProgBtn1] 	= "EncoderAndButtons";
			[Enums.SpecialExecutor.ProgBtn2] 	= "EncoderAndButtons";
			[Enums.SpecialExecutor.ProgBtn3] 	= "EncoderAndButtons";
		}
	end
end

-- ***************************************************
-- Update Settings Content
-- ***************************************************

local function UpdateSettingsContent(editor)
	local editTarget = editor.EditTarget;
	if(editTarget) then
		local obj=editTarget.Object;
		local tab = editor.Content.Dialogs.Settings;
		local placeholder = tab.ObjectSettings;
		if(obj and tab.visible) then
			local placeholderContent = nil;
			local rebuildPlaceholder = false;
			-- CHECK EXISTING:
			if (placeholder:GetUIChildrenCount() > 0) then
				placeholderContent = placeholder:GetUIChild(1);
				if placeholderContent.Target:GetClass() ~= obj:GetClass() then
					rebuildPlaceholder = true;
				end
			else
				rebuildPlaceholder = true;
			end
			
			if (tab.Visible) then
				if rebuildPlaceholder then
					-- type changed, we need to change placeholder
					placeholder.w, placeholder.h = "100%","100%"

					local settingsPluginName = obj:GetUISettings();
					if settingsPluginName then
						assert(Root().Menus[settingsPluginName],"Settings not found: "..tostring(settingsPluginName))
						placeholderContent = Root().Menus[settingsPluginName]:CommandCall(editor);
					else
						placeholderContent = Root().Menus.GenericSettings:CommandCall(editor);
					end

					if obj:GetClass() == "World" or obj:GetClass() == "Group" or obj:GetClass() == "Sound" or obj:GetClass() == "Quickey" then
						placeholder.w, placeholder.h = 600,400;
					end
				end

				if (placeholderContent) then
					placeholderContent.Target = obj;
					ReduceFont(placeholderContent);

					if placeholderContent:GetClass() == "EditorPropertyButtons" then
						placeholderContent.BigMode = true;
						placeholderContent.UseEditorTarget = "No" -- otherwise the change handling above doesnt work!
					end

				else
					ErrEcho("Could not import playback settings ui");
				end
			end
		else
			editor.Content.Dialogs.Settings.ObjectSettings:ClearUIChildren();
		end
	else
	   ErrEcho("Edit target not found");
	end
end

-- ***************************************************
-- Tab Change
-- ***************************************************

signalTable.ContentChange = function( caller,status,creator )
	local overlay = caller:GetOverlay()
	SetLastTab(caller.SelectedItemIdx);
	if caller.SelectedItemValueStr == "" --[[edit]] then
		overlay.Content.Dialogs.visible = false;
		overlay.MainDialog.visible = true;
		-- hide title buttons that are behind the new ones:
		overlay.TitleBar.LockBtn.visible = false;
		overlay.TitleBar.DisplayUserPreference.visible = false;
		overlay.TitleBar.ConfigButtons.ConfigControl.visible = false;
		overlay.TitleBar.ShowAppearancesBtn.visible = false;

		-- open assigned objects editor:
		local assignedObj = overlay.EditTarget.object;
		assert(assignedObj:HasEditUI(),"Trying to call Editor, but object has none.");
		local uiEditorName = assignedObj:GetUIEditor();
		local editor = overlay.SwitchMenuWithTarget(uiEditorName, assignedObj);

		-- modify assigned objects editor:
		if editor and IsObjectValid(editor) then
			local dispPref = editor:FindRecursive("DisplayUserPreference","DialogButton")
			if dispPref then
				-- change to me:
				dispPref.Name="DispPrefExecEditor"
				dispPref.Target = PluginVars(pluginName);
				dispPref.UseBaseOverlay="Yes";
			end

			local settings = editor:FindRecursive("Settings","IndicatorControl")
			if settings then
				settings.visible = false;
			end
		end
	else
		overlay.SwitchMenu("");
		overlay.Content.Dialogs.visible = true;
		overlay.MainDialog.visible = false;
		overlay.TitleBar.DisplayUserPreference.visible = true;
		overlay.TitleBar.ConfigButtons.ConfigControl.visible = true;
		if IsSpecialExec(overlay.editTarget) then
			overlay.TitleBar.ConfigButtons.ConfigControl.Visible = false
		end
		
		if (caller.SelectedItemValueStr == "Settings") then
			overlay.TitleBar.LockBtn.visible = false;
		else
			overlay.TitleBar.LockBtn.visible = true;
		end

		-- ensure deletion of assigned objects editor:
		local assignedObjEditor = overlay.MainDialog:GetUIChild(1);
		if assignedObjEditor then
			assignedObjEditor:CommandDelete();
		end
	end
end

signalTable.OnConfigQuickLoad = function(caller)
	local editor = caller:GetOverlay()
	LoadExecConfig(editor.EditTarget)
end

signalTable.OnConfigQuickSave = function(caller)
	local editor = caller:GetOverlay()
	SaveExecConfig(editor.EditTarget)
end

signalTable.OnConfigSelect = function(caller)
	local editor = caller:GetOverlay();
	local exec = editor.EditTarget;
	local execConfigPool = CurrentProfile().SelectedDataPool.Configurations;

	local managerPlugin = Root().Menus.ExecConfigLoadSaveDialog;
	if(managerPlugin)then
		local managerOverlay = managerPlugin:CommandCall(caller);
		if(managerOverlay)then
			managerOverlay:InputSetTitle("Load Executor Configuration");
			managerOverlay:InputSetAdditionalParameter("Mode", "LS");

			local objectGrid = managerOverlay.DialogFrame.ObjectGrid;
			if(objectGrid)then
				objectGrid.TargetObject = execConfigPool;
				local currentExecConfig = exec.ExecutorConfiguration;
				if(currentExecConfig)then
					local columnID = GetPropertyColumnId(currentExecConfig, "Name");
					objectGrid.SelectCell('', HandleToInt(currentExecConfig), columnID);
					local cells = objectGrid:GridGetSelectedCells();
					if cells ~= nil then
						objectGrid:GridScrollCellIntoView(cells[#cells]);
					end
				end

				local result = managerOverlay:InputRun();
				if(result)then
					local mode = managerOverlay.AdditionalArgs.Mode
					local resultHandle = StrToHandle(result.Value)
					if(resultHandle)then
						exec.ExecutorConfiguration = resultHandle;
						if(mode == "Load")then
							LoadExecConfig(exec)
						else
							SaveExecConfig(exec)
						end
					end
				end
			end
		end
	end
end

signalTable.OnLoadFromDefault = function(caller)
	local editor = caller:GetOverlay();
	local pbPlaceholder = editor.Content.Dialogs.Settings.ObjectSettings;
	local objectSettingsUI = pbPlaceholder:GetUIChild(1);
	objectSettingsUI.LoadFromDefault();
end

signalTable.OnSaveToDefault = function(caller)
	local editor = caller:GetOverlay();
	local pbPlaceholder = editor.Content.Dialogs.Settings.ObjectSettings;
	local objectSettingsUI = pbPlaceholder:GetUIChild(1);
	objectSettingsUI.SaveToDefault();
end

-- ***************************************************
-- change hooks:
-- ***************************************************

signalTable.OnHandleVisibilityChanged = function(caller,status,visible)
    local editor = caller:GetOverlay();
    editor.TitleBar.ConfigButtons.Visible = visible;
	editor.TitleBar.ShowAppearancesBtn.Visible = false;
end

signalTable.OnObjectTabVisibilityChanged = function(caller,status,visible)
	local editor = caller:GetOverlay();
	if(visible) then
		editor.TitleBar.ObjPools.Visible = true;
		caller.Selector:OnSetSelectorVisibility();
	else
		editor.TitleBar.ObjPools.Visible = false;
	end
end

signalTable.OnObjectSettingsVisibilityChanged = function(caller,status,visible)
	local editor = caller:GetOverlay();
	editor.TitleBar.SettingsButtons.Visible = visible;
	if (visible) then
		editor.Content.Dialogs.visible = true;
		UpdateSettingsContent(editor);
	end
end

signalTable.OnExecutorChanged = function(caller)
	local editor = caller:GetOverlay();
	HookObjectChange(signalTable.ExecHook, editor.EditTarget ,my_handle:Parent(),editor);
	signalTable.ExecHook(editor.EditTarget,nil,editor);

	CheckRefreshHandleContent(editor,editor.EditTarget);
	CheckRefreshEditContent(editor,editor.EditTarget);

	local tab = GetTabRequest(caller)
	local exec = editor.EditTarget
	local obj = exec.object
	if not obj then
		SelectTab(caller, "Object")
	elseif tab then
		SelectTab(caller, tab)
	end
end

signalTable.ExecHook = function(exec,signal,editor)
	UpdateTabs(editor);
	if not IsObjectValid(exec) then ErrEcho("Exec not valid"); return; end
	if IsXKey(exec) then
		UpdateHandlesXKey(editor);
	end
	if IsSpecialExec(exec) then
		UpdateHandlesSpecial(editor);
	end
	UpdateSettingsContent(editor);
	
	local ObjectAssigned = true 
	if not exec.object then
		ObjectAssigned = false
	end

	editor.TitleBar.LockBtn.Target = exec;
	local OaE = editor.Content.Dialogs.OverviewAndEditor
	local keyEventSel = OaE.Editor.KeyEventSelector

	if IsXKey(exec) then
		keyEventSel.MAPress.Enabled = false
		keyEventSel.MAUnpress.Enabled = false
	else
		keyEventSel.MAPress.Enabled = true
		keyEventSel.MAUnpress.Enabled = true
	end

	local locked = (exec.Lock == "")
	local functionEditor = OaE.Editor
	local sizeEditXKey = OaE.HandleXKeysContainer.HandleXKeys.XKeySizeEdit
	local sizeEditExec = OaE.Handle.ExecSizeEdit
	functionEditor.Enabled = locked and ObjectAssigned

	-- set Exec Config Contorl Target
	local control = editor.TitleBar.ConfigButtons.ConfigControl
	control.Target = editor.EditTarget

	local resolutionControls = functionEditor.Resolution
	resolutionControls.Enabled = locked and ObjectAssigned

	functionEditor.CustomCommand.Enabled = locked and ObjectAssigned
	functionEditor.CustomCommandAddExec.Enabled = locked and ObjectAssigned
	functionEditor.UseCustomCommand.Enabled = locked and ObjectAssigned
end

signalTable.ExecEditorLoaded = function(caller)
	-- select correct tab
	UpdateTabs(caller);
	local tab = GetInitialTabName(caller)
	if tab then
		SelectTab(caller,tab);
	end
end

signalTable.SetEditorAsTarget = function(caller)
	local editor = caller:GetOverlay();
	caller.Target = editor
end
