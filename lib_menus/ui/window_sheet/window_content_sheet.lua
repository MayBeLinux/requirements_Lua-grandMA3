local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function UpdateRecipeGrid(cue_grid)
	local ui_parent=cue_grid:Parent();
	local recipe_grid=ui_parent.Scroller.RecipeFrame.RecipeGrid;
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


local function OnScrollerChanged(obj, change, ctx)
    local settings = ctx.WindowSettings;
	if (settings) and (settings.ShowRecipes) then
	    local grid = ctx.Frame.Splitter.CueGrid;
		UpdateRecipeGrid(grid);		
	end	
end

local function OnSettingsChanged(obj, change, ctx)
	local titleButtons = ctx.TitleBar.TitleButtons;
	local stepControl = nil;
	local cueOnlyControl = nil;
	local valueReadoutControl = nil;
	if (titleButtons) then
		stepControl = titleButtons.StepControl;
		valueReadoutControl = titleButtons.ValueReadout;
		cueOnlyControl = titleButtons.CueOnlyBtn;
	end
	
	local vis = obj.TrackSheet;
	local layerToolbarVis = obj.ShowLayerToolbar;

	if (stepControl) then stepControl.Visible = vis; end;
	if (valueReadoutControl) then valueReadoutControl.Visible = vis; end;
	if (cueOnlyControl) then cueOnlyControl.Visible = vis; end;

	local Frame=ctx.Frame;
	Frame.Splitter.Scroller.ScrollerFrame.Visible= true;
	Frame.Splitter.Scroller.RecipeFrame.Visible=obj.ShowRecipes;
	Frame.Splitter.Scroller.Toolbars.LayerToolbar.Visible = obj.ShowLayerToolbar;	
	Frame.Splitter.Scroller.Toolbars.MaskToolbar.Visible = obj.ShowMaskToolbar;	
	Frame.Splitter.Scroller.NotesFrame.Visible = obj.ShowNotes;

	local settings = ctx.WindowSettings;
	local cue = settings.ManualCue;
	
	if (cue) and (HandleToInt(cue) ~= 0) then
	    local Seq = cue:Parent();
		if(Seq ~= nil) then
	       if (ctx.Frame.Splitter.CueGrid.TargetObject ~= Seq) then
		      ctx.Frame.Splitter.CueGrid.TargetObject = Seq;
		      local grid = ctx.Frame.Splitter.CueGrid;
		      grid:SelectRow(HandleToInt(cue));
		   end
		end
	end
	
	local scroller = Frame.Splitter.Scroller.ScrollerFrame.CuePartViewerScroll.MultiScroller;

	if (settings.ContentSheetCueMode ~= "Manual") then
	   scroller:ObtainCurrentCue();
	   cue = scroller.ShownCue;		   
	end

	HookObjectChange(OnScrollerChanged, scroller, my_handle:Parent(), ctx);
    
	if obj.ShowRecipes then
		UpdateRecipeGrid(ctx.Frame.Splitter.CueGrid);
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

local function SetTitlebuttonsTarget(caller,status,settings)
	local titleButtons = caller.TitleBar.TitleButtons
	if (titleButtons) then
		titleButtons.ValueReadout.Target = settings
		titleButtons.LinkType.Target = settings
		titleButtons.ContentSheetCueMode.Target = settings
		titleButtons.ShowTracked.Target = settings
		titleButtons.ShowParts.Target = settings
		titleButtons.CueOnlyBtn.Target = settings
		titleButtons.FixtureSort.Target = settings
		titleButtons.FixtureSelect.Target = settings
		titleButtons.FeatureSort.Target = settings
		titleButtons.FeatureSymbols.Target = settings
		titleButtons.ShowMaskToolbar.Target = settings
		titleButtons.ShowLayerToolbar.Target = settings
		titleButtons.OutputSymbol.Target = settings
		titleButtons.FeatureSymbols.Target = settings
		titleButtons.MergeCells.Target = settings
		titleButtons.PresetReadout.Target = settings
		titleButtons.ChannelSetReadout.Target = settings
		titleButtons.ColorMode.Target = settings
		titleButtons.ShowRecipes.Target = settings
		titleButtons.SortMode.Target = settings
		titleButtons.GroupByIDType.Target = settings
		titleButtons.ShowNotes.Target = settings
		titleButtons.ShowIDType.Target = settings
		titleButtons.ShowNameField.Target = settings
		titleButtons.Layer.Target = settings
		SetMasksTarget(caller, titleButtons, settings)
	else
		ErrEcho("[window fixture sheet]TitleButtons container was not found");
	end

end

signalTable.ContentSheetWindowLoaded = function(caller,status,creator)
	
    local settings = caller.WindowSettings;
		    
	if (settings) then
	    local cue = settings.ManualCue;
		caller.TitleBar.Title.Settings = settings;
		SetTitlebuttonsTarget(caller, status, settings)
		HookObjectChange(OnSettingsChanged, caller.WindowSettings, my_handle:Parent(), caller);
		OnSettingsChanged(caller.WindowSettings, nil, caller);
	    if (cue) and (HandleToInt(cue) ~= 0) then
		   caller.Frame.Splitter.CueGrid.TargetObject = cue:Parent();
		   local grid = caller.Frame.Splitter.CueGrid;
		   grid.ItemPlacementOffsetFactorH=0.5; -- so that selected row is in middle
		   grid:SelectRow(HandleToInt(cue));		    
		end
		caller.TitleBar.TitleButtons.Mask1.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(1)
		caller.TitleBar.TitleButtons.Mask2.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(2)
		caller.TitleBar.TitleButtons.Mask3.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(3)
		caller.TitleBar.TitleButtons.Mask4.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(4)
		caller.TitleBar.TitleButtons.Mask5.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(5)
		caller.TitleBar.TitleButtons.Mask6.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(6)
		caller.TitleBar.TitleButtons.Mask7.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(7)
		caller.TitleBar.TitleButtons.Mask8.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(8)
		caller.TitleBar.TitleButtons.Mask9.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(9)
		caller.TitleBar.TitleButtons.Mask10.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(10)
		caller.TitleBar.TitleButtons.Mask11.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(11)
		caller.TitleBar.TitleButtons.Mask12.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(12)
		caller.TitleBar.TitleButtons.Mask13.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(13)
		caller.TitleBar.TitleButtons.Mask14.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(14)
		caller.TitleBar.TitleButtons.Mask15.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(15)
		caller.TitleBar.TitleButtons.Mask16.Target = caller.WindowSettings.FilteredSheetSettingsFilterCollect:CmdlinePtr(16)
	end	
end

signalTable.SetSettingsAsTarget = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.Target = settings;
end

signalTable.SetTargetSettings = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.Target = settings;
end

signalTable.SetFixtureSettingsTarget = function(caller,status,visible)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.Target = settings.FixtureSheetSettings
end


local function OnSelected(caller,status,settings)
    local selected = IntToHandle(caller.SelectedRow);
	if (selected ~= nil) then
	   --Echo("  OnSelected "..selected:GetClass());
	   if (settings) then
	       if (selected:GetClass() == "Part") and (settings.ManualCue ~= selected:Parent()) then
		      settings.ManualCue = selected:Parent();	
		   end
		   if (selected:GetClass() == "Cue") and (settings.ManualCue ~= selected) then
		      settings.ManualCue = selected;		  
		   end	  
	   end
	end
end

signalTable.OnCueSelected = function(caller,status,creator)
	local selected = IntToHandle(caller.SelectedRow);
	if (selected ~= nil) then
	   --Echo("  Selected cue: "..selected:ToAddr());
	   local wnd = caller:FindParent("Window");
	   OnSelected(caller,status,wnd.WindowSettings);	   
	   wnd.ContentChanged = true;	   
	end
end

signalTable.OnRowSelected = function(caller,status,creator)
	local selected = IntToHandle(caller.SelectedRow);
	if (selected ~= nil) then
	   local wnd = caller:FindParent("Window");
	   --Echo("  Selected row: "..selected:ToAddr());
	   OnSelected(caller,status,wnd.WindowSettings);
	   wnd.ContentChanged = true;	   
	end
end

signalTable.OnTitlebuttonsLoaded = function(caller,status)
	local Patch = Patch();
	if (Patch) then
		local idTypes = Patch.IDTypes;
		if(idTypes) then
			for i=1,idTypes:Count() do
				if caller["IDType"..i] then
					caller["IDType"..i].Text = idTypes:Ptr(i).Name;
				end
			end
		end;
	end;
end

signalTable.SetRecipeSettings = function(caller,status,creator)
	if not IsObjectValid(caller) then return; end
    local settings = CurrentProfile().TemporaryWindowSettings.SequenceSheetSettings.RecipeSheetSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.RecipeGrid.ExternalSettings = settings;
end
