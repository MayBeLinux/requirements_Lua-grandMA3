local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.SetRecipeSettings = function(caller,status,creator)
	local settings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.RecipeGrid.ExternalSettings = settings;
end

signalTable.SetPresetRecipeSettings = function(caller,status,creator)
	local settings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.PresetRecipes.ExternalSettings = settings;
end

signalTable.OnPresetRecipeRowSelected = function(caller,status,row_id)
  local ui_parent=caller:Parent();
  local object = IntToHandle(row_id);

  local o = caller:GetOverlay()
  local recipeButtonsActive = false;
  if IsObjectValid(object) then
	local isRecipe = object:IsClass("Recipe")
	local hasRecipes = object:Count() > 0
	if isRecipe or not hasRecipes then
		signalTable:PresetUpdateMatrickUI(o, object)
	else
		signalTable:PresetUpdateMatrickUI(o, nil)
	end

	if object:IsClass("Recipe") then
		recipeButtonsActive = true;
	end
  else
	recipeButtonsActive = true;
  end
  local recipeBtnTypes = {
  	{class="MainDlgDelButton"},
  	{class="MainDlgCutButton"},
  	{class="MainDlgCopyButton"},
  	{class="MainDlgPasteButton"},
  	{name="CookBtn"},
  	{name="TakeSelectionBtn"},
	{class="MainDlgInsertButton"}
  }

  --[[if not IsObjectValid(object) or object:IsClass("Recipe")  then
		recipeBtnTypes[#recipeBtnTypes + 1] = {class="MainDlgInsertButton"};
  end]]
  
  for i,v in ipairs(recipeBtnTypes) do
  	local btn = o:FindRecursive(v.name, v.class)
  	if btn ~= nil then 
  		if btn:Get("AutoEnabled") ~= nil then btn.AutoEnabled = recipeButtonsActive; end
  		btn.Enabled = recipeButtonsActive;
  	end
  end

  if recipeButtonsActive then
	  local btn = o:FindRecursive('CookBtn')
	  if IsObjectValid(btn) then
		local p = object:Parent()
		btn.Enabled = not p.RecipeTemplate
	  end
  end

  local btn = o:FindRecursive("EditBtn", "IndicatorButton")
  if btn ~= nil then 
	if IsObjectValid(object) then
		local nm = "Edit"
		nm = nm.." "..object:GetClass()
		if object:GetClass() == "Recipe" then nm = nm .. " "..object:Index() end
		btn.Text = nm
		btn.Enabled = true
	else
		btn.Text = "Edit"
		btn.Enabled = false
	end
  end
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame.MAtricks.PresetRecipes.TargetObject=target;
end

signalTable.OnListReference = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.OnRecast = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("Recast "..addr); end
end

signalTable.OnCook = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	CmdIndirect("Cook "..addr);
end

signalTable.OnCleanup = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	CmdIndirect("Cleanup /Type='Recipe' "..addr);
end

signalTable.OnTune = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local p = editor.EditTarget
	local addr   = ToAddr(p);
	CmdIndirect("Move "..addr.." At "..addr..".1");
end

signalTable.OnEditMatricks = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("Edit "..addr.." /Type 'MAtrick'" ); end
end

signalTable.OnTakeSelection = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local grid = editor.Frame.MAtricks.PresetRecipes
	local object = IntToHandle(grid.SelectedRow);
	local addr   = ToAddr(object);
	if(addr) then CmdIndirect("Store "..addr.." /Selection /PhaserData 'No' /Matricks 'No'" ); end
end

signalTable.OnAT = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("AT "..addr); end
end


signalTable.OnEdit = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local grid = editor.Frame.MAtricks.PresetRecipes
	local object = IntToHandle(grid.SelectedRow);
	local addr   = ToAddr(object);
	if(addr) then CmdIndirect("Edit "..addr); end
end

signalTable.OnResetSelected = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local grid = editor.Frame.MAtricks.PresetRecipes
	local object = IntToHandle(grid.SelectedRow);
	local addr   = ToAddr(object);
	if(addr) then CmdIndirect("Reset "..addr); end
end

local function PrepareMatricksSettings(RealSettings, updateSettings)
	local res = {}
	local presetSettings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings
	local columnFilter = presetSettings:Ptr(1):Ptr(1)
	if columnFilter ~= nil then
		local set_if = function(bit, val)
			if columnFilter:Get("Bits", nil, bit) == 1 then
				return val
			else
				return false
			end
		end

		res.EnableX = set_if(7, true)
		res.EnableY = set_if(8, true)
		res.EnableZ = set_if(9, true)
		res.EnableGrid = set_if(5, true)
		res.EnableInvert = set_if(5, true)
		res.EnableLayers = set_if(4, true)
		res.EnableShuffle = set_if(10, true);
		res.ToolbarDisable = true
		if(updateSettings == true) then
			RealSettings.EnableGrid = true;
			RealSettings.EnableLayers = true;
			RealSettings.EnableShuffle = true;
		end
	else
		res = RealSettings;
	end
	return res
end

signalTable.PresetSettingsChanged = function(SettingsObj, Plugin, window)
	local InnerGrid = window.Frame.MAtricks.MAtricksSplit.InnerGrid;
	signalTable.SettingsChanged(PrepareMatricksSettings(SettingsObj, false), my_handle:Parent(), window, InnerGrid);
end

signalTable.PresetColumnFilterChanged = function(FilterObj, Plugin, window)
	local InnerGrid = window.Frame.MAtricks.MAtricksSplit.InnerGrid;
    local SettingsObj = CurrentProfile().TemporaryWindowSettings.MatricksWindowSettings;
	signalTable.SetMAtrickSplitMinHeight(window);
	signalTable.SettingsChanged(PrepareMatricksSettings(SettingsObj, true), my_handle:Parent(), window, InnerGrid);
end

signalTable.SetMAtrickSplitMinHeight = function(window)
	local presetSettings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings;
	local columnFilter = presetSettings:Ptr(1):Ptr(1);
	if columnFilter ~= nil then
		local matricksActive = columnFilter:Get("Bits", nil, 5) == 1;
		local invertActive = columnFilter:Get("Bits", nil, 6) == 1;
		if matricksActive and invertActive then
			window.Frame.MAtricks.MAtricksSplit.MinSize = 330;
		else
			window.Frame.MAtricks.MAtricksSplit.MinSize = 280;
		end
	end
end

local function UpdatePresetEditorUI(preset, changeLevel, main)
	local matricksAllowed = true;--((preset.OwnDataPresent and preset:Count() == 0) or preset.OwnNonCookedDataPresent) or preset:IsClass("Recipe");
	local recipesAllowed = false; --not matricksAllowed or (preset:Count() > 0);

	local btnTune = main:FindRecursive("TuneBtn", "IndicatorButton")
	local recipeCnt = preset:Count()
	if btnTune ~= nil then
		btnTune.Enabled = recipeCnt == 0
	end

	local recipeGrid = main:FindRecursive("PresetRecipes", "DBObjectGrid")
	local canHaveRecipes = (recipeCnt > 0) or ((not preset.OwnDataPresent) and (not preset.HasAnyMatricksData))
	--AllowAddNewline cannot work atm
	local presetSettings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings
	presetSettings:Ptr(2).AllowAddNewline = canHaveRecipes;

	local columnFilter = presetSettings:Ptr(1):Ptr(1)
	columnFilter.Preset = preset;

	local canAddTargets = recipeCnt == 0
	recipeGrid.AddTargets = canAddTargets;
	recipeGrid:Changed()

  	local btn = main:FindRecursive("CookBtn")
	if IsObjectValid(btn) then
		btn.Enabled = not preset.RecipeTemplate
	end
end

function signalTable:PresetUpdateMatrickUI(window, tgt)
    local SettingsObj = CurrentProfile().TemporaryWindowSettings.MatricksWindowSettings;

	local InnerGrid = window.Frame.MAtricks.MAtricksSplit.InnerGrid;
	local TitleButtons = window.TitleBar.MAtricksButtons;
	local modSettings = PrepareMatricksSettings(SettingsObj, true)
	signalTable:UpdateMatricksUIWithEditTarget(tgt, InnerGrid, TitleButtons, caller, modSettings)
	signalTable.SettingsChanged(modSettings, my_handle:Parent(), window, InnerGrid);
end

function signalTable:PresetWindowLoaded(caller,status,creator)
    local SettingsObj = CurrentProfile().TemporaryWindowSettings.MatricksWindowSettings;
	editTarget = caller.editTarget;

    HookObjectChange(UpdatePresetEditorUI, editTarget, my_handle:Parent(), caller);
	caller:WaitInit(2)
	UpdatePresetEditorUI(editTarget, nil, caller);
    HookObjectChange(signalTable.PresetSettingsChanged, SettingsObj, my_handle:Parent(), caller);

	local presetSettings = CurrentProfile().TemporaryWindowSettings.PresetEditorSettings
	local columnFilter = presetSettings:Ptr(1):Ptr(1)
	presetSettings.RowHeightFactor = 2
    HookObjectChange(signalTable.PresetColumnFilterChanged, columnFilter, my_handle:Parent(), caller);

	caller.TitleBar.Settings.Target = caller:GetOverlay();

	if editTarget:Count() == 0 then
		signalTable:PresetUpdateMatrickUI(caller, editTarget)
	end

	caller.TitleBar.MAtricksButtons.Visible = true;
	
	signalTable.SetMAtrickSplitMinHeight(caller);
end

signalTable.SettingsButtonsLoaded = function(caller, status, creator)
	HookObjectChange(signalTable.ShowSettingsChanged, CurrentProfile(), my_handle:Parent(), caller);
	signalTable.ShowSettingsChanged(caller, caller, caller)
end

signalTable.ShowSettingsChanged = function(FilterObj, Plugin, SettingsButtons)
	SettingsButtons.Visible = CurrentProfile().ShowSettingsInEditors
end
