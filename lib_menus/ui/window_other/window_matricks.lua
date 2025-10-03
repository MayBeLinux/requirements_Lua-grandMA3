local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local ObjectsWithMatricksTarget = {};
local columnCount = 0;
local editTarget = nil;
local editTargetList = nil;
local TargetListOwner = nil;

function signalTable.WindowLoadedGeneric(editTarget,SettingsObj,InnerGrid, TitleButtons, window)

	InnerGrid.ToolBarDirection.XDir.Target = SettingsObj;
	InnerGrid.ToolBarDirection.YDir.Target = SettingsObj;
	InnerGrid.ToolBarDirection.ZDir.Target = SettingsObj;

	if TitleButtons.Grid then TitleButtons.Grid.Target = SettingsObj; end
	if TitleButtons.Shuffle then TitleButtons.Shuffle.Target = SettingsObj; end
	if TitleButtons.Layers then TitleButtons.Layers.Target = SettingsObj; end
	if TitleButtons.EnableX then TitleButtons.EnableX.Target = SettingsObj; end
	if TitleButtons.EnableY then TitleButtons.EnableY.Target = SettingsObj; end
	if TitleButtons.EnableZ then TitleButtons.EnableZ.Target = SettingsObj; end
	signalTable.SettingsChanged(SettingsObj, nil, window, InnerGrid);

	if(editTarget ~= nil) then
	    local FunctionButtons=InnerGrid.FunctionGrid.FunctionButtons;

		FunctionButtons.Layers.AdaptiveSpeed.Visible = false;
		FunctionButtons.Layers.AdaptiveWidth.Visible = false;

		FunctionButtons.Shuffle.Selection1.Visible = false;
		FunctionButtons.Shuffle.Selection2.Visible = false;
		FunctionButtons.Shuffle.Selection3.Visible = false;
		FunctionButtons.Shuffle.Shuffle1.Texture = "corner5";

		local addr   = ToAddr(editTarget);
		if TitleButtons.ResetBtn then TitleButtons.ResetBtn.SignalValue = "Reset " .. addr; end

		if editTarget:IsClass("Preset") then
			FunctionButtons.Shuffle.Shuffle1.Visible = false;
			FunctionButtons.Shuffle.Shuffle2.Visible = false;
			FunctionButtons.Shuffle.Visible = false;
		end
	end
end

function signalTable:WindowLoaded(caller,status,creator)
    local SettingsObj;
	
	editTarget = caller.editTarget;
	if(editTarget ~= nil) then
		if editTarget:GetClass() == "Group" then
			
		end
		signalTable.ActiveSelectionChanged(caller,status,caller);
	end

	if(caller:GetOverlay()) then -- Overlay
		SettingsObj	= CurrentProfile().TemporaryWindowSettings.MatricksWindowSettings;
	else -- Window
		SettingsObj = caller.WindowSettings;
	end

	local Matrick = Selection()

	HookObjectChange(signalTable.ActiveSelectionChanged,	-- 1. function to call
					 CurrentEnvironment(),				    -- 2. object to hook
					 my_handle:Parent(),					-- 3. plugin object ( internally needed )
					 caller);								-- 4. user callback parameter 

	local InnerGrid = caller.Frame.InnerGrid;
	local TitleButtons = caller.Title.TitleButtons;

	if(editTarget ~= nil and editTarget:GetClass() == "Group") then
		SettingsObj.EnableLayers = false
		if (TitleButtons ~= nil) then
			if TitleButtons.Layers then TitleButtons.Layers.Visible = false; end
		end
	end

	local OnSettingsChanged = function(obj, chlvl, ctx) signalTable.SettingsChanged(obj, chlvl, ctx, InnerGrid) end

    HookObjectChange(OnSettingsChanged, SettingsObj, my_handle:Parent(), caller);

	signalTable.WindowLoadedGeneric(editTarget, SettingsObj, InnerGrid, TitleButtons, caller);

	HookObjectChange(signalTable.OnWindowChanged, caller, my_handle:Parent(), InnerGrid);

	local RecipeEditor=CurrentEnvironment().RecipeEditor
	HookObjectChange(signalTable.RecipeEditingHook,RecipeEditor,my_handle:Parent(),caller);
	signalTable.RecipeEditingHook(RecipeEditor,my_handle:Parent(),caller)
end

-- ------------------------------------------
signalTable.OnWindowChanged = function(window, chlvl, InnerGrid)
	if(window ~= nil and window.Frame ~= nil) then -- not when closing the window -- it is no longer fully existing
		if(columnCount > 0) then
			local widthString = InnerGrid.TopContainer.W;
			widthString = widthString:gsub('%d*%.%d*%%%(',"");
			widthString = widthString:gsub("%)","");
			local newWidth = tonumber(widthString) - 5;
			widthString = tostring(newWidth);
		
			InnerGrid.TopContainer.TopBox.TopGrid.W = widthString;
			InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.W = widthString;
			InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.W = widthString;
			InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.W = widthString;

			InnerGrid.FunctionGrid.FunctionButtons.W = widthString;
		end
	end
end
-- ------------------------------------------
signalTable.SettingsChanged = function(SettingsObj, changeLevel, window, InnerGrid)
	columnCount = 0;
    if(SettingsObj.EnableX) then
        InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Visible  = true;
	else
	    InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Visible  = false;
	end

    if(SettingsObj.EnableY) then
        InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Visible  = true;
	else
	    InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Visible  = false;
	end

    if(SettingsObj.EnableZ) then
        InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Visible  = true;
	else
	    InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Visible  = false;
	end

	if(SettingsObj.EnableGrid) then
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Grid.Visible = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Grid.Visible = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Grid.Visible = true;
		InnerGrid.FunctionGrid.FunctionButtons.Invert.Visible					     = true;
		columnCount = columnCount+1;
	else
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Grid.Visible = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Grid.Visible = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Grid.Visible = false;
		InnerGrid.FunctionGrid.FunctionButtons.Invert.Visible					     = false;
    end

	if(SettingsObj.EnableInvert == false) then
		InnerGrid.FunctionGrid.FunctionButtons.Invert.Visible					     = false;
    end

	if(SettingsObj.EnableShuffle) then
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Shuffle.Visible	 = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Shuffle.Visible	 = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Shuffle.Visible	 = true;
		InnerGrid.FunctionGrid.FunctionButtons.Shuffle.Visible					     = true;
		columnCount = columnCount+1;
	else
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Shuffle.Visible	 = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Shuffle.Visible	 = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Shuffle.Visible	 = false;
		InnerGrid.FunctionGrid.FunctionButtons.Shuffle.Visible					     = false;
    end

	if(SettingsObj.EnableLayers) then
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Layers.Visible	 = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Layers.Visible	 = true;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Layers.Visible	 = true;
		InnerGrid.FunctionGrid.FunctionButtons.Layers.Visible = true;
		columnCount = columnCount+1;
	else
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionX.Layers.Visible	 = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionY.Layers.Visible	 = false;
		InnerGrid.TopContainer.TopBox.TopGrid.DirectionZ.Layers.Visible	 = false;
		InnerGrid.FunctionGrid.FunctionButtons.Layers.Visible = false;
    end

	local showShuffle = InnerGrid.FunctionGrid.FunctionButtons.Shuffle.Visible;
	if editTarget and editTarget:IsClass("Preset") then
		showShuffle = false;
	end

	if(InnerGrid.FunctionGrid.FunctionButtons.Invert.Visible == true or showShuffle == true or InnerGrid.FunctionGrid.FunctionButtons.Layers.Visible == true) then
		InnerGrid.FunctionGrid.Visible = true;
	else
		InnerGrid.FunctionGrid.Visible = false;
	end

	if (SettingsObj.ToolbarDisable == true) then
		InnerGrid.ToolBarDirection.Visible = false
	end

	signalTable.OnWindowChanged(window, nil, InnerGrid);
end

signalTable.RecipeEditingHook = function(HookObj,status,caller)
	if caller:GetClass() == "GenericEditor" then
		return;
	end

	local RecipeEditor=CurrentEnvironment().RecipeEditor

	local recipeEdit = false;
	if RecipeEditor.RecipeEditing and #RecipeEditor.TargetRecipes > 0 then
		editTargetList = RecipeEditor.TargetRecipes
		TargetListOwner = RecipeEditor
		recipeEdit = true
	else
		editTargetList = nil
		TargetListOwner = nil
	end

	-- in Recipe Edit mode, the Editor should only work for Recipes
	caller.Frame.InnerGrid.OnlyForRecipeWarning.Visible = RecipeEditor.RecipeEditing and not recipeEdit
	
	-- adjust targets:
	signalTable.ActiveSelectionChanged(CurrentEnvironment(),my_handle:Parent(),caller)

	-- adjust icon:
	if caller.Name == "MatricksOverlay" then
		caller.Title.TitleBtn.Icon = recipeEdit and "cooking" or "object_matricks"
		caller.Title.TitleBtn.IconColor = recipeEdit and "RecipeEditing.Active" or "Button.Icon"
	end

	-- adjust enabled state:
	if caller.Title.TitleButtons.Active then
		caller.Title.TitleButtons.Active.Enabled = not recipeEdit;
	end
	if caller.Title.TitleButtons.Reset then
		caller.Title.TitleButtons.Reset.Enabled = not recipeEdit;
	end

	caller.Frame.InnerGrid.ToolBarDirection.XRange.Enabled = not recipeEdit;
	caller.Frame.InnerGrid.ToolBarDirection.YRange.Enabled = not recipeEdit;
	caller.Frame.InnerGrid.ToolBarDirection.ZRange.Enabled = not recipeEdit;
end


signalTable.ActiveSelectionChanged = function(caller,status,window)
	local sel = Selection();
	local target = sel;
	if(editTarget ~= nil) then
		target = editTarget;
	end

	for i, Object in pairs(ObjectsWithMatricksTarget) do
		if editTargetList and Object.Target ~= TargetListOwner then
			Object.Target = TargetListOwner;
		elseif (Object.Target ~= target) then
			Object.Target = target;
		end
	end
end

function signalTable:UpdateMatricksUIWithEditTarget(tgt, innerGrid, titleButtons, window, settingsObj)
	editTarget = tgt;
	if(editTarget ~= nil) then
		signalTable.ActiveSelectionChanged(window,status,window);
	end
	signalTable.WindowLoadedGeneric(editTarget, settingsObj, innerGrid, titleButtons, window);
end

function signalTable:SetMatricksTarget(caller,status,creator)
	if editTargetList ~= nil then
		caller.Target = TargetListOwner;
	elseif(editTarget ~= nil) then
		caller.Target = editTarget;
	else
		caller.Target = Selection();
	end
	ObjectsWithMatricksTarget[#ObjectsWithMatricksTarget+1] = caller;
end

signalTable.AdaptiveSpeed = function()
 	CmdIndirect("At Measure 1 /Auto")
end

signalTable.AdaptiveWidth = function()
 	CmdIndirect("At Width 100 /Auto");
end

signalTable.CopyActiveSel = function()
	local UserEnvironment  =CurrentEnvironment();
	local active_index = UserEnvironment.ActiveSelIndex;
	local back_index   = (active_index) % 2 + 1;
	CmdIndirect("copy Selection " .. active_index .. " at " .. back_index);
end


signalTable.CopyValues = function()
	local UserEnvironment  =CurrentEnvironment();
	local active_index = UserEnvironment.ActiveSelIndex;
	local back_index   = (active_index) % 2 + 1;
	CmdIndirect("Clone Selection " .. back_index  .. " at Selection " .. active_index .. " if Programmer /Overwrite" );
end

function signalTable:ReduceFont(tgt)
	local CurrentDisplay = tgt:GetDisplay();
	local DisplayIndex = CurrentDisplay:Index();

	if (DisplayIndex == 6 or DisplayIndex == 7) then
		for _,child in ipairs(tgt:Children()) do
			if (child:IsClass("Button")) then
				child.Font = "Regular14";
				if(child:IsClass("PropertyControl")) then
					child.LabelAreaHeight = 10;
				end
			end
		end
	end
end

signalTable.OnDoShuffle = function()
	if(editTarget ~= nil) then
		editTarget:DoShuffle();
	else
		Cmd("Shuffle");
	end
end

local swapTable={};
swapTable["FadeFromX"]  = { enum="TimeNoneSwapFade" , value="Swap Fade"}
swapTable["DelayFromX"] = { enum="TimeNoneSwapDelay", value="Swap Delay"}
swapTable["SpeedFromX"] = { enum="TimeNoneSwapSpeed", value="Swap Speed"}
swapTable["PhaseFromX"] = { enum="PhaseValueNone"     , value="Swap Phase"}
swapTable["FadeFromY"]  = { enum="TimeNoneSwapFade" , value="Swap Fade"}
swapTable["DelayFromY"] = { enum="TimeNoneSwapDelay", value="Swap Delay"}
swapTable["SpeedFromY"] = { enum="TimeNoneSwapSpeed", value="Swap Speed"}
swapTable["PhaseFromY"] = { enum="PhaseValueNone"	   , value="Swap Phase"}
swapTable["FadeFromZ"]  = { enum="TimeNoneSwapFade" , value="Swap Fade"}
swapTable["DelayFromZ"] = { enum="TimeNoneSwapDelay", value="Swap Delay"}
swapTable["SpeedFromZ"] = { enum="TimeNoneSwapSpeed", value="Swap Speed"}
swapTable["PhaseFromZ"] = { enum="PhaseValueNone" 	   , value="Swap Phase"}

signalTable.OnInvertValues = function(caller, value)
	local target = caller:Parent()[value].Target;
	if(target ~= nil) then
		local entry = swapTable[value];
		local enum = Enums[entry.enum][entry.value];
		local cmd = "Set " .. ToAddr(target) .. " Property '" .. value .. "' " .. tostring(enum);
		CmdIndirect(cmd);
	end
end
