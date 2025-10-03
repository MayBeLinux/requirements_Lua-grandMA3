local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function UpdateRecipeTarget(ctx)
	local mainGrid = ctx.Frame.SequenceGrid;
	signalTable.OnRowSelected(mainGrid, nil, mainGrid.SelectedRow);
end

local function UpdateRecipeGrid(cue_grid)
	local ui_parent=cue_grid:Parent();
	local recipe_grid=ui_parent.RecipeFrame.RecipeGrid;
	if recipe_grid:IsVisible() == true then
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

signalTable.SetMaskTarget = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;

	SetMasksTarget(caller, caller, settings)
end

local function OnSettingsChanged(obj, change, ctx)
	local titleButtons = ctx.TitleBar.TitleButtons;
	local stepControl = nil;
	local cueOnlyControl = nil;
	local maskToolbarControl = nil;
	--local valueReadoutControl = nil;
	if (titleButtons) then
		SetMasksTarget(obj, titleButtons, obj)
		stepControl = titleButtons.StepControl;
		--valueReadoutControl = titleButtons.ValueReadoutControl;
		cueOnlyControl = titleButtons.CueOnlyBtn;
		maskToolbarControl = titleButtons.ShowMaskToolbar;

	end

	local vis = obj.TrackSheet;
	local layerToolbarVis = obj.ShowLayerToolbar;

	if (stepControl) then stepControl.Visible = vis; end;
	--if (valueReadoutControl) then valueReadoutControl.Visible = vis; end;
	if (cueOnlyControl) then cueOnlyControl.Visible = vis; end;
	if(maskToolbarControl) then maskToolbarControl.Visible = vis; end;

	local Frame=ctx.Frame;
	Frame.RecipeFrame.Visible=obj.ShowRecipes;
	Frame.NotesFrame.Visible=obj.ShowNotes;
	Frame.Toolbars.LayerToolbar.Visible = obj.ShowLayerToolbar;
	if (obj.TrackSheet) then
		Frame.Toolbars.MaskToolbar.Visible=obj.ShowMaskToolbar;
	else
		Frame.Toolbars.MaskToolbar.Visible=false;
	end
	if obj.ShowRecipes then
		UpdateRecipeGrid(ctx.Frame.SequenceGrid)
	end
end

local function OnFilterSettingsChanged(obj, change, ctx)
	OnSettingsChanged(obj:Parent():Parent(), change, ctx);
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

signalTable.SequenceSheetWindowLoaded = function(caller,status,creator)
	local settings = caller.WindowSettings;
	if (settings) then
		caller.TitleBar.Title.Settings = settings;
		HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
		HookObjectChange(OnFilterSettingsChanged, settings:Ptr(1):Ptr(1), my_handle:Parent(), caller);
		OnSettingsChanged(settings, nil, caller);

		local cue_grid = caller.Frame.SequenceGrid
		local grid_sel = cue_grid:GridGetSelection();
		HookObjectChange(OnMainGridSelectionChanged, grid_sel, my_handle:Parent(), cue_grid);
		UpdateRecipeGrid(cue_grid);
	end
end

signalTable.SetSettingsAsTarget = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.Target = settings;
end

signalTable.SetTargetSettings = function(caller,status,creator)	
	signalTable.SetSettingsAsTarget(caller,status,creator)
end

signalTable.SetRecipeSettings = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings=wnd.WindowSettings.RecipeSheetSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.RecipeGrid.ExternalSettings = settings;
end

signalTable.OnSequenceTargetChanged = function(caller,status,new_target)
    --Echo("Sequence target changed to "..tostring(new_target));
	local wnd = caller:FindParent("Window");
	UpdateRecipeTarget(wnd);
	UpdateRecipeGrid(wnd.Frame.SequenceGrid)

	wnd.Target = wnd.Frame.SequenceGrid.TargetObject;
	local TagButtonList = wnd.Frame.TagButtonList;
	if TagButtonList then
		TagButtonList.Target = wnd.Target;
	end
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
					notesHeader.Text = "Note for " .. cueNameFromIndex .. " '" .. cueNameFromObject .. "' : " .. partNameFromIndex .. "'";
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

  	caller:SelectionChanged(row_id);
end

signalTable.OnCharInput = function(caller, signal)
    local seqSheet = caller:FindParent("SequenceWindow").Frame.SequenceGrid;
    seqSheet:OnNoteCharInput(signal);
end
