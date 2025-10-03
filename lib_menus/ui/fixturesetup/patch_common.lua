local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local NewLineRowId = -2;
--[[
	Local scope functions
]]

function PatchGetSplitGridFirstSelected(m)
	local g = m.Content.SplitFrame.FilterBy.ObjGrid;
	local gridSel = g:GridGetSelection();
	local selItems = gridSel.SelectedItems;
	if #selItems > 0 then
		return selItems[1].row
	end
	return nil
end

local function TryPatch(f, next)
	local mode = f.ModeDirect;
	if mode ~= nil then
		local fp = mode.DMXFootprint;
		for i=1,8,1 do
			local v = fp[i].valid;
			if (v) then
				next, last = FindBestDMXPatchAddr(Patch(), next, fp[i].size, 1);
				f["Break"..i]=next;
				if (next >= 0) then next = last; end;
			end
		end
	end
	return next
end

local function CollidesWithRecentlyPatched(addr, size, opt)
	for i=1,#opt.patched,1 do
		local item = opt.patched[i]
		if addr < (item.addr + item.size) and (addr+size) > item.addr then
			return true, item.addr + item.size;
		end
	end
	return false;
end

local function CollidesWithAnything(mode, brkIdx, addr, size, opt)
	local u = math.floor(addr / 512);
	local o = addr % 512;
	local addrStr = (u+1).."."..(o+1)
	return CheckDMXCollision(mode, addrStr, 1, brkIdx) ~= true or CollidesWithRecentlyPatched(addr, size, opt) == true;
end

function TryPatchIntoUniverse(f, univ, opt)
	local mode = f.ModeDirect;
	if mode ~= nil then
		local fp = mode.DMXFootprint;
		univ = tostring(univ)
		for i=1,8,1 do
			local v = fp[i].valid;
			if (v) then
				local cur = f["Break"..i];
				local off = cur % 512;
				cur = tostring(univ).."."..(off + 1);
				local absNewAddr = (univ - 1)*512 + off;
				--cur = cur:gsub("^%d+", univ);
				local _do = true; 
				local next_free = false;
				if CollidesWithAnything(mode, i-1, absNewAddr, fp[i].size, opt) == true then
					if opt.all_next_free == true then
						next_free = true;
					elseif opt.all_leave_as_is == true then
						_do = false;
					else
						local res = MessageBox({
							title="Patch collision detected",
							message="Re-patching "..f.Name.."\nAddress "..cur.." is already occupied\nPatch to the next free address?",
							commands={{value=1, name="Yes"}, {value=2, name="Yes for all"}, {value=3, name="No"}, {value=4, name="No for all"}},
						});
						if res.success then
							if res.result == 1 then
								next_free = true;
							elseif res.result == 2 then
								next_free = true;
								opt.all_next_free = true;
							elseif res.result == 3 then
								_do = false;
							elseif res.result == 4 then
								_do = false;
								opt.all_leave_as_is = true;
							end
						else
						   _do = false;
						end
					end
				end

				if _do == true then
					if next_free == true then
						cur = (univ-1)*512 + off
						repeat
							cur = FindBestDMXPatchAddr(Patch(), cur, fp[i].size, 1);
							local collides, next = CollidesWithRecentlyPatched(cur, fp[i].size, opt);
							if collides == true then 
								cur = next 
							end
						until not collides
					end

					f["Break"..i]=cur;
					opt.patched[#opt.patched + 1] = {addr = cur, size=fp[i].size}
				end
			end
		end
	end
	return next
end

local function IDCollidesWithAnything(idIdx, id, opt)
	return CheckFIDCollision(id, 1, idIdx) ~= true or (opt.ids[id] ~= nil);
end

local function GetMainFixtureGrid(caller)
	local patch = Patch();
	local ov = caller:GetOverlay();
	return ov.Content.MainFixturesGridContainer.FixturesSetupGrid;
end

function PatchTrySetID(f, idName, idIdx, opt)
	local oldType = f.IDType
	if oldType ~= idName then
		if idName == nil then
			f.CID = "None"
			f.FID = "None"
			f.IDType = "Fixture"
		else
			local cid = nil;
			local fid = nil;
			local checkId = nil
			if oldType == "Fixture" then
				cid = f.FID
				fid = "None"
				checkId = cid
			elseif idName == "Fixture" then
				fid = f.CID
				cid = "None"
				checkId = fid
			else
				cid = f.CID
				fid = nil
				checkId = cid
			end
			if checkId == "None" then checkId = 0 end
			local _do = true
			local next_free = false
			if checkId > 0 and IDCollidesWithAnything(idIdx, checkId, opt) == true then
				if opt.all_next_free == true then
					next_free = true;
				elseif opt.all_leave_as_is == true then
					_do = false;
				else
					local res = MessageBox({
						title="ID collision detected",
						message="Setting ID for "..f.Name.."\nID "..checkId.." is already occupied\nSet to the next free ID?",
						commands={{value=1, name="Yes"}, {value=2, name="Yes for all"}, {value=3, name="No"}, {value=4, name="No for all"}},
					});
					if res.success then
						if res.result == 1 then
							next_free = true;
						elseif res.result == 2 then
							next_free = true;
							opt.all_next_free = true;
						elseif res.result == 3 then
							_do = false;
						elseif res.result == 4 then
							_do = false;
							opt.all_leave_as_is = true;
						end
					else
					   _do = false;
					end
				end
			elseif checkId == 0 then
				cid = nil
				fid = nil
			end

			if _do == true then
				if next_free == true then
					local idTypes = Patch().IDTypes
					checkId = idTypes:Ptr(idIdx + 1).MaxID + 1
					repeat
						local collides = IDCollidesWithAnything(idIdx, checkId, opt);
						if collides == true then 
							checkId = checkId + 1 
						end
					until not collides
					if oldType == "Fixture" then
						cid = checkId;
					elseif idName == "Fixture" then
						fid = checkId;
					else
						cid = checkId;
					end
				end

				if cid ~= nil then f.CID = cid end
				if fid ~= nil then f.FID = fid end
				f.IDType = idName
				if checkId > 0 then opt.ids[checkId] = true; end
			end
		end
	end
end

local function UpdateCondensedFilter(settings, columnToShow)
	if columnToShow == nil then
		settings.AllowExtendedCondensed = false
		return
	end
	settings.AllowExtendedCondensed = true
	local colFilters = settings:Ptr(1)
	local condensed = colFilters:Ptr(2)
	if condensed.Name == "Condensed" then
		if condensed:Find(columnToShow) == nil then
			settings.CheckColumnCondensedFilter()--remove anything that doesn't fit
			local gc = condensed:Append();
			gc.Name = columnToShow;
			gc.Visible = true;
			condensed:Changed()
		end
	end
end

function CallInsertFixturesWizzardIfPatchEmpty(caller)
	local p = Patch();
	local block = (GlobalBlockAutoFunctionality ~= nil) and (GlobalBlockAutoFunctionality == true);
	if ((p.CountFixtures == 1) and (block == false)) then
		local grid = GetMainFixtureGrid(caller)
		local columnId = GetPropertyColumnId(p, "Name");
		grid.SelectCell('', NewLineRowId, columnId);
		coroutine.yield({ui=1})
		CmdIndirect("Insert UiGridSelection");
	end
end

local function GetGridLocalRowFilter(grid)
	local settings = grid:GridGetSettings();
	return settings:Ptr(3);
end

local function GetFixtureGridLocalRowFilter(ctx)
	local fixtureGrid = GetMainFixtureGrid(ctx)
	return GetGridLocalRowFilter(fixtureGrid), fixtureGrid;
end

local function SplitGridUpdateExplorer(splitSel, cl, splitGrid)
	local filter, fixtureGrid = GetFixtureGridLocalRowFilter(splitGrid);
	fixtureGrid.ClearFilter()
	fixtureGrid:GridGetSettings().ShowFilterToolbar = false;

	local selItems = splitSel.SelectedItems;
	if #selItems > 0 then
		local newTargets ={}
		for i=1,#selItems,1 do
			local o = IntToHandle(selItems[i].row)
			if IsObjectValid(o) and o:IsClass("Stage") then
				o = o.Fixtures
			end
			newTargets[#newTargets + 1] = o
		end
		fixtureGrid.TargetObjects = newTargets
	else
		local p = Patch();
		local dest = CmdObj().Destination;
		if p:HasParent(dest) ~= nil then
			return;--we are actually not in the patch anymore
		end
		fixtureGrid.TargetObject = dest;
	end
end

local function GetFilterRoutines(field, filter)
	local cols = {field};
	local toFilterValue = function(r)
		return HandleToStr(IntToHandle(r))
	end
	local configureFilters = function(r)
		if r ~= nil then
			local f = IntToHandle(r)
			if IsObjectValid(f) and f:IsClass("PatchFilterItem") then
				local i = f:Index()
				if i == 1 then--All
					return
				elseif i == 2 then--Empty
					local item = filter:Append();
					item.Filter = "<Empty>"
					item.Columns = cols;
				end
			else 
				local item = filter:Append();
				item.Filter = toFilterValue(r);
				item.Columns = cols;
			end
		end
	end

	if field == "IDType" then
		local defaultConfig = configureFilters;
		configureFilters = function(r)
			if r ~= nil then
				local f = IntToHandle(r)
				if IsObjectValid(f) and f:IsClass("PatchFilterItem") then
					local i = f:Index()
					if i == 2 then--Empty
						local item = filter:Append();
						item.Filter = "0"
						item.Columns = {"CID"};

						local item = filter:Append();
						item.Filter = "0"
						item.Columns = {"FID"};
						return
					end
				end
			end
			defaultConfig(r)
		end
		toFilterValue = function(r)
			local id = IntToHandle(r);
			return id.Name.." "..id:Index();
		end
	elseif field == "Filter" then
		local first = true;
		configureFilters = function(r)
			if first == true then
				first = false;
				local settings = filter:FindParent("PatchSettings");
				local fObj = IntToHandle(r);
				if settings ~= nil and fObj ~= nil and fObj:IsClass("World") then
					settings.Filter = fObj;
				else
					settings.Filter = nil;
				end
			end
		end
	elseif field == "Patch" then
		local added = 0
		local composedFilter = ""
		local addIfNotEmpty = function()
			if added > 0 then
				local item = filter:Append();
				item.Filter = composedFilter;
				item.Columns = cols;
				added = 0
				composedFilter = ""
			end
		end
		configureFilters = function(r)
			if r ~= nil then
				local f = IntToHandle(r)
				if IsObjectValid(f) and f:IsClass("PatchFilterItem") then
					local i = f:Index()
					if i == 1 then--All
						return
					elseif i == 2 then--Empty
						local item = filter:Append();
						item.Filter = "-t"--unpatched
						item.Columns = cols;
						return
					elseif i == 3 then--Conflicted
						local item = filter:Append();
						item.Filter = "ct"--unpatched
						item.Columns = cols;
						return
					end
				end
			end
			if r == nil or added == 100 then
				addIfNotEmpty()
			end
			if r ~= nil then
				local dmx = IntToHandle(r);
				if added == 0 then
					composedFilter = tostring(dmx:Index())
				else
					composedFilter = composedFilter.."+"..tostring(dmx:Index())
				end
				added = added + 1
			end
		end
	elseif field == "FixtureType" then
		toFilterValue = function(r)
			local ftFake = IntToHandle(r)
			local ftReal = ftFake.FTRef;
			return HandleToStr(ftReal.DMXModes:Ptr(1))
		end
		local dmxModeCols = {"ModeDirect"};
		configureFilters = function(r)
			if r ~= nil then
				local ftFake = IntToHandle(r)
				local f = ftFake
				if IsObjectValid(f) and f:IsClass("PatchFilterItem") then
					local i = f:Index()
					if i == 1 then--All
						return
					elseif i == 2 then--Empty
						local item = filter:Append();
						item.Filter = "<Empty>"
						item.Columns = cols;
					end
				elseif ftFake:GetClass() == "FixtureTypeFake" then
					local ft = ftFake.FTRef;
					for i,v in ipairs(ft.DMXModes) do
						local item = filter:Append();
						item.Filter = HandleToStr(v);
						item.Columns = dmxModeCols;
					end
				else --DMXMode
					--need to filter by 2 columns
					local item = filter:Append();
					item.Filter = HandleToStr(ftFake.DMRef);
					item.Columns = dmxModeCols;
				end
			end
		end
	end

	return configureFilters;
end

local function SplitGridSelectionChanged(gridSel, cl, ctx)
	local filter, grid = GetFixtureGridLocalRowFilter(ctx);

	local configureFilters = GetFilterRoutines(ctx.SignalValue, filter)

	grid.ClearFilter()
	local fix_settings = grid:GridGetSettings()
	fix_settings.Filter = nil
	local cleanFilterCount = filter:Count()
	local selItems = gridSel.SelectedItems;
	if #selItems > 0 then
		for i=1,#selItems,1 do
			configureFilters(selItems[i].row)
		end
		configureFilters(nil)
		fix_settings.ShowFilterToolbar = true;
		--grid.AllowFilterContent = true;
	else
		fix_settings.ShowFilterToolbar = false;
		--grid.AllowFilterContent = false;
	end
end

local function HookGridSelection(grid, callback)
	local selObj = grid:GridGetSelection();
	HookObjectChange(callback, selObj, my_handle:Parent(), grid);
end

local function UnHookGridSelection(grid, callback)
	local selObj = grid:GridGetSelection();
	UnhookMultiple(callback, selObj, grid);
end

local function val_or_default(v, d)
	if v ~= nil then
		return v;
	else
		return d;
	end
end

--[[
	Global scope functions (used potentially in both: live and edit patches)
]]

function GetPatchSettings()
	local patch = Patch();
	local user_profile=CurrentProfile();
	local temp_settings=user_profile.TemporaryWindowSettings;
	local patch_settings=nil;
	if patch.Name == "LivePatch" then
		patch_settings=temp_settings.PatchLiveSettings;
	else
		patch_settings=temp_settings.PatchEditorSettings;
	end
	return patch_settings
end

function Get3DSettings()
	local patch = Patch();
	local user_profile=CurrentProfile();
	local temp_settings=user_profile.TemporaryWindowSettings;
	local settings=nil;
	settings=temp_settings.View3DSettings;
	Echo(string.format("3D Settings:%s",settings.name))
	return settings
end

function IsInPatchSplitView()
	return GetPatchSettings().ShowSplitView == true
end

function PatchMenuFixtureTypes(caller)
	local currentGrid = GetMainFixtureGrid(caller)
	local fixture = IntToHandle(tonumber(currentGrid.SelectedRow));

	local fixtureTypesUI = caller.SwitchMenu("FixtureTypes");
	if (fixture) then
		local mode = fixture.ModeDirect;
		if (mode) then
			local fixtureType = mode:Parent():Parent();
			local grid = fixtureTypesUI.Content.FixtureTypesSetupGrid;
			local columnId = GetPropertyColumnId(fixtureType, "Name");
			grid.ClearSelection();
			grid.SelectCell('', HandleToInt(fixtureType), columnId);
		end
	end
	
end
--[[
	p:
	{
	 cnt, (reference to Content block)
	 visible (bool),

	 value (string),
	 target (object reference),
	 selectCell{row,column} (can be nil),
	 newLineAllowed, (optional)
	 explorerMode (optional),
	 levelLimit(default=0),
	 columnFilter (optional, default 'Default')
	}
]]
function ConfigurePatchSplitView(p)
	local cnt = p.cnt;
	local maintabsCont = cnt:Parent().MainTabsCont;
	local maintabs = maintabsCont.MainTabs;
	local modesCont = cnt:Parent().PatchModesCont;
	local modes = modesCont.PatchModes;

	if cnt:GetOverlay().CloseProhibited == true then
		return;
	end

	UnHookGridSelection(cnt.SplitFrame.FilterBy.ObjGrid, SplitGridSelectionChanged);
	UnHookGridSelection(cnt.SplitFrame.Explorer, SplitGridUpdateExplorer);

	local mainSel = maintabs.SelectedItemValueStr

	local fixFilter, fixGrid = GetFixtureGridLocalRowFilter(cnt);
	local fix_settings = fixGrid:GridGetSettings()
	fixGrid.ClearFilter();
	fix_settings.ShowFilterToolbar = false;
	fixGrid.LevelLimit = val_or_default(p.fixLevelLimit, 127)
	local caller = cnt:Parent();
	if mainSel ~= "ShowSplitView" or p.value == "Hide" then
		cnt.SplitFrame.Visible = false;
		modesCont.Visible = false;
		fixGrid.FilterBlockUIEnabled = true;
		UpdateCondensedFilter(fix_settings, p.extendCondensed)
		return;
	end

	cnt.SplitFrame.Visible = p.visible;
	modesCont.Visible = p.visible;
	fixGrid.FilterBlockUIEnabled = not p.visible;

	local selectionChangedCallback = SplitGridSelectionChanged
	if p.visible then
	    local expectedContent = "FilterBy";
		if p.value == "Explorer" then expectedContent = "Explorer" end
		if cnt.SplitFrame.ActiveChild ~= expectedContent then
			cnt.SplitFrame.ChangeActive(expectedContent)
		end
	end

	if p.value == "Explorer" then
		HookGridSelection(cnt.SplitFrame.Explorer, SplitGridUpdateExplorer);
		selectionChangedCallback = SplitGridUpdateExplorer
	elseif p.value == "FilterBy" then
		signalTable[modes.SelectedItemValueStr](cnt:GetOverlay(), '')
		return;
	elseif p.visible == true then --actual filter mode
		HookGridSelection(cnt.SplitFrame.FilterBy.ObjGrid, SplitGridSelectionChanged);
	end

	if p.visible == true then
		local splitGrid = cnt.SplitFrame.FilterBy.ObjGrid;
		if p.value == "Explorer" then splitGrid = cnt.SplitFrame.Explorer; end
		splitGrid.LevelLimit = val_or_default(p.levelLimit, 0)
		local prevMask = splitGrid:GridGetData().FilterMask
		splitGrid:GridGetData().FilterMask = val_or_default(p.filterMask, 1);
		if prevMask ~= splitGrid:GridGetData().FilterMask then
			splitGrid:GridGetBase():Changed()
		end
		local settings = splitGrid:GridGetSettings();
		local colFilters = settings:Ptr(1)


		splitGrid.AllowFilterContent = val_or_default(p.filterContent, false)

		splitGrid.AllowEdit = val_or_default(p.editContent, true)
		splitGrid.AllowAddNewline = val_or_default(p.newLineAllowed, true)
		splitGrid.CreateAndEdit = val_or_default(p.createAndEdit, false)
		splitGrid.AutoNextCell = val_or_default(p.autoNextCell, true)
		splitGrid:GridGetData().ExplorerMode = val_or_default(p.explorerMode, false) 
		colFilters.SelectedFilter = val_or_default(p.columnFilter, "Default")
		splitGrid.SignalValue = p.value;
		if p.target ~= nil then
			if p.patchFilter ~= nil then 
				local patchFilter = Patch().PatchFilter;
				if p.patchFilter.empty == false then
					patchFilter.EmptyVisible = false;
				else
					patchFilter.EmptyVisible = true;
					patchFilter.EmptyFilterName = p.patchFilter.empty
				end
				if p.patchFilter.all == false then
					patchFilter.AllVisible = false;
				else
					patchFilter.AllVisible = true;
					patchFilter.AllFilterName = p.patchFilter.all
				end
				if p.patchFilter.custom3 ~= nil then
					patchFilter.CustomEntry3Visible = true;
					patchFilter.CustomEntry3FilterName = p.patchFilter.custom3
				else
					patchFilter.CustomEntry3Visible = false;
				end
				patchFilter.Settings = GetPatchSettings();
				patchFilter.Target = p.target;
				p.target = patchFilter
			end

			splitGrid.TargetObject = p.target;
			splitGrid.AddTargets = val_or_default(p.addTargets, false)
		end
		splitGrid.ClearSelection()

		UpdateCondensedFilter(fixGrid:GridGetSettings(), p.extendCondensed)
		FindBestFocus(fixGrid);

		if p.selectCell ~= nil then
			--splitGrid.SelectCell('', p.selectCell.row, p.selectCell.column);
			--selectionChangedCallback(splitGrid:GridGetSelection(), nil, splitGrid);
		end
	end
end

local function CheckSplit(cfg)
	if IsInPatchSplitView() ~= true then 
		cfg.value = "Hide" 
		cfg.visible = false 
		cfg.extendCondensed = nil 
	end
	return cfg;
end

function PatchSplitViewLayers(caller)
	local tgt = Patch().Layers;
	local columnId = GetPropertyColumnId(tgt, "Name");
	local cfg = {cnt = caller.Content, columnFilter="NameWithUsed", visible = true, value="Layer", extendCondensed="Layer", createAndEdit=true, autoNextCell=false, target=tgt, patchFilter={empty="No Layer"}, selectCell={row=NewLineRowId, column=columnId}}
	ConfigurePatchSplitView(CheckSplit(cfg));
end

function PatchSplitViewDMXUniverses(caller)
	local tgt = Patch().DmxUniverses;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView(CheckSplit({cnt = caller.Content, columnFilter="NameWithUsed", visible = true, value="Patch", target=tgt, patchFilter={empty="Unpatched", custom3="Conflicts"}, selectCell={row=NewLineRowId, column=columnId}}));
end

function PatchSplitViewFilters(caller)
	local tgt = DataPool().Filters;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView(CheckSplit({cnt = caller.Content, columnFilter="NameOnly", newLineAllowed=false, editContent=false, visible = true, value="Filter", target=tgt, patchFilter={empty=false}, selectCell={row=NewLineRowId, column=columnId}}));
end

function PatchSplitViewClasses(caller)
	local tgt = Patch().Classes;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView(CheckSplit({cnt = caller.Content, columnFilter="NameWithUsed", visible = true, value="Class", createAndEdit=true, autoNextCell=false, extendCondensed="Class", target=tgt, patchFilter={empty="No Class"}, selectCell={row=NewLineRowId, column=columnId}}));
end

function PatchSplitViewIDTypes(caller)
	local tgt = Patch().IDTypes;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView(CheckSplit({cnt = caller.Content, columnFilter="NameWithUsed", visible = true, value="IDType", extendCondensed="CID", target=tgt, patchFilter={empty="No ID"}, selectCell={row=NewLineRowId, column=columnId}}));
end

function PatchSplitViewFixtureTypes(caller)
	local tgt = Patch().FixtureTypesOverview;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView(CheckSplit({cnt = caller.Content, 
						visible = true, 
						value="FixtureType", 
						target=tgt, 
						patchFilter={empty="No Fixture Type"}, 
						selectCell={row=NewLineRowId, column=columnId}, 
						newLineAllowed=false, 
						columnFilter="NameWithUsed", 
						levelLimit=1, 
						editContent=false,
						filterMask = GetPatchSettings().FilterMaskValue + 1
						--filterContent=true
						}));
end

function PatchClearSplitFilter(caller)
	local splitGrid = caller:GetOverlay().Content.SplitFrame.FilterBy.ObjGrid;
	splitGrid.ClearSelection();
end

function PatchShowSplitView(caller)
	if not IsObjectValid(caller) or caller.CloseProhibited then
		Echo("patch invalid")
		return;
	end
	caller.SwitchMenu("");
	local cfg = {cnt = caller.Content, visible = true, value="FilterBy"}
	if IsInPatchSplitView() ~= true then 
		cfg.value = "Hide" 
		cfg.visible = false 
	end
	caller.TitleBar.TitleButtons.ShowFilter.Visible=not cfg.visible
	caller.TitleBar.TitleButtons.FilterBtn.Visible=not cfg.visible
	if cfg.visible == true then
		local patchEditorSettings = GetMainFixtureGrid(caller):GridGetSettings();
		patchEditorSettings.Filter = nil;
	end
	ConfigurePatchSplitView(cfg);
end

function PatchSplitViewExplorer(caller)
	local tgt = CmdObj().Destination;
	local columnId = GetPropertyColumnId(tgt, "Name");
	ConfigurePatchSplitView({cnt = caller.Content, 
						visible = true, 
						value="Explorer", 
						target=tgt:FindParent("Stage"), 
						addTargets=true,
						--selectCell={row=NewLineRowId, column=columnId}, 
						newLineAllowed=false, 
						--explorerMode=true, 
						columnFilter="NameAndId", 
						levelLimit=127, 
						fixLevelLimit=0, 
						filterMask = GetPatchSettings().FilterMaskValue + 1,
						editContent=false});
end

function PatchSettingsChangedCallback(obj, chLev, ctx)
	local ov = ctx:GetOverlay();
	local p = Patch();
	local fix_grid = GetMainFixtureGrid(ctx)
	local patchEditorSettings = fix_grid:GridGetSettings();

	local currentDest = CmdObj().Destination;
	if p:HasParent(currentDest) ~= nil then
		return;--we are actually not in the patch anymore
	end
	local changeDir = ov.MainDialog:GetUIChildrenCount() == 0;--there is no sub-dialog opened

	local s = StrToHandle(patchEditorSettings:Get("SelectedStage", Enums.Roles.Edit));
	local shouldBeTarget = nil;
	if (IsObjectValid(s) == true) then
		shouldBeTarget = s.Fixtures;
		if (changeDir and shouldBeTarget ~= currentDest) then
			Cmd("cd Root "..p:Addr());
			Cmd("cd "..s:Addr(p));
            Cmd("cd \"Fixtures\"");
		end
	else--all stages 
		shouldBeTarget = p.Stages;
		if (changeDir and shouldBeTarget ~= currentDest) then
			Cmd("cd Root "..p:Addr());
			Cmd("cd \"Stages\"");
		end
	end

	local explorerMode = changeDir and ov.Content.SplitFrame.Visible == true and ov.Content.SplitFrame.Explorer.Visible == true;
	local prevMask = fix_grid:GridGetData().FilterMask
	fix_grid:GridGetData().FilterMask = patchEditorSettings.FilterMaskValue;
	local dmxLessChanged = prevMask ~= patchEditorSettings.FilterMaskValue
	if dmxLessChanged then
		fix_grid:GridGetBase():Changed()
	end

	if explorerMode ~= true then
		fix_grid.TargetObject = shouldBeTarget;
	elseif IsObjectValid(s) then
		ov.Content.SplitFrame.Explorer.TargetObject = s
	else
		ov.Content.SplitFrame.Explorer.TargetObject = p.Stages
	end

	local f = patchEditorSettings.Filter;
	local isValid = IsObjectValid(f) == true;
	local showToolbar = patchEditorSettings.ShowFilterToolbar;
	local showSplit = patchEditorSettings.ShowSplitView;
	local maintabsCont = ov.MainTabsCont;
	local maintabs = maintabsCont.MainTabs;
	local mainSel = maintabs.SelectedItemValueStr

	if mainSel == "ShowSplitView" then
		if showSplit ~= ov.PatchModesCont.Visible or (showSplit and dmxLessChanged) then
			local cb = function()
				PatchShowSplitView(ov, "ShowSplitView")
			end
			--cannot execute right away, we're in the hook
			Timer(cb, 0, 1)
		end
	end

	GetMainFixtureGrid(ov).AllowFilterContent = showToolbar;
end

function PatchFixturesChangedCallback(obj,_,patchEditor)
	-- fixtures structurally changed, trigger a re-init of the FilterBy grid
	local filterByGrid = patchEditor.Content.SplitFrame.FilterBy.ObjGrid
	filterByGrid:Changed()
end

function PatchGridColumnFilterChangedCallback(obj, chLev, patchEditor)
	local tabs = patchEditor.PatchModesCont.PatchModes;
	local function toggleTab(tabName, tabValue, value)
		local idx = tabs:FindListItemByName(tabName);
		if idx and not value then
			tabs:RemoveListItem(tabName);
		elseif not idx and value then
			tabs:AddListLuaItem(tabName,tabValue,signalTable[tabValue])
		end
	end

	local filterIsFull = obj.SelectedFilter == 0 -- 0 -> Full, 1 -> "Condensed"
	toggleTab("ID Types","SplitViewIDTypes", filterIsFull)
	toggleTab("Layers","SplitViewLayers", filterIsFull)
	toggleTab("Classes","SplitViewClasses", filterIsFull)
	tabs:Changed()
end

function FixturePatchLoadedCommon(caller, str)
	local patch_settings=GetPatchSettings()
	local settings_3D=Get3DSettings()

	--Root().Menus.FilterSettings:CommandCall(caller);
	caller:WaitInit();

	local p = Patch();
	local stageBtn = caller.TitleBar.TitleButtons.StageControl;
	stageBtn.Property = "SelectedStage";
	stageBtn.Target = patch_settings;

	HookObjectChange(signalTable.PatchFixturesChanged,p.Stages, my_handle:Parent(), caller)
	HookObjectChange(signalTable.SettingsChanged, patch_settings, my_handle:Parent(), caller);
	HookObjectChange(signalTable.GridColumnFilterChanged, patch_settings:Ptr(1), my_handle:Parent(), caller);

	--setting column filter swipe button's target property to a GridColumnFilterCollect object in the settings
	caller.TitleBar.TitleButtons.ColumnsFilters.Target = patch_settings:Ptr(1);
	signalTable.SettingsChanged(patch_settings, 0, caller);
	signalTable.GridColumnFilterChanged(patch_settings:Ptr(1), 0, caller);
	caller.TitleBar.Title.Settings = patch_settings;
	caller.TitleBar.TitleButtons.FilterBtn.Target = patch_settings;
	caller.TitleBar.TitleButtons.ShowFilter.Target = patch_settings;
	caller.TitleBar.TitleButtons.ShowSplit.Target = patch_settings;
	caller.TitleBar.TitleButtons.Show3DPositions.Target = patch_settings;
	caller.TitleBar.TitleButtons.DMXFullOnly.Target = patch_settings;
	caller.TitleBar.TitleButtons3D.Camera.Target = settings_3D;

end

local function SplitViewVisibleCheck(tgtFunc, ...)
	if IsInPatchSplitView() == true then 
		tgtFunc(...)
	end
end

--[[
	signal table configuration
]]
signalTable.PatchFixturesChanged = PatchFixturesChangedCallback
signalTable.SettingsChanged = PatchSettingsChangedCallback
signalTable.GridColumnFilterChanged = PatchGridColumnFilterChangedCallback
signalTable.ClearSplitFilter = PatchClearSplitFilter
signalTable.ShowSplitView = PatchShowSplitView
signalTable.MenuFixtureTypes = PatchMenuFixtureTypes
signalTable.SplitViewFixtureTypes = function(...) SplitViewVisibleCheck(PatchSplitViewFixtureTypes, ...); end
signalTable.SplitViewLayers = function(...) SplitViewVisibleCheck(PatchSplitViewLayers, ...); end
signalTable.SplitViewDMXUniverses = function(...) SplitViewVisibleCheck(PatchSplitViewDMXUniverses, ...); end
signalTable.SplitViewExplorer = function(...) SplitViewVisibleCheck(PatchSplitViewExplorer, ...); end
signalTable.SplitViewIDTypes = function(...) SplitViewVisibleCheck(PatchSplitViewIDTypes, ...); end
signalTable.SplitViewClasses = function(...) SplitViewVisibleCheck(PatchSplitViewClasses, ...); end
signalTable.SplitViewFilters = function(...) SplitViewVisibleCheck(PatchSplitViewFilters, ...); end

signalTable.SetPatchEditorSettingsAsTarget = function (caller)
	caller.Target = GetPatchSettings();
end
