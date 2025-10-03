local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-------------------------------------------
-- temporary variables

local lastState = {
	filterSettings = {
	   manufacturer = true,
	   name = true,
	   mode = true,
	   description = false,
	   usedOnly = false
	},
	gridSelectedFixture = nil; -- remember for library changes
	itemSelection = {
		manu = nil;
		fixt = nil;
		mode = nil;
	},
};

local updateLibraryAllowed = true;

-------------------------------------------
-- Library Type selection area

local function updateTitleText(caller)
	local overlay = caller:GetOverlay()
	local title = overlay.TitleBar.Title
	title.text = "Select fixture type to import from "
	if (Patch().FixtureTypes.SourceIsShow) then
		title.text = title.text .. "show"
	else
		title.text = title.text .. "library"
	end
end

local function updateTabCorners(o)
	local ctr = o.Frame.HeadContainer.Row2
	if Patch().FixtureTypes.SourceIsShow then
		ctr.FromShw.Texture="corner0"
		ctr.FromLib.Texture="corner6"
	else
		ctr.FromShw.Texture="corner9"
		ctr.FromLib.Texture="corner0"
	end
end

local function updateModeButtonColoring(overlay)
	local ctr = overlay.Frame.HeadContainer.Row2;
	ctr.FromShw.State = Patch().FixtureTypes.SourceIsShow
	ctr.FromLib.State = not Patch().FixtureTypes.SourceIsShow

	updateTabCorners(overlay)
end

local function updateSideCtrBtn(overlay)
	local cnt = overlay.Frame.GridContainer.SideContainer
	local btn = overlay.Frame.BottomContainer.SideCtrBtn
	if Patch().FixtureTypes.SourceIsShow then
		cnt.visible = false; -- hide content
	end

	-- update enabled flag:
	btn.Enabled = not Patch().FixtureTypes.SourceIsShow
end

signalTable.GotoLibClicked = function(caller)
	Patch().FixtureTypes.SourceIsShow = false;
	updateTitleText(caller)
	updateTabCorners(caller:GetOverlay())
	updateSideCtrBtn(caller:GetOverlay())
	signalTable.UpdateLibrary()
end

signalTable.GotoShowClicked = function(caller)
	Patch().FixtureTypes.SourceIsShow = true;
	updateTitleText(caller)
	updateTabCorners(caller:GetOverlay())
	updateSideCtrBtn(caller:GetOverlay())
	signalTable.UpdateLibrary()
end

-------------------------------------------
-- library update trigger

signalTable.UpdateLibrary = function(force)
	if updateLibraryAllowed or force then
		CmdIndirectWait("Call FixtureType Library")
	end
end

-------------------------------------------
-- FixtureType Collect Changed

signalTable.FixtureTypeCollectChanged = function(ftc, cl, ctx)
	if ctx then
		-- signalTable.UpdateLibrary()
		signalTable.UpdateFilterButtons(ctx)
		updateModeButtonColoring(ctx)
	end
end

-------------------------------------------
-- On Load

local function OnDestroyDialog(caller, arg)
	local FixtureTypes=Patch().FixtureTypes;
	if (FixtureTypes.SourceIsShow) then
		FixtureTypes.SourceIsShow = false;
	end
end

local function PatchSettingsChanged(obj, chLev, o)
	--[[
		Hide Environmental functionality disabled in FixtureTypeImport,
		it should not be necessary any more with the new 3 Column Grid
		(all environmentals are combined in SET)

	if IsObjectValid(o) then
		-- register filter mask change (hide environmental)
		if (o.FilterMask ~= obj.FilterMaskValue) then
			o.FilterMask = obj.FilterMaskValue;
		end
	end]]
end

local function initDriveSelection(overlay)
	local currentDrive = Root().StationSettings.LocalSettings.SelectedDrive;
	local driveFound = false;
	for i,d in ipairs(Root().Temp.DriveCollect) do
		if (d.Path == currentDrive) then
			overlay.Frame.HeadContainer.Row1.LibraryButtons.DriveSelector:SelectListItemByIndex(i);
			driveFound = true;
			break;
		end
	end
	if ((currentDrive == "") or (driveFound ~= true)) then --internal
		overlay.Frame.HeadContainer.Row1.LibraryButtons.DriveSelector:SelectListItemByIndex(1);
	end
end

signalTable.FTImportLoaded = function(caller,status,creator)
	local addArgs = caller.AdditionalArgs;
	local selectMode = nil;
	local mode = nil;
	local adjustSize = true;
	local embedded = false;
	local libraryOnly = false;
	if (addArgs and addArgs.Mode) then selectMode = addArgs.Mode; end;
	if (addArgs and addArgs.DMXModeRef) then mode = StrToHandle(addArgs.DMXModeRef); end;
	if ((addArgs ~= nil) and (addArgs.AdjustSize ~= nil)) then adjustSize = addArgs.AdjustSize == "Yes"; end;
	if ((addArgs ~= nil) and (addArgs.Embedded ~= nil)) then embedded = addArgs.Embedded == "Yes"; end;
	if ((addArgs ~= nil) and (addArgs.ImportOptions ~= nil)) then libraryOnly = addArgs.ImportOptions == "LibraryOnly"; end

	if (selectMode == "Select") then
		-- Insert Fixtures Wizard
		caller.Frame.BottomContainer.ImportBtn.Text = "Select";
		caller.TitleBar.Title.Text = "Select DMX Mode to use";
		local FixtureTypes=Patch().FixtureTypes;
		if (FixtureTypes:Count() > 1) then
			FixtureTypes.SourceIsShow = true;
			caller:HookDelete(OnDestroyDialog);
		else
			FixtureTypes.SourceIsShow = false;
		end
	else
		-- Raw Import Mode
		selectMode = nil;
		local FixtureTypes=Patch().FixtureTypes;
		caller.Frame.HeadContainer.Row2.FromShw.enabled = false
		if (FixtureTypes.SourceIsShow) then
			FixtureTypes.SourceIsShow = false;
		end
	end

	-- setting some targets
	caller.Frame.BottomContainer.BottomCtrBtn.Target = caller.Frame.GridContainer.DescContainer
	caller.Frame.BottomContainer.SideCtrBtn.Target = caller.Frame.GridContainer.SideContainer

	-- updating ui elements...
	updateTabCorners(caller)
	updateTitleText(caller)
	updateModeButtonColoring(caller)
	updateSideCtrBtn(caller)
	signalTable.InitFilterButtons(caller)
	signalTable.UpdateFilterButtons(caller)

	-- everything built, now adjust size:
	if (adjustSize) then
		local d = caller:GetDisplay();
		local dr = d.AbsRect;
		caller.W = math.floor(dr.w * 1);
		caller.H = math.floor(dr.h * 1);
	end

	if (embedded) then
		caller.W="100%";
		caller.H="100%";
		caller.TitleBar.CloseBtn.Visible="false";
		caller.TitleBar.Title.MoveStart="";
		caller.TitleBar.Title.Move="";
		caller.TitleBar.Title.MoveEnd="";
		caller.TitleBar.Title.GestureClick="";
		caller.Texture="small_corner12" -- no shadow

		caller.Resizer.Visible=false;
		caller.Frame.BottomContainer.ImportBtn.Visible = true;
	end

    caller.Frame.HeadContainer.Row1.FilterEdit.Target = caller;
	if (caller.Frame.HeadContainer.Row1.FilterEdit:WaitInit(1) == true) then
		caller.Frame.HeadContainer.Row1.FilterEdit.SelectAll();
	end

	caller.TitleBar.AdditionalStuff.CountBtn.Target = caller;

	if caller.AbsRect.h < 650 then
		-- RPU adjustment
		caller.Frame.BottomContainer.BottomCtrBtn.Enabled = false;
		caller.Frame.BottomContainer.SideCtrBtn.Enabled = false;
	end
	
	local FixtureTypes=Patch().FixtureTypes;
	HookObjectChange(signalTable.FixtureTypeCollectChanged,
					 FixtureTypes,
					 my_handle:Parent(),
					 caller);

	-- as last step: preparing library...
	initDriveSelection(caller)
	signalTable.UpdateLibrary(true);
end

signalTable.DriveChange = function(caller,status,driveH,index)
	local drive = IntToHandle(driveH);
	local o = caller:GetOverlay();
	signalTable.UpdateLibrary(true);
	o.InitGrids();
end

signalTable.DoReturnEmpty = function(caller,dummy)
	local o = caller:GetOverlay();
	o.Value = "";
	o.Close();
end

-------------------------------------------
-- Import Fixture Type

signalTable.DoImportFT = function(caller,dummy)
	local o = caller:GetOverlay();
	local sel = o.Frame.GridContainer.Mode;
	local selInfo = IntToHandle(sel.SelectedItemValueI64);
	local origSelInfo = selInfo;
	local fixtureType = nil;
	local mode = nil;

	local originIsMode = origSelInfo:IsClass("FixtureTypeModeFile");
	local originIsType = origSelInfo:IsClass("FixtureTypeFile");

	if (originIsMode and (origSelInfo.OriginDMXMode ~= nil)) then 
		mode = origSelInfo.OriginDMXMode;
	elseif (originIsType and (origSelInfo.OriginFixtureType ~= nil)) then
		fixtureType = origSelInfo.OriginFixtureType;
		mode = origSelInfo:Ptr(1).OriginDMXMode;
	else
		if (not originIsType) then
			selInfo = selInfo:Parent();
			if (not selInfo:IsClass("FixtureTypeFile")) then selInfo = nil; end;
		end

		if ((selInfo ~= nil) and (selInfo.FileName ~= nil)) then
			local dest = Patch().FixtureTypes;
			local nextIndex = dest:Count() + 1;
			local d = Root().StationSettings.LocalSettings.SelectedDriveObject;
			local driveIndex = d:Index()
			local targetPath = selInfo.Path;
			Cmd("Select Drive 1");--set drive to internal
			updateLibraryAllowed = false;
			CmdIndirectWait("Import Library "..selInfo:Index().." At FixtureType "..nextIndex.." If Drive "..driveIndex.." /NoRefresh");
			updateLibraryAllowed = true;
			fixtureType = dest:Ptr(nextIndex);
			Cmd("Select Drive "..driveIndex);--reset drive to previous
			initDriveSelection(o)
		end
	end

	if (fixtureType and (mode == nil)) then
		if (originIsMode and (origSelInfo.Mode:len() > 0)) then 
			mode = fixtureType.DMXModes[origSelInfo.Mode]; 
		else
			mode = fixtureType.DMXModes:Ptr(1);
		end;
	end

	if (mode ~= nil) then
		o.Value = HandleToStr(mode);
	end
	o.Close();
end

signalTable.SelectAndClose = function(caller,status,col_id,row_id)
	signalTable.DoImportFT(caller,status);
end

signalTable.JumpToSelectButton = function(caller)
	FindBestFocus(caller:GetOverlay().Frame.BottomContainer.ImportBtn);
end

-------------------------------------------
-- Filter Buttons

local function adjustUsedOnlyIfNecessary(o,newValue)
	if newValue ~= nil then
		if (newValue ~= o.FilterByUsedOnly) then
			o.FilterByUsedOnly = newValue;
		end
	end
end

signalTable.InitFilterButtons = function(o)
	o.Frame.HeadContainer.Row1.FilterUsed.Target = o;
	-- ....DMXFullOnly.Target = GetPatchSettings() -- also removed

	-- some filteres were removed from UI with this commit, but the settings itself are still existing
	-- o.FilterByManufacturer = lastState.filterSettings.manufacturer;
	-- o.FilterByName = lastState.filterSettings.name;
	-- o.FilterByMode = lastState.filterSettings.mode;
	-- o.FilterByDescription = lastState.filterSettings.description;
	adjustUsedOnlyIfNecessary(o,lastState.filterSettings.usedOnly)
end

signalTable.UpdateFilterButtons = function(caller)
	if caller then
		local overlay = caller:GetOverlay()

		local libButtons = overlay.Frame.HeadContainer.Row1.LibraryButtons
		local UsedOnlyButton = overlay.Frame.HeadContainer.Row1.FilterUsed;
		libButtons.Enabled = not Patch().FixtureTypes.SourceIsShow
		UsedOnlyButton.enabled = Patch().FixtureTypes.SourceIsShow

		if Patch().FixtureTypes.SourceIsShow then
			adjustUsedOnlyIfNecessary(overlay,lastState.filterSettings.usedOnly)
		else
			adjustUsedOnlyIfNecessary(overlay,false)
		end
	end
end

signalTable.FTFilterChanged = function(caller, newFilter)
	lastState.filterSettings.manufacturer = caller.FilterByManufacturer;
	lastState.filterSettings.name = caller.FilterByName;
	lastState.filterSettings.mode = caller.FilterByMode;
	lastState.filterSettings.description = caller.FilterByDescription;
	lastState.filterSettings.usedOnly = caller.FilterByUsedOnly;
end

-------------------------------------------
-- Row Selection changed (SignalNames defined in FixtureTypeImport class)

signalTable.OnSelectedManufacturer = function(caller)
	local o = caller:GetOverlay();
	signalTable.UpdateModeInformation(o)
	o.RememberSelection();
end
signalTable.OnSelectedFixture = function(caller)
	local o = caller:GetOverlay();
	signalTable.UpdateModeInformation(o)
	o.RememberSelection();
end

-------------------------------------------
-- "Clear" filter button is only enabled when something is written
signalTable.UpdateClearFilterButton = function(caller, newCnt)
	local filterContainer = caller:Parent()
	filterContainer.Clear.enabled = newCnt ~= ""
end

-------------------------------------------
-- AdditionalInfo Info

signalTable.UpdateModeInformation = function(o)
	-- Update Side Container:
	local sel = o.Frame.GridContainer.Mode;
	local selMode = IntToHandle(sel.SelectedItemValueI64);
	local selFixture = (selMode and IsObjectValid(selMode)) and selMode:Parent() or nil
	
	local grid = o.Frame.GridContainer.SideContainer.ChannelSheet
	local gridData = grid.Internals.GridBase.FTInfoGridData

	if selMode and IsObjectValid(selMode) and (selMode:GetClass() == "FixtureTypeModeFile") and (selFixture:GetClass() == "FixtureTypeFile") then
		gridData.Channels = selMode.NonVirtualChannels;
	else
		gridData.Channels = {};
	end

	grid:Changed("None")

	-- Update Bottom Container:
	local botCtr = o.Frame.GridContainer.DescContainer

	botCtr.Description.Content = selMode.Description
	botCtr.Version.Text = selFixture and selFixture.Version or ""
	botCtr.FName.Content = selFixture and selFixture.FileName or ""
	botCtr.FSize.Text = selFixture and selFixture:Get("FileSize",Enums.Roles.Display) or ""
	botCtr.Creator.Text = selFixture and selFixture.Creator or ""
	botCtr.Source.Text = selFixture and selFixture.Source or ""
	botCtr.Uploader.Text = selFixture and selFixture.Uploader or ""
	botCtr.Rating.RatingText.Text = selFixture and selFixture.Rating or ""

	-- rating stars
	local rating = selFixture and tonumber(selFixture.Rating) or 0
	botCtr.Rating.RatingStars.Rating1.State = rating >= 0.5
	botCtr.Rating.RatingStars.Rating2.State = rating >= 1.5
	botCtr.Rating.RatingStars.Rating3.State = rating >= 2.5
	botCtr.Rating.RatingStars.Rating4.State = rating >= 3.5
	botCtr.Rating.RatingStars.Rating5.State = rating >= 4.5

	local isShareFile = selFixture and selFixture:GetClass() == "FixtureTypeShareLibraryFile"

	botCtr.Creator.Enabled = isShareFile
	botCtr.Uploader.Enabled = isShareFile
	botCtr.Rating:SetChildren("Enabled",isShareFile)
	botCtr.Rating.RatingStars:SetChildren("Visible",isShareFile)
	botCtr.HeadlineCreator.Enabled = isShareFile
	botCtr.HeadlineUploader.Enabled = isShareFile
	botCtr.HeadlineRating.Enabled = isShareFile

	local isFromLib = not Patch().FixtureTypes.SourceIsShow
	botCtr.Version.Enabled = isFromLib
	if not isFromLib then botCtr.Version.Text = ""; end
	botCtr.HeadlineVersion.Enabled = isFromLib
	botCtr.FName.Enabled = isFromLib
	botCtr.HeadlineFName.Enabled = isFromLib
	botCtr.FSize.Enabled = isFromLib
	botCtr.HeadlineFSize.Enabled = isFromLib
end

signalTable.NavigateBetweenItemLists = function(caller,dummy,keyCode)
	local parent = caller:Parent();
	local prev, next;
	if caller.name == "Manufacturer" then
		next = parent.Fixture;
	elseif caller.name == "Fixture" then
		prev = parent.Manufacturer;
		next = parent.Mode;
	elseif caller.name == "Mode" then
		prev = parent.Fixture
	end

	if (keyCode == Enums.KeyboardCodes.Right) then
		FindBestFocus(next);
	end
	if (keyCode == Enums.KeyboardCodes.Left) then
		FindBestFocus(prev);
	end
	if (keyCode == Enums.KeyboardCodes.Enter) then
		FindBestFocus(caller:GetOverlay().Frame.BottomContainer.ImportBtn);
	end
end