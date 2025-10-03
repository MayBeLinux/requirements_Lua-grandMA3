local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local MAX_MARKERS_TOTAL = ConfigTable().MaxMArkers
local MAX_MARKER_ID = ConfigTable().MaxMArkerID

local smallDisplay = false;
local addrEdited = false;
local fidEdited = false;
local cidEdited = false;
local lastAddr = {};
local lastFid = nil
local lastCid = nil
local lastVisibleField = nil;
local preSetDmxUniverse = nil;

local currentField = nil;

local function UpdateActiveLabel()
	local fields = currentField:Parent()
	if fields.name == "Fields" then
		local n = currentField.name
		local colAct = "Global.Selected"
		local colInact = ""

		fields.FixtureNameLabel.TextColor = (n == "FixtureName" and colAct or colInact);
		fields.QuantityLabel.TextColor = (n == "Quantity" and colAct or colInact);
		fields.FixtureIDLabel.TextColor = (n == "FixtureID" and colAct or colInact);
		fields.IDTypeLabel.TextColor = (n == "IDType" and colAct or colInact);
		fields.ChannelIDLabel.TextColor = (n == "ChannelID" and colAct or colInact);
		fields.LayerLabel.TextColor = (n == "Layer" and colAct or colInact);
		fields.ClassLabel.TextColor = (n == "Class" and colAct or colInact);
		fields.Br1.TextColor = (n == "Address1" and colAct or colInact);
		fields.Br2.TextColor = (n == "Address2" and colAct or colInact);
		fields.Br3.TextColor = (n == "Address3" and colAct or colInact);
		fields.Br4.TextColor = (n == "Address4" and colAct or colInact);
		fields.Br5.TextColor = (n == "Address5" and colAct or colInact);
		fields.Br6.TextColor = (n == "Address6" and colAct or colInact);
		fields.Br7.TextColor = (n == "Address7" and colAct or colInact);
		fields.Br8.TextColor = (n == "Address8" and colAct or colInact);
	end
end

local function ShowWarning(o,text)
	o.Title.WarningButton.ShowAnimation(text)
end

local function FixtureIsMarker(o)
	if (o.DmxMode) then
		return (o.DmxMode:Parent():Parent().SpecialPurpose=="MArker")
	end
end

-------------------------------------------
-- error color

local function changeColorErr(field, collision)
	assert(type(collision)=="boolean")
	local oldColor = field.BackColor and field.BackColor:AddrNative(Root().ColorTheme.ColorGroups) or "";
	local newColor = collision and "InsertFixturesWizard.Collision" or "UIObject.Background"

	if (oldColor == "InsertFixturesWizard.UserEdited" and newColor == "UIObject.Background") then
		return; -- [[its an edited cell and still valid, no need to change color]]
	end

	if (oldColor ~= newColor) then
		field.BackColor = newColor;
	end
end

local function changeColorEdited(field)
	if field.name == "Done" then return; end

	local oldColor = field.BackColor and field.BackColor:AddrNative(Root().ColorTheme.ColorGroups) or "";
	if (oldColor ~= "InsertFixturesWizard.Collision") then
		field.BackColor = "InsertFixturesWizard.UserEdited"
	end
end

local function resetColor(field)
	field.BackColor = "UIObject.Background"
end

-------------------------------------------
-- Name suggestion handling

local function CreateIndexName(o, fixtureName)
	local mode = o.DmxMode;
	local used = mode:Parent():Parent().RealUsed
	local idx = used + 1

	return fixtureName.." "..idx
end

local function UpdateNameSuggestions(o)
	local container = o.Frame.Context.ContextFixtureName.NamesAutoLayout
	local mode = o.DmxMode
	local ft = mode:Parent():Parent();

	container:ClearUIChildren()

	local function addEntry(text)
		local new = container:Append("Button")
		new.Text=text
		new.Clicked="DoSelectSuggestedName"

		-- and with id:
		new = container:Append("Button")
		new.Text=CreateIndexName(o, text)
		new.Clicked="DoSelectSuggestedName"
	end

	if ft.ShortName then
		addEntry(ft.ShortName)
	end

	if ft.Name and ft.Name ~= ft.ShortName then
		addEntry(ft.Name)
	end

	if ft.Manufacturer then
		addEntry(ft.Manufacturer)
		
		if ft.ShortName then
			addEntry(ft.Manufacturer.." "..ft.ShortName)
		end
	end
end

signalTable.DoSelectSuggestedName = function(caller)
	local o = caller:GetOverlay()
	o.FixtureName=caller.text;
	FindBestFocus(o.Frame.Fields.Name)
end

-------------------------------------------
-- FID suggestion handling

local function UpdateFIDSuggestions(overlay, idType)
	local function CreateFIDSuggestion(btn, fixtureQuantity, idType)
		local result = tonumber(btn.signalValue);
		local max;
		if result > 10000 then
			max = 9999;
		elseif result > 1000 then
			max = 999;
		else
			max = 99;
		end
		for i = 1, max do
			if not CheckFIDCollision(result,fixtureQuantity, idType) then
				result = result + 1;
			else
				return result;
			end
		end
	end

	idType = idType or 0; -- 0 = fixture ID
	local buttonContainer = overlay.Frame.Context.ContextFixtureID.FidSuggestions
	local buttons = buttonContainer:UIChildren();
	for i=1, #buttons do
		local btn = buttons[i]
		if btn.Text ~= "None" and btn.Text ~= "Suggestions" then
			local sug = CreateFIDSuggestion(btn,overlay.FixtureQuantity,idType)
			if sug then
				btn.Text = sug;
				btn.Enabled = true;
			else
				btn.Text = btn.SignalValue
				btn.Enabled = false;
			end
		end
	end
end

local function GetFidNextContext(fields, isCID)
	if fields.IDType.Visible and not isCID then
		return fields.IDType;
	elseif fields.Layer.Visible then
		return fields.Layer;
	elseif fields.Address1.Visible then
		return fields.Address1; 
	else
		return fields:GetOverlay().Frame.ButtonBlock.Done;
	end
end

signalTable.DoSelectSuggestedFID = function(caller,signal)
	local newVal = caller.text
	local overlay = caller:GetOverlay()

	if newVal == "None" then
		newVal = "";
	end

	assert(currentField)
	local target = currentField

	target.Content = newVal;
	local isCID = target.name =="ChannelID"
	if (isCID) then
		FindBestFocus(overlay.Frame.Fields.ChannelID)
	else
		FindBestFocus(overlay.Frame.Fields.FixtureID)
	end
end

-------------------------------------------
-- Local helper functions

local function CheckFIDCollisionsStatus(o)
	local f = o.Frame.Fields;
	local cnt = o.FixtureQuantity;
	
	local fid = o.FixtureFID;
	local fidCollision = false;
	if (fid ~= "None" and fid ~= "" and cnt ~= 0) then
		if (CheckFIDCollision(tonumber(fid), cnt) == false) then
			fidCollision = true;
		end
	end

	local cid = o.FixtureCID;
	local cidCollision = false;
	if (cid ~= "" and cnt ~= 0 and o.FixtureIDType ~= nil) then
		local t = o.FixtureIDType
		if t ~= nil then
			local idt = t:Index() - 1

			if (CheckFIDCollision(tonumber(cid), cnt, idt) == false) then
				cidCollision = true;
			end
		end
	end

	if FixtureIsMarker(o) and o.FixtureQuantity ~= 0 and cid ~= "" then
		local highestID = o.FixtureQuantity * tonumber(cid)
		if highestID > MAX_MARKER_ID then
			cidCollision = true;
			ShowWarning(o,"Marker ID not allowed: Maximum is "..MAX_MARKER_ID..".")
		end
	end

	changeColorErr(f.FixtureID, fidCollision)
	changeColorErr(f.ChannelID, cidCollision)
end

local function GetDmxSelectorDialog(o)
	local dmxSelector = o.Frame.Context.ContextAddress.AddrDMXSheetMode:Ptr(1);
	if (dmxSelector and dmxSelector:IsClass("UIDMXPatch")) then
		return dmxSelector;
	end	
	return nil;
end

local function ScrollToDMX(o,br)
	local addrAbs = o["FixtureAddress"..br];
	if (addrAbs >= 0) then
		local dmxSelector = GetDmxSelectorDialog(o);
		if (dmxSelector) then dmxSelector.SelectAbsoluteAddress('', addrAbs); end
	end
end

local function EnableControls(o)
	local f = o.Frame.Fields;
	f.FixtureName.Enabled = true;
	f.Quantity.Enabled = true;
	f.FixtureID.Enabled = true;
	f.IDType.Enabled = true;
	f.Layer.Enabled = true;
	f.Class.Enabled = true;
	o.Frame.ButtonBlock.Done.Enabled=true;
end

local function DisableControls(o)
	local f = o.Frame.Fields;
	f.FixtureName.Enabled = false;
	f.Quantity.Enabled = false;
	f.FixtureID.Enabled = false;
	f.IDType.Enabled = false;
	f.Layer.Enabled = false;
	f.Class.Enabled = false;
	o.Frame.ButtonBlock.Done.Enabled=false;

	--update visibility of the 'Break' address fields
	for i=1,8,1 do
		f["Br"..i].Visible=false;
		f["Address"..i].Visible=false;
	end
end

local function AreControlsActive(o)
	local f = o.Frame.Fields;
	return f.FixtureName.Enabled;
end

-------------------------------------------
-- Focus Handling

local function UpdateLastVisibleField(fields)
	-- we assume the ui objects are in corresponding order, we go backwards
	local children = fields:UIChildren()
	for i=#children, 1, -1 do
		local field = children[i]
		if field.visible and field.name ~= "Filler" then
			lastVisibleField = field;
			return;
		end
	end
end

signalTable.SendTab = function(caller,dummy,keyCode)

	if ((keyCode == nil) or (keyCode == Enums.KeyboardCodes.Enter) ) then
		if caller == lastVisibleField then
			FindBestFocus(caller:GetOverlay().Frame.ButtonBlock.Done);
		else
			FindNextFocus();
		end
	end
end

signalTable.FocusToContext = function(caller,dummy,keyCode,shift,ctrl,alt)

	local shiftOnly = shift and not ctrl and not alt;
	if (keyCode == Enums.KeyboardCodes.Right) then
		FindBestFocus(caller:GetOverlay().Frame.Context);
	elseif ((keyCode == Enums.KeyboardCodes.Up) or (shiftOnly and (keyCode == Enums.KeyboardCodes.Tab))) then
		FindNextFocus(true);--back
	elseif ((keyCode == Enums.KeyboardCodes.Down) or ((keyCode == Enums.KeyboardCodes.Tab) and not shiftOnly)) then
		FindNextFocus();--back
	elseif (keyCode == Enums.KeyboardCodes.Escape) then
		caller:GetOverlay().CloseCancel();
	end
end

signalTable.JumpNext = function(caller, modalResult, modalValue, ctxNext)
	
	if (modalResult == Enums.ModalResult.Cancel) then ctxNext:GetOverlay().CloseCancel(); end
	if(ctxNext.Visible == true) then
		FindBestFocus(ctxNext);
	else
		FindBestFocus(ctxNext:GetOverlay().Frame.ButtonBlock.Done);
	end
end

-------------------------------------------
-- Context Content Change

local function SetFixtureTypeSelectorVisible(o, value)
	o.Title.ColumnsFilters.visible = not value
	o.Frame.ContextFixtureTypeSelector.visible = value
	o.Frame.ContextFixtureTypeSelectorBackground.visible = value
	o.Frame.Fields.visible = not value
	o.Frame.VirtualKeyboard.visible = not value
	o.Frame.ButtonBlock.visible = not value
	o.Frame.Context.visible = not value
	o.Frame.Context:Changed() -- force placeholder size update
end

signalTable.SelectContext = function(caller, name)
	if (IsObjectValid(caller)) then
		if currentField ~= caller then
			changeColorEdited(currentField)
		end
		currentField = caller;
		UpdateActiveLabel()

		local o = caller:GetOverlay();
		local ctxs = o.Frame.Context;
		if ((name == nil) or (name == "")) then
			name = caller.Name;
		end

		if name == "ChannelID" then
			name = "FixtureID"
		end

		SetFixtureTypeSelectorVisible(o,(name == "FixtureTypeSelector"))

		if smallDisplay then
			o.Frame.Context.visible = false;
		end

		ctxs.ChangeActive("Context"..name);
	end
end

signalTable.LineEditSelectAll = function(caller)
	if (IsObjectValid(caller)) then 
		caller.SelectAll(); 
		signalTable.SelectContext(caller);
	end
end

signalTable.LineEditSelectAllAddr = function(caller)
	if (IsObjectValid(caller)) then 
		caller.SelectAll(); 
		signalTable.SelectContext(caller, "Address");
		local o = caller:GetOverlay();
		coroutine.yield(0.1);--needed because of the visibility issues
		ScrollToDMX(o, tonumber(caller.SignalValue));
	end
end

signalTable.LineEditDeSelect = function(caller,dummy,newFocus)
	local o = nil;
	if (IsObjectValid(newFocus)) then o = newFocus:GetOverlay(); end;
	if (IsObjectValid(caller)) then caller.DeSelect(); end
end

signalTable.IDTypeSelectedInternal = function(val, ctxNext)
	local o = ctxNext:GetOverlay();

	-- set new ID Type:
	o.FixtureIDType = val;
	o.Frame.Fields.IDType.Text = IsObjectValid(val) and val.Name or ""

	local enableCID = val and val:Index() ~= 1
	local cidInput = o.Frame.Fields.ChannelID

	if enableCID then
		cidInput.Enabled=true
		if not cidEdited then
			lastCid = val.MaxID + 1
			o.FixtureCID = lastCid
		end
	else
		cidInput.Enabled=false
		lastCid = 0;
		o.FixtureCID=lastCid
		val = Patch().IDTypes.Fixture;
		if not fidEdited then
			lastFid = val.MaxID + 1
			o.FixtureFID = lastFid
		end
	end

	CheckFIDCollisionsStatus(o)
end

signalTable.IDTypeSelected = function(caller, modalResult, modalValue, ctxNext)
	signalTable.JumpNext(caller, modalResult, modalValue, ctxNext);
	signalTable.IDTypeSelectedInternal(StrToHandle(caller.Value), ctxNext)
end

signalTable.LayerSelectedInternal = function(val, ctxNext)
	local o = ctxNext:GetOverlay();
	local btn = o.Frame.Fields.Layer;
	if (IsObjectValid(val)) then
		o.FixtureLayer = val;
		btn.Text = val.Name;
	else
		o.FixtureLayer = nil;
		btn.Text = "";
	end
end

signalTable.LayerSelected = function(caller, modalResult, modalValue, ctxNext)
	signalTable.JumpNext(caller, modalResult, modalValue, ctxNext);
	signalTable.LayerSelectedInternal(StrToHandle(caller.Value), ctxNext)
end

signalTable.ClassSelectedInternal = function(val, ctxNext)
	local o = ctxNext:GetOverlay();
	local btn = o.Frame.Fields.Class;
	if (IsObjectValid(val)) then
		o.FixtureClass = val;
		btn.Text = val.Name;
	else
		o.FixtureClass = nil;
		btn.Text = "";
	end
end

signalTable.ClassSelected = function(caller, modalResult, modalValue, ctxNext)
	signalTable.JumpNext(caller, modalResult, modalValue, ctxNext);
	signalTable.ClassSelectedInternal(StrToHandle(caller.Value), ctxNext);
end

-------------------------------------------
-- Dmx Address Update

local function AutoUpdatePatch(o,force)
	local function UpdateDMXAddress(o, start, footprint, count, breakIdx)
		local addr, last = FindBestDMXPatchAddr(Patch(), start, footprint, count);
		if (addr >= 0) then
			lastAddr[breakIdx] = addr -- + 1?
			o["FixtureAddress"..breakIdx] = addr;
			o.Frame.Fields["Address"..breakIdx].Content = o:Get("FixtureAddress"..breakIdx,Enums.Roles.Display)
		end
	
		return addr, last;
	end

	local mode = o.DmxMode;
	if (IsObjectValid(mode) and (addrEdited ~= true or force)) then
		local prevAddrEdited = addrEdited;
		local fp = mode.DMXFootprint;
		local cnt = o.FixtureQuantity;
		local next, last = 0, 0;
		if preSetDmxUniverse ~= nil and (addrEdited ~= true or force) then
			next = preSetDmxUniverse * 512;
		end
		for i=1,8,1 do
			local v = fp[i].valid;
			if (v) then
				next, last = UpdateDMXAddress(o, next, fp[i].size, cnt, i);
				if (i == 1) then ScrollToDMX(o, i); end
				if (next >= 0) then next = last; end;
			end
		end
		addrEdited = prevAddrEdited;
	end
end

signalTable.FixtureTypeSelected = function(caller, modalResult, modalValue, ctxNext)
	if (modalResult == Enums.ModalResult.Cancel) then ctxNext:GetOverlay().CloseCancel(); end
	signalTable.FixtureTypeSelectedInternal(StrToHandle(caller.Value), ctxNext)
end

signalTable.FixtureTypeSelectedInternal = function(mode, ctxNext)
	local o = ctxNext:GetOverlay();
	o.DmxMode = mode;

	local dmxSelector = GetDmxSelectorDialog(o);
	if (dmxSelector) then dmxSelector.DMXMode = mode; end

	if (IsObjectValid(mode)) then
		EnableControls(o);
		o.Frame.Fields.FixtureTypeSelector.Text = mode:Parent():Parent().Name;
		o.Frame.Fields.FixtureTypeModeInfo.Text = mode.Name;
		o.Frame.Fields.FixtureTypeChanInfo.Text = mode.TotalFootPrint;
		changeColorEdited(o.Frame.Fields.FixtureTypeModeInfo)

		o.Frame.Fields.FixtureTypeModeDesc.Visible = true;
		o.Frame.Fields.FixtureTypeChanDesc.Visible = true;
		o.Frame.Fields.FixtureTypeModeInfo.Visible = true;
		o.Frame.Fields.FixtureTypeChanInfo.Visible = true;

		local ft = mode:Parent():Parent();
		if (ft.ShortName:len() > 0) then
			o.FixtureName = CreateIndexName(o, ft.ShortName)
		else
			o.FixtureName = CreateIndexName(o, ft.Name)
		end
		resetColor(o.Frame.Fields.FixtureName)

		local fp = mode.DMXFootprint;
		local fields = o.Frame.Fields;
		--update visibility of the 'Break' address fields
		for i=1,8,1 do
			local v = fp[i].valid;
			fields["Br"..i].Visible=v;
			fields["Address"..i].Visible=v;
		end

		if FixtureIsMarker(o) then
			signalTable.IDTypeSelectedInternal(Patch().IDTypes.MArker,o)
		end

		UpdateNameSuggestions(o)
		AutoUpdatePatch(o);
		signalTable.CheckQuantityAllowed(o);
	end

	UpdateLastVisibleField(o.Frame.Fields)
	FindBestFocus(ctxNext);
end

signalTable.FIDSelected = function(caller, modalResult, modalValue, ctxNext)
	if (modalResult == Enums.ModalResult.Cancel) then ctxNext:GetOverlay().CloseCancel(); end
	FindBestFocus(ctxNext);
	local o = ctxNext:GetOverlay()
	o.FixtureFID = caller.Value
end

-------------------------------------------
-- Context Loading

local function CommonContextConfig(ctx, hideTitle)
	ctx.MinSize ="0,0";--no min size, we need to squeeze it in
	ctx.WantsModal = false;
	ctx.AutoClose = false;
	ctx.AdjustInitialPosition = false;
	ctx.StayAlwaysVisible = false;
	if (hideTitle == true) then 
		ctx.TitleBar.Visible = false; 
		ctx.Frame.Texture = Root().GraphicsRoot.TextureCollect.Textures["frame15"]; 
	end
end

local function LoadFixtureTypeContextHelper(target, fields)
	local ftImport = Root().Menus.FixtureTypeImport;
	if (ftImport) then
		local ftImportUI = ftImport:CommandCall(target,false--[[don't search focuse]],false--[[no buddies are allowed]]);
		if (ftImportUI) then
			ftImportUI:InputSetAdditionalParameter("Mode", "Select");
			ftImportUI:InputSetAdditionalParameter("AdjustSize", "No");
			ftImportUI:InputSetAdditionalParameter("Embedded", "Yes");
			CommonContextConfig(ftImportUI, false);
			ftImportUI.W="100%";
			ftImportUI:OverlaySetCloseCallback("FixtureTypeSelected", fields.FixtureName);
			-- adjustments so that it fits the whole overlay
			ftImportUI.TitleBar.Visible = false
			ftImportUI.Frame.Texture = ""
			ftImportUI.Margin = "-7,0,0,0"
			ftImportUI.BackColor="Global.Transparent"
		end
	end
end

local function LoadIDTypeContextHelper(target, fields)
	local assignEditor = Root().Menus.AssignmentEditor;
	if (assignEditor) then
		local assignEditorUI = assignEditor:CommandCall(target,false--[[don't search focuse]],false--[[no buddies are allowed]]);
		if (assignEditorUI) then
			assignEditorUI.Frame.Selector.ProvideEmpty = false;
			assignEditorUI.Frame.Selector:Ptr(1):Ptr(1).Size = 0; -- hide AssignmentUITab
			assignEditorUI:InputSetAdditionalParameter("SpecialCase", "None\nclear\nButton");
			assignEditorUI:InputSetAdditionalParameter("DestinationClass", "Fixture");
			assignEditorUI:InputSetAdditionalParameter("DestinationProperty", "IDType");
			assignEditorUI:InputSetAdditionalParameter("ForceReturnValue", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Editable", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Embedded", "Yes");
			CommonContextConfig(assignEditorUI, false);
			assignEditorUI.W="100%";
			assignEditorUI.H="100%";

			if fields.ChannelID.Visible == true then
				assignEditorUI:OverlaySetCloseCallback("IDTypeSelected", fields.ChannelID);
			else
				assignEditorUI:OverlaySetCloseCallback("IDTypeSelected", fields.Address1);
			end
		end
	end
end

local function LoadLayerContextHelper(target, fields)
	local assignEditor = Root().Menus.AssignmentEditor;
	if (assignEditor) then
		local assignEditorUI = assignEditor:CommandCall(target,false--[[don't search focuse]],false--[[no buddies are allowed]]);
		if (assignEditorUI) then
			assignEditorUI.Frame.Selector.ProvideEmpty = false;
			assignEditorUI.Frame.Selector:Ptr(1):Ptr(1).Size = 0;
			assignEditorUI:InputSetAdditionalParameter("SpecialCase", "None\nclear\nButton");
			assignEditorUI:InputSetAdditionalParameter("DestinationClass", "Fixture");
			assignEditorUI:InputSetAdditionalParameter("DestinationProperty", "Layer");
			assignEditorUI:InputSetAdditionalParameter("ForceReturnValue", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Editable", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Embedded", "Yes");
			CommonContextConfig(assignEditorUI, false);
			assignEditorUI.W="100%";
			assignEditorUI.H="100%";
			assignEditorUI:OverlaySetCloseCallback("LayerSelected", fields.Class);
		end
	end
end

local function LoadClassContextHelper(target, fields)
	local assignEditor = Root().Menus.AssignmentEditor;
	if (assignEditor) then
		local assignEditorUI = assignEditor:CommandCall(target,false--[[don't search focuse]],false--[[no buddies are allowed]]);
		if (assignEditorUI) then
			assignEditorUI.Frame.Selector.ProvideEmpty = false;
			assignEditorUI.Frame.Selector:Ptr(1):Ptr(1).Size = 0;
			assignEditorUI:InputSetAdditionalParameter("SpecialCase", "None\nclear\nButton");
			assignEditorUI:InputSetAdditionalParameter("DestinationClass", "Fixture");
			assignEditorUI:InputSetAdditionalParameter("DestinationProperty", "Class");
			assignEditorUI:InputSetAdditionalParameter("ForceReturnValue", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Editable", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Embedded", "Yes");
			CommonContextConfig(assignEditorUI, false);
			assignEditorUI.W="100%";
			assignEditorUI.H="100%";
			assignEditorUI:OverlaySetCloseCallback("ClassSelected", fields.Address1);
		end
	end
end

local function LoadAddressContextHelper(target, fields)
	local dmxSelector = Root().Menus.DMXAddressSelector;
	local phSheet = target.AddrDMXSheetMode;

	if (dmxSelector) then
		local dmxSelectorUI = dmxSelector:CommandCall(
											phSheet,
											false,--don't search focuse,
											false--no buddies are allowed
											);
		if (dmxSelectorUI) then
		--turning off moving possibilities
			dmxSelectorUI.TitleBar.Title.MoveStart = ":";
			dmxSelectorUI.TitleBar.Title.Move = ":";
			dmxSelectorUI.TitleBar.Title.MoveEnd = ":";
			dmxSelectorUI.TitleBar.Title.Text = "";
			dmxSelectorUI.TitleBar:Ptr(2):Ptr(1).MinSize = 0;
			dmxSelectorUI.UniverseGrid.DoubleClicked="DoSelect"; -- select directly on click
			dmxSelectorUI:InputSetAdditionalParameter("SettingsName", "DMXAddressSettings");
			dmxSelectorUI:InputSetAdditionalParameter("DefaultColumnCount", "8");
			dmxSelectorUI:InputSetAdditionalParameter("Embedded", "Yes");
			CommonContextConfig(dmxSelectorUI, false);
			dmxSelectorUI.MinSize="500,0";
			dmxSelectorUI:OverlaySetCloseCallback("AddressSelected", fields:Parent().ButtonBlock.Done);
		end
	end
end

local function LoadContextHelpers(o)
	local ctx = o.Frame.Context;
	local f = o.Frame.Fields;

	LoadFixtureTypeContextHelper(o.Frame.ContextFixtureTypeSelector, f);
	LoadIDTypeContextHelper(ctx.ContextIDType, f);
	LoadLayerContextHelper(ctx.ContextLayer, f);
	LoadClassContextHelper(ctx.ContextClass, f);
	LoadAddressContextHelper(ctx.ContextAddress, f);
	o:Changed(); -- force position update
end

-------------------------------------------
-- Dmx Addr Checks

local function CheckAddressCollisionsStatus(o)
	local f = o.Frame.Fields;
	for i = 1,8 do
		local addrField = f["Address"..i];
		if (addrField.Visible) then
			local collision = o["AddrCollision"..i]
			changeColorErr(addrField,collision)
		end
	end
end

signalTable.AddressSelected = function(caller, modalResult, modalValue, ctxNext)
	local o = ctxNext:GetOverlay()
	if (modalResult == Enums.ModalResult.Cancel) then o.CloseCancel(); end

	if string.find(currentField.name,"Address") then
		local fieldLastChar = string.sub(currentField.name,-1);
		local idx = tonumber(fieldLastChar)
		local next = o.Frame.Fields["Address"..(idx + 1)];
		if (next and next.Visible == true) then
			FindBestFocus(next);
		else
			FindBestFocus(ctxNext);
		end
		currentField.Content = caller.Value;
	else
		ErrEcho("AddressSelected called with wrong target field!")
	end
end

signalTable.AddressNumInputDone = function(caller, modalResult, modalValue, ctxNext)
	if (modalResult == Enums.ModalResult.Cancel) then ctxNext:GetOverlay().CloseCancel(); end

	local t = caller.Frame.InputField.Target;
	local idx = tonumber(t.SignalValue);
	local o = t:GetOverlay();
	local next = o.Frame.Fields["Address"..(idx + 1)];
	if (next and next.Visible == true) then
		FindBestFocus(next);
	else
		FindBestFocus(ctxNext);
	end
end

signalTable.CheckQuantityAllowed = function(o)
	local newVal = o.FixtureQuantity
	local quanIsValid = (newVal ~= "" and tonumber(newVal) ~= 0)
	local mode = o.DmxMode
	if quanIsValid and FixtureIsMarker(o) then
		local used = mode:Parent():Parent().Used
		if (tonumber(newVal) + used) > MAX_MARKERS_TOTAL then

			ShowWarning(o,"Maximum of "..MAX_MARKERS_TOTAL.." MArkers allowed!")
			quanIsValid = false;
		end
	end
	if (IsObjectValid(mode)) then
		o.Frame.ButtonBlock.Done.Enabled = quanIsValid
	end
	changeColorErr(o.Frame.Fields.Quantity,not quanIsValid)
end

signalTable.QuantityChanged = function(caller, newVal)
	local o = caller:GetOverlay();
	local dmxSelector = GetDmxSelectorDialog(o);
	if (dmxSelector and newVal ~= "") then dmxSelector.FixtureCount = tonumber(newVal); end

	AutoUpdatePatch(o);
	CheckFIDCollisionsStatus(o);
	UpdateFIDSuggestions(o);
	CheckAddressCollisionsStatus(o);
	signalTable.CheckQuantityAllowed(o);
end

signalTable.FIDChanged = function(caller, newVal)
	if newVal ~= lastFid then
		lastFid = newVal
		fidEdited = true
	end
	CheckFIDCollisionsStatus(caller:GetOverlay());
end

signalTable.CIDChanged = function(caller, newVal)
	local conv_newVal = newVal
	if(conv_newVal == "") then
		conv_newVal = 0
	end

	if conv_newVal ~= lastCid then
		lastCid = conv_newVal
		cidEdited = true
	end
	CheckFIDCollisionsStatus(caller:GetOverlay());
end

local function CheckIfDmxModeStillValid(_,_, ctx)
	if ctx then
		local isInvalid = (IsObjectValid(ctx.DmxMode) ~= true) and IsObjectValid(ctx) and AreControlsActive(ctx)

		changeColorErr(ctx.Frame.Fields.FixtureTypeModeInfo, isInvalid)

		if isInvalid then
			--mode is invalid, make sure all is disabled and we're at step 1
			DisableControls(ctx);
			ctx.Frame.Fields.FixtureTypeSelector.Text = "";
			ctx.Frame.Fields.FixtureTypeModeInfo.Text = "";
			ctx.Frame.Fields.FixtureTypeChanInfo.Text = "";
			ctx.FixtureName="";

			signalTable.SelectContext(ctx.Frame.Fields.FixtureTypeSelector);
			FindBestFocus(ctx.Frame.Context);
		end
	end
end

local function GetSplitGridFirstSelected(m)
	local g = m.Content.SplitFrame.FilterBy.ObjGrid;
	local gridSel = g:GridGetSelection();
	local selItems = gridSel.SelectedItems;
	if #selItems > 0 then
		return selItems[1].row
	end
	return nil
end

local function InitStartingFixtureWizardValues(o)
	preSetDmxUniverse = nil

	local main = o:FindParent("MainDlgFixtureSetup");
	if main == nil then return; end

	if IsInPatchSplitView() ~= true then return; end

	local subTabs = main.PatchModesCont.PatchModes;
	local splitBy = subTabs.SelectedItemValueStr;
	if splitBy == "SplitViewLayers" then
		local sel = GetSplitGridFirstSelected(main);
		if sel ~= nil then o.FixtureLayer = IntToHandle(sel) end
	elseif splitBy == "SplitViewClasses" then
		local sel = GetSplitGridFirstSelected(main);
		if sel ~= nil then o.FixtureClass = IntToHandle(sel) end
	elseif splitBy == "SplitViewIDTypes" then
		local sel = GetSplitGridFirstSelected(main);
		if sel ~= nil then o.FixtureIDType = IntToHandle(sel) end
	elseif splitBy == "SplitViewDMXUniverses" then
		local sel = GetSplitGridFirstSelected(main);
		if sel ~= nil then 
			local dmxUniv = IntToHandle(sel)
			preSetDmxUniverse = dmxUniv:Index() - 1
		end
	elseif splitBy == "SplitViewFixtureTypes" then
		local sel = GetSplitGridFirstSelected(main);
		if sel ~= nil then 
			local dm = nil;
			local ftFake = IntToHandle(sel)
			if ftFake:GetClass() == "FixtureTypeFake" then
				local ft = ftFake.FTRef;
				dm = ft.DMXModes:Ptr(1)
			elseif ftFake:GetClass() == "DMXModeFake" then
				dm = ftFake.DMRef;
			end
			if dm ~= nil and dm:Parent():Parent().Universal ~= true then
				o.DmxMode = dm
			end
		end
	end
end

-------------------------------------------
-- OnLoad

local function AdjustSize(o)
	local d = o:GetDisplay();
	local dRct = d.AbsRect;

	local DEBUG_SMALL_DISPLAY = false; -- ACTIVATE / DEACTIVATE FOR TESTING

	if DEBUG_SMALL_DISPLAY then
		o.MaxSize="800,480"
		smallDisplay = true;
	else
		local smallW, smallH = 1100, 650;
		smallDisplay = dRct.w <= smallW or dRct.h <= smallH

		if smallDisplay then
			-- rpu limitation
			o.maxsize = string.format("%d,%d",dRct.w,dRct.h);
		else
			o.minsize = string.format("%d,%d",smallW,smallH);
		end

		o.w, o.h = dRct.w, dRct.h;
		o.RelativeToDisplay=false; -- reset this, otherwise resizing is not working correctly
	end

end

signalTable.InsertFixturesWizardLoaded = function(caller,status,creator)
	AdjustSize(caller)
	local p = Patch();
	InitStartingFixtureWizardValues(caller)

	local fields = caller.Frame.Fields;
	fields.FixtureName.Target=caller;
	fields.Quantity.Target=caller;
	fields.FixtureID.Target=caller;
	fields.ChannelID.Target=caller;
	caller.Frame.Context.ContextAddress.PatchButtons.Offset.Target=caller;

	local idt = caller.FixtureIDType
	if idt ~= nil and idt:Index() ~= 1 then
		caller.FixtureCID = idt.MaxID + 1
	else
		-- reset to Fixture ID Type
		signalTable.IDTypeSelectedInternal(p.IDTypes.Fixture, caller)
	end

	caller.FixtureFID = p.IDTypes.Fixture.MaxID + 1
	lastFid = caller.FixtureFID
	addrEdited = false;
	fidEdited = false;
	cidEdited = false;

	currentField = fields.FixtureTypeSelector

	local GridColumnFilterObj = CurrentProfile().TemporaryWindowSettings.PatchEditorSettings:Ptr(1)
	HookObjectChange(signalTable.SelectedFilterChangedCallback, GridColumnFilterObj, my_handle:Parent(), caller);

	local filter = GridColumnFilterObj.SelectedFilter;
	caller.Title.ColumnsFilters.Target = GridColumnFilterObj

	signalTable.SelectedFilterChangedCallback(GridColumnFilterObj,nil,caller);

	LoadContextHelpers(caller);

	if caller.FixtureLayer ~= nil then
		signalTable.LayerSelectedInternal(caller.FixtureLayer, caller)
	end
	if caller.FixtureClass ~= nil then
		signalTable.ClassSelectedInternal(caller.FixtureClass, caller)
	end
	if caller.FixtureIDType ~= nil then
		signalTable.IDTypeSelectedInternal(caller.FixtureIDType, caller)
	end

	if caller.DmxMode and IsObjectValid(caller.DmxMode) then
		signalTable.FixtureTypeSelectedInternal(caller.DmxMode, caller.Frame.Fields.FixtureName);
	else
		signalTable.SelectContext(caller.Frame.Fields.FixtureTypeSelector);
		FindBestFocus(caller.Frame.Context);
	end

	HookObjectChange(CheckIfDmxModeStillValid, p.FixtureTypes, my_handle:Parent(), caller);
end

signalTable.AddrUserChanged = function(caller, newCnt)
	if (caller.Visible) then
		local o = caller:GetOverlay();
		local idx = tonumber(caller.SignalValue);
		if (o["FixtureAddress"..idx] ~= lastAddr[idx]) then
			addrEdited = true;
			lastAddr[idx] = o["FixtureAddress"..idx];
		end

		o["FixtureAddress"..idx] = newCnt

		CheckAddressCollisionsStatus(o);
		ScrollToDMX(o, idx);
	end
end

signalTable.Done = function(caller, dummy)
	local o = caller:GetOverlay();
	local ctxIsParent = o.AdditionalArgs.isParent == "y";
	local ctx = o.Context;
	if (ctxIsParent ~= true) then ctx = ctx:Parent(); end;
	local currentPos = ctx;
	local currentCount = currentPos:Count();
	local f = o.Frame.Fields;
	local requestedCount = o.FixtureQuantity;

	if ((requestedCount > 0) and (o.DmxMode) and IsObjectValid(o.DmxMode)) then
		local addFixturesParam = {}

		local m = o.DmxMode;
		local mName = "unknown";
		if (m) then mName = m:Parent():Parent().Name.." "..m.Name; end;
		addFixturesParam.mode = m
		addFixturesParam.undo = "Creating new "..requestedCount.." '"..mName.."' fixtures"
		addFixturesParam.amount = requestedCount
		addFixturesParam.parent = currentPos

		--create fixtures
		if (ctxIsParent ~= true) then
			--we need to insert
			addFixturesParam.insert_index = o.Context:Index()
		end

		--prepare one big set command to set different properties
		local idt = o.FixtureIDType;
		if (idt) then
			addFixturesParam.idtype = idt.name;
		end

		local fid = o.FixtureFID;
		if (fid ~= "None") then
			addFixturesParam.fid = tostring(fid);
		end

		local cid = o.FixtureCID;
		if (cid ~= "None") then
			addFixturesParam.cid = cid;
		end

		local fname = o.FixtureName;
		if (fname:len() > 0) then
			addFixturesParam.name = fname;
		end

		local layer = o.FixtureLayer;
		if (layer) then
			addFixturesParam.layer = layer.name;
		end

		local cl = o.FixtureClass;
		if (cl) then
			addFixturesParam.class = cl.name;
		end

		addFixturesParam.patch = {}
		for i=1,8 do
			local a = o:Get("FixtureAddress"..i,Enums.Roles.Display)
			if a ~= "" then
				addFixturesParam.patch[i] = a
			end
		end

		local fOff = o.PatchOffset;
		if (fOff > 0) then
			addFixturesParam.offset = fOff;
		end

		o.Enabled = false;
		if AddFixtures(addFixturesParam) == true then
			preSetDmxUniverse = nil
			o.Value = "Ok";
			o.Close();
		else
			o.Enabled = true;
			MessageBox({title = "Cannot create fixtures", message = "Failed to create fixtures", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
		end
	else
		MessageBox({title = "Cannot create fixtures", message = "Cannot create fixtures: either mode is not specified or quantity", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
	end
end

signalTable.DoPatchToNone = function(caller)
	currentField.Content = ""
	changeColorEdited(currentField)
end

signalTable.DoPatchNextAddr = function(caller)
	local o = caller:GetOverlay();
	preSetDmxUniverse = nil; -- reset previous set dmx universe
	AutoUpdatePatch(o,true);
	changeColorEdited(currentField)
end

signalTable.DoPatchNextUniv = function(caller)
	local o = caller:GetOverlay();
	-- adjust the dmxUniverse to the next free one:
	local universes = Patch().DmxUniverses:Children();
	for idx,univ in ipairs(universes) do
		local alreadyPatchedFixtures = univ.Used
		if alreadyPatchedFixtures == 0 then
			preSetDmxUniverse = idx - 1;
			AutoUpdatePatch(o,true);
			changeColorEdited(currentField)
			return;
		end
	end
end

-----------------------------------------------------------
-- ChangeModeViaPopup

signalTable.ChangeModeViaPopup = function(caller,_,_,x,y)
	local o = caller:GetOverlay()
	local currentMode = o.DmxMode
	local allModes = currentMode:Parent():Children();

	local itemList = {};
	for _,m in ipairs(allModes) do
		itemList[#itemList + 1] = {"str", m.Name, HandleToStr(m)}
	end

	x = caller.AbsRect.x + x + 25;
	y = caller.AbsRect.y + y + 100;

	local _, newMode = PopupInput({
		title="DmxMode",
		caller=caller,
		items=itemList,
		selectedValue=HandleToStr(currentMode),
		x=x,
		y=y
	});
	if newMode then
		local o = caller:GetOverlay()
		signalTable.FixtureTypeSelectedInternal(StrToHandle(newMode), o.Frame.Fields.FixtureName);
	end
end

-----------------------------------------------------------
-- AdjustFIDContent

signalTable.OnFIDGetFocus = function(caller)
	signalTable.LineEditSelectAll(caller)
	signalTable.AdjustContextFixtureID(caller)
end

signalTable.AdjustContextFixtureID = function(field)
	local o = field:GetOverlay()
	local idType = 0;
	if field.name == "ChannelID" then
		idType = o.FixtureIDType.index - 1
	end
	UpdateFIDSuggestions(o,tonumber(idType))
end

-----------------------------------------------------------
-- Keyboard Actions

signalTable.ClearCurrentField = function(caller)
	local n = currentField.Name;
	if n == "FixtureName" then
		currentField.Content = ""
	elseif n == "Quantity" then
		currentField.Content = "0"
		currentField.SelectAll()
	elseif n == "FixtureID" or n == "ChannelID" then
		currentField.Content = ""
		currentField.SelectAll()
	elseif n:find("Address") == 1 then
		currentField.Content = ""
		currentField.SelectAll()
	end
end

-----------------------------------------------------------
-- "Full" vs. "Condensed"

signalTable.SelectedFilterChangedCallback = function(obj,_,o)
	local showFullFields = obj.SelectedFilter == 0--[["Full"]] and not smallDisplay
	local fields = o.Frame.Fields;
	
	fields.ChannelID.Visible = showFullFields;
	fields.ChannelIDLabel.Visible = showFullFields;
	fields.IDType.Visible = showFullFields;
	fields.IDTypeLabel.Visible = showFullFields;
	fields.Layer.Visible = showFullFields;
	fields.LayerLabel.Visible = showFullFields;
	fields.Class.Visible = showFullFields;
	fields.ClassLabel.Visible = showFullFields;

	UpdateLastVisibleField(fields)
end