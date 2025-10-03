local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function ReduceFont(tgt)
	local CurrentDisplay = tgt:GetDisplay();
	local DisplayIndex = CurrentDisplay:Index();

	if (DisplayIndex == 6 or DisplayIndex == 7) then
		for _,child in ipairs(tgt:Children()) do
			if (child:IsClass("PropertyInput") or child:IsClass("SwipeButton")) then
				child.Font = "Regular9";
				child.LabelAreaHeight = 10;
			end
		end
	end
end

local function UpdateRecipeGrid(cue_grid)
	local ui_parent=cue_grid:Parent();
	local recipe_grid=ui_parent.RecipeFrame.RecipeGrid;
	if ui_parent.RecipeFrame.Visible == true then
		local selColumn = tonumber(cue_grid.SelectedColumn);
		local row_id = 0
		if selColumn ~= nil and selColumn >= 4294967296 then
			--this is track sheet data actually
			row_id = cue_grid:GridGetParentRowId(row_id);
		end
		local selection = cue_grid:GridGetSelectedCells()
		if not selection then
			selection = {}
		end
		local selected_objects = {}
		for i=1,#selection,1 do
			local row_id = selection[i].r_UniqueId
			local column_id = selection[i].c_UniqueId
			if selColumn == column_id then
				if column_id ~= nil and column_id >= 4294967296 then
					--this is track sheet data actually
					row_id = cue_grid:GridGetParentRowId(row_id);
				end
				local object = IntToHandle(row_id);
				if IsObjectValid(object) then
					if (object:IsClass("Cue")) then
						object=object:Ptr(1);
					end
					selected_objects[#selected_objects + 1] = object
				end
			end
		end
		
		recipe_grid:Set("TargetObjects", selected_objects, Enums.ChangeLevel.None)
		local new_line = #selected_objects <= 1
		recipe_grid.EditAllowedAdd = new_line
		recipe_grid.AllowAddNewLine = new_line
		recipe_grid.AllowAddContent = new_line
		recipe_grid:GridGetData().ShowParentAsHintForMultiTarget = not new_line
		if #selected_objects > 0 then
			local settings=recipe_grid:GridGetSettings();
			local columnFilter = settings:Ptr(1):Ptr(1)
			if columnFilter.Preset ~= selected_objects[1] then
				columnFilter.Preset = selected_objects[1];
			end
		end
	end
end

local function UpdateSettingsContent(editor)
	local editTarget = editor.EditTarget;
	if(editTarget) then
		local tab = editor.Frame.Settings;
		local placeholder = tab.ObjectSettings;

		if(tab.visible) then
			local placeholderContent = nil;
			local rebuildPlaceholder = false;
			-- CHECK EXISTING:
			if (placeholder:GetUIChildrenCount() > 0) then
				placeholderContent = placeholder:GetUIChild(1);
			else
				rebuildPlaceholder = true;
			end
			
			if (tab.Visible) then
				if rebuildPlaceholder then
					placeholder.w, placeholder.h = "100%","100%"
					local settingsPluginName = "SequenceSettings";
					assert(Root().Menus[settingsPluginName],"Settings not found: "..tostring(settingsPluginName))
					placeholderContent = Root().Menus[settingsPluginName]:CommandCall(editor);
				end

				if (placeholderContent) then
					placeholderContent.Target = editTarget;
					ReduceFont(placeholderContent);
				else
					ErrEcho("Could not import sequence settings ui");
				end
			end
		else
			editor.Frame.Settings.ObjectSettings:ClearUIChildren();
		end
	else
	   ErrEcho("Edit target not found");
	end
end

local function SetMasksTarget(caller,MaskContainer,settings)
	local filteredSheetSettingsFilterCollect = settings.FilteredSheetSettingsFilterCollect
	MaskContainer.Mask1.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(1)
	MaskContainer.Mask2.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(2)
	MaskContainer.Mask3.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(3)
	MaskContainer.Mask4.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(4)
	MaskContainer.Mask5.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(5)
	MaskContainer.Mask6.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(6)
	MaskContainer.Mask7.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(7)
	MaskContainer.Mask8.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(8)
	MaskContainer.Mask9.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(9)
	MaskContainer.Mask10.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(10)
	MaskContainer.Mask11.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(11)
	MaskContainer.Mask12.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(12)
	MaskContainer.Mask13.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(13)
	MaskContainer.Mask14.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(14)
	MaskContainer.Mask15.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(15)
	MaskContainer.Mask16.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(16)
end

local function OnSettingsChanged(obj, change, ctx)
	local Frame=ctx.Frame;
	Frame.Cue.RecipeFrame.Visible=obj.ShowRecipes;
	Frame.Cue.NotesFrame.Visible=obj.ShowNotes;
	Frame.Cue.Toolbars.LayerToolbar.Visible = obj.ShowLayerToolbar;
	if obj.ShowRecipes then
		UpdateRecipeGrid(Frame.Cue.SequenceGrid)
	end
	
	SetMasksTarget(obj, ctx.TitleBar.TitleButtons, obj);
	if (obj.TrackSheet) then
		Frame.Cue.Toolbars.MaskToolbar.Visible=obj.ShowMaskToolbar;
	else
		Frame.Cue.Toolbars.MaskToolbar.Visible=false;
	end
end

signalTable.SetMaskTarget = function(caller,status,creator)
	local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings;
	SetMasksTarget(caller, caller, settings)
end

local function OnMainGridSelectionChanged(obj, change, ctx)
	UpdateRecipeGrid(ctx);
end

local function NoToIndex(obj)
	if obj.no ~= nil and type(obj.no) == "number" then
		local index = tostring(obj.no / 1000);
		return index:gsub("%.?0+$", "");
	elseif obj.Index ~= nil and type(obj.Index) == "number" then
		local index = obj.Index;
		return index:gsub("%.?0+$", "");
	end
	return "";
end

local function OnFilterSettingsChanged(obj, change, ctx)
	ctx.Frame.Cue.SequenceGrid:Changed()

	
	local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings;
	if (settings.TrackSheet) then
		ctx.Frame.Cue.Toolbars.MaskToolbar.Visible=settings.ShowMaskToolbar;
	else
		ctx.Frame.Cue.Toolbars.MaskToolbar.Visible=false;
	end
end

signalTable.OnLoaded = function(caller,status,creator)
	if not IsObjectValid(caller) then return; end
	local dispCollect = caller:Parent():Parent():Parent()
	local EditBar = dispCollect:FindRecursive("","SequenceEditBar")
	if(EditBar ~= nil) then	
		EditBar.LinkedObject = caller
	end
	caller.TitleBar.Settings.Target = caller:GetOverlay();;

	caller:WaitInit()
	coroutine.yield({ui=1})

	local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings;
	if (settings) then
		HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
		HookObjectChange(OnFilterSettingsChanged, settings:Ptr(1):Ptr(1), my_handle:Parent(), caller);
		OnSettingsChanged(settings, nil, caller);

		local cue_grid = caller.Frame.Cue.SequenceGrid
		local grid_sel = cue_grid:GridGetSelection();
		HookObjectChange(OnMainGridSelectionChanged, grid_sel, my_handle:Parent(), cue_grid);
		UpdateRecipeGrid(cue_grid);

		local buttonsBar = caller.TitleBar.TitleButtons;
		if (buttonsBar) then
			buttonsBar.WindowSettings = settings;

			-- Set target of every child
			for _,child in ipairs(buttonsBar:Children()) do
				if (IsObjectValid(child) and child.Property) then
					child.Target = settings;
				end
			end

			buttonsBar.Visible = true;
		end
	end

	signalTable.OnEditTargetChanged(caller)
	signalTable.OnGenericEditLoaded(caller,status,creator);

end

signalTable.OnEditTargetChanged = function(caller)
	UpdateSettingsContent(caller)
	local SequenceGrid = caller.Frame.Cue.SequenceGrid;
	if SequenceGrid then
		SequenceGrid.TargetObject = caller.EditTarget;
	end

	local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings;
	SetMasksTarget(caller, caller.TitleBar.TitleButtons, settings);
end

signalTable.SetRecipeSettings = function(caller,status,creator)
	if not IsObjectValid(caller) then return; end
    local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings.RecipeSheetSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.RecipeGrid.ExternalSettings = settings;
end

signalTable.OnRowSelected = function(caller,status,row_id)
	local ui_parent=caller:Parent();
	local selColumn = tonumber(caller.SelectedColumn);
	if selColumn ~= nil and selColumn >= 4294967296 then
		--this is track sheet data actually
		row_id = caller:GridGetParentRowId(row_id);
	end

	local object = IntToHandle(row_id);
	local notesHeader = ui_parent.NotesFrame.NotesHeader;
	if (IsObjectValid(object)) then
		local cueObj = nil;
		local partObj = nil;
		local hasMoreParts = false;
		if (object:IsClass("Part") ) then
			cueObj = object:Parent();
			partObj = object;
		elseif (object:IsClass("Cue")) then
			cueObj = object;
			partObj = object:Ptr(1);
			object=object:Ptr(1);
			hasMoreParts = cueObj:Count() > 1;
		end

		if (cueObj and partObj) then
			-- Naming scheme "Cue 1 : Part 1" or with custom labels "Cue 1 'MyCue' : Part 1 'MyPart'"
			local cueNameFromObject = cueObj.Name;
			local partNameFromObject = partObj.Name;
			local cueNameFromIndex = "Cue " .. NoToIndex(cueObj);
			local partNameFromIndex = "Part " .. partObj.index;

			if (cueNameFromObject == "CueZero" or cueNameFromObject == "OffCue") then
				notesHeader.Text = "Note for " .. cueNameFromObject;
			elseif (partObj.Part == 0) then -- Selection is cue
				if (cueNameFromObject == cueNameFromIndex and hasMoreParts) then
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " : " .. partNameFromIndex;
				elseif (hasMoreParts) then
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex;
				elseif (cueNameFromObject == cueNameFromIndex) then
					notesHeader.Text = "Note for " .. cueNameFromIndex;
				else
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "'";
				end
			else
				if (cueNameFromObject == cueNameFromIndex and partNameFromObject == partNameFromIndex) then
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " : " .. partNameFromIndex;
				elseif (cueNameFromObject == cueNameFromIndex and partNameFromObject ~= partNameFromIndex) then
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " : " .. partNameFromIndex .. " '" .. partNameFromObject .. "'";
				elseif (cueNameFromObject ~= cueNameFromIndex and partNameFromObject == partNameFromIndex) then
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex;
				else
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex .. " '" .. partNameFromObject .. "'";
				end
			end
		end
	end

	--[[local recipe_grid=ui_parent.RecipeFrame.RecipeGrid;
	recipe_grid.TargetObject=object;

	local settings=recipe_grid:GridGetSettings();
	local columnFilter = settings:Ptr(1):Ptr(1)
	if columnFilter:GetClass() == "PresetSheetFilter" then
		columnFilter.Preset = object;
	end
	]]

 	caller:SelectionChanged(row_id);
end

signalTable.OnSettingsButtonClicked = function(caller,dummy,target)
	ed = caller:GetOverlay();
	local editor = caller:Parent():Parent()
	if (ed.ShowFullSettings) then
		editor.Frame.Cue.Visible = false
		editor.Frame.Settings.Visible = true
	else
		editor.Frame.Cue.Visible = true
		editor.Frame.Settings.Visible = false
	end
	editor.TitleBar.TitleButtons.Visible = editor.Frame.Cue.Visible
	editor.TitleBar.SettingsButtons.Visible = editor.Frame.Settings.Visible
	UpdateSettingsContent(editor)
end

signalTable.OnSaveToDefault = function(caller)
	local editor = caller:GetOverlay();
	local pbPlaceholder = editor.Frame.Settings.ObjectSettings;
	local objectSettingsUI = pbPlaceholder:GetUIChild(1);
	objectSettingsUI.SaveToDefault();
end

signalTable.OnLoadFromDefault = function(caller)
	local editor = caller:GetOverlay();
	local pbPlaceholder = editor.Frame.Settings.ObjectSettings;
	local objectSettingsUI = pbPlaceholder:GetUIChild(1);
	objectSettingsUI.LoadFromDefault();
end

signalTable.SetSettingsAsTarget = function(caller,status,creator)
	local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings;
	caller.Target = settings;
end

