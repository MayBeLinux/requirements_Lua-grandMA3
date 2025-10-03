local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local FocusedSequenceSheet = nil;
local hookId = {};


-- --------------------------------------------------------
--
-- --------------------------------------------------------
local function UnhookAll()
	for _,id in ipairs(hookId) do
		Unhook(id);
	end
	hookId = {};
end

local function GetTargetGrid(sheet)
	if sheet.Frame.Cue == nil then
		return sheet.Frame.SequenceGrid
	else
		return sheet.Frame.Cue.SequenceGrid
	end
end
				
-- --------------------------------------------------------
--
-- --------------------------------------------------------

signalTable.BarLoaded = function(caller,status,window)
	if(window:GetClass() == "SequenceWindow") then
		caller.LinkedObject = window
	end
	FocusedSequenceSheet = caller.LinkedObject

	if(FocusedSequenceSheet ~= nil) then
		signalTable.SetEncoderPage(caller)

		local GridObj = GetTargetGrid(FocusedSequenceSheet);
		signalTable.TargetWindowChanged(caller);

		UnhookAll();

		local id = HookObjectChange(signalTable.CueChanged, GridObj:GridGetSettings(), my_handle:Parent(), caller);
		table.insert(hookId, id);
		if(FocusedSequenceSheet.WindowSettings ~= nil) then
			local id = HookObjectChange(signalTable.RefreshEncoderPage, FocusedSequenceSheet.WindowSettings, my_handle:Parent(), caller)
			table.insert(hookId, id);
		end
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.CueChanged = function(ColumnGridSelection, dummy, EncoderBarObj)
	if(FocusedSequenceSheet ~= nil) then
		signalTable.TargetWindowChanged(EncoderBarObj, dummy, FocusedSequenceSheet)
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.TargetWindowChanged = function(EncoderBarObj)
	if(FocusedSequenceSheet ~= nil) then
		local Grid = GetTargetGrid(FocusedSequenceSheet);
		local Lower=EncoderBarObj.InnerBox.Lower;
		local Upper=EncoderBarObj.InnerBox.Upper;
		local Sequence = Grid.TargetObject

		local sequ_addr=ToAddr(Sequence);
	
		EncoderBarObj.InnerBox.Pages.Target = EncoderBarObj

		if (sequ_addr ~= nil) then
			Upper.EditBtn.SignalValue="Edit " .. sequ_addr
			Upper.EditBtn.Text="Edit " .. Sequence.Name

			Upper.NavButtons.FastBackBtn.SignalValue = "<<< " ..sequ_addr   
			Upper.NavButtons.BackBtn.SignalValue     = "Go- " .. sequ_addr  
			Upper.NavButtons.PauseBtn.SignalValue    = "Pause " .. sequ_addr
			Upper.NavButtons.StopBtn.SignalValue     = "Off " .. sequ_addr  
			Upper.NavButtons.NextBtn.SignalValue     = "Go+ " .. sequ_addr  
			Upper.NavButtons.FastNextBtn.SignalValue = ">>> " .. sequ_addr  
		end

		local PageButton = EncoderBarObj.InnerBox.Pages

		signalTable.EncoderPageChanged(PageButton,"",EncoderBarObj.EncoderFunction)	

		signalTable.DetectCurrCue(Upper.CueEdit.CurrCue)
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.RefreshEncoderPage = function(WindowSettings,dummy,EncoderBarObj)
	signalTable.SetEncoderPage(EncoderBarObj)
	signalTable.EncoderPageChanged(EncoderBarObj.InnerBox.Pages,"",EncoderBarObj.EncoderFunction)
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SetEncoderPage = function(EncoderBarObj)
	if(FocusedSequenceSheet ~= nil and FocusedSequenceSheet.WindowSettings ~= nil) then
		local curFunc = EncoderBarObj.EncoderFunction;
		--Echo("Here: "..curFunc);

		local CheckPage = function(set, fun)
			--Echo("CheckPage: set:"..set.."; fun:"..fun.."; winset:"..tostring(FocusedSequenceSheet.WindowSettings[set]).."; EncFunc="..tostring(Enums.EncoderFunction[fun]));
			if(FocusedSequenceSheet.WindowSettings[set] ~= true and curFunc == Enums.EncoderFunction[fun]) then
				EncoderBarObj.EncoderFunction = "Data Edit";
				return true;
			end

			return false;
		end

		--[[
		local adjusted = false;
		adjusted = CheckPage("CueTiming", "CueTiming");
		if (adjusted ~= true) then adjusted = CheckPage("PresetTiming", "PresetTiming1"); end
		if (adjusted ~= true) then adjusted = CheckPage("PresetTiming", "PresetTiming2"); end
		if (adjusted ~= true) then adjusted = CheckPage("PresetTiming", "PresetTiming3"); end
		if (adjusted ~= true) then adjusted = CheckPage("PresetTiming", "PresetTiming4"); end
		if (adjusted ~= true) then adjusted = CheckPage("Cmd", "Cmd"); end
		if (adjusted ~= true) then adjusted = CheckPage("Loops", "Loops"); end
		if (adjusted ~= true) then adjusted = CheckPage("CueSettings", "CueSettings"); end
]]
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.EncoderPageChanged = function(PageButton,dummy,ButtonValue)
	local up = CurrentProfile();
	local EncoderBar = up.EncoderBarPool:Ptr(1);
	local EncoderBanks = EncoderBar:Count();

	local EncoderBarObj = PageButton:Parent():Parent()
	if(FocusedSequenceSheet ~= nil) then
		local Grid = GetTargetGrid(FocusedSequenceSheet)
		local Lower=EncoderBarObj.InnerBox.Lower;

		Lower.Encoder5a.Target=FocusedSequenceSheet;
		Lower.Encoder5b.Target=FocusedSequenceSheet;
		
		Lower.Encoder1a.Target=Grid;
		Lower.Encoder1b.Target=Grid;
		Lower.Encoder2a.Target=Grid;
		Lower.Encoder2b.Target=Grid;
		Lower.Encoder3a.Target=Grid;
		Lower.Encoder3b.Target=Grid;
		Lower.Encoder4a.Target=Grid;
		Lower.Encoder4b.Target=Grid;

		local EncA = { }
		local EncB = { }
		local PageName = function(idx)
			local p = EncoderBar:Ptr(idx);
			if (p ~= nil) then return p.Name; end;
			return "";
		end
		local CreatePresetTimingEncoders = function(i)
			local EncoderIndex = 1
			for EncoderIndex = 1, 4 do
				if(i < EncoderBanks) then
					EncA[EncoderIndex] =  {"Preset"..i.."Fade"   ,1, "PresetTiming", PageName(i) .. "Fade"  }
					EncB[EncoderIndex] = {"Preset"..i.."Delay"  ,1, "PresetTiming", PageName(i) .. "Delay" }
				else
					EncA[EncoderIndex]={"Preset"..i.."Fade"  ,0, "PresetTiming", "" }
					EncB[EncoderIndex]={"Preset"..i.."Delay" ,0, "PresetTiming", ""}
				end
				i = i + 1
				EncoderIndex = EncoderIndex + 1
			end
		end
		-- EncXy: 1. Property, 2. Visibility, 3. System, 4. Name
		if(EncoderBarObj.EncoderFunction == "CueSettings") then
			EncA[1]={"TrigTime",1, "CueTiming", ""}
			EncB[1]={"TrigType",1, "CueTiming", ""}
			EncA[2]={"Release" ,0, "CueTiming", ""}
			EncB[2]={"Assert"  ,0, "CueTiming", ""}
			EncA[3]={"PresetMode",0, "CueTiming", ""}
			EncB[3]={"Duration" ,0, "CueTiming", ""}
			EncA[4]={"",0, "CueTiming", ""}
			EncB[4]={"",0, "CueTiming", ""}

		elseif(EncoderBarObj.EncoderFunction == "CueTiming") then
			EncA[1]={"CueInFade" ,1, "CueTiming", ""}
			EncB[1]={"CueOutFade"   ,1, "CueTiming", ""}
			EncA[2]={"CueInDelay",1, "CueTiming", ""}
			EncB[2]={"CueOutDelay"  ,1, "CueTiming", ""}
			EncA[3]={"SnapDelay" ,1, "CueTiming", ""}
			EncB[3]={"IndivFade" ,0, "CueTiming", ""}
			EncA[4]={"IndivDelay",0, "CueTiming", ""}
			EncB[4]={"IndivDuration" ,0, "CueTiming", ""}						

		elseif(EncoderBarObj.EncoderFunction == "PresetTiming1") then
			CreatePresetTimingEncoders(1)
		elseif(EncoderBarObj.EncoderFunction == "PresetTiming2") then
			CreatePresetTimingEncoders(5)
		elseif(EncoderBarObj.EncoderFunction == "PresetTiming3") then
			CreatePresetTimingEncoders(9)
		elseif(EncoderBarObj.EncoderFunction == "PresetTiming4") then
			CreatePresetTimingEncoders(13)
		elseif(EncoderBarObj.EncoderFunction == "MIB") then
			EncA[1]={"MIBMode"  ,1,"MIB", ""}
			EncB[1]={"",0,"", ""}
			--EncB[1]={"MIBTarget",1,"MIB", ""}
			EncA[2]={"MIBFade",1,"MIB", ""}
			EncB[2]={"MIBDelay",1,"MIB", ""}
			EncA[3]={"MIBMultiStep",1,"MIB", ""}
			EncB[3]={"",0,"", ""}
			EncA[4]={"MIBPreference",1,"MIB", ""}
			EncB[4]={"",0,"", ""}

		elseif(EncoderBarObj.EncoderFunction == "Cmd") then
			EncA[1]={"CommandDelay" ,1,"CueTiming", ""}
			EncB[1]={"Command"      ,0,"CueTiming", ""}
			EncA[2]={"",0,"", ""}
			EncB[2]={"",0,"", ""}
			EncA[3]={"",0,"", ""}
			EncB[3]={"",0,"", ""}
			EncA[4]={"",0,"", ""}
			EncB[4]={"",0,"", ""}

		elseif(EncoderBarObj.EncoderFunction == "Loops") then
			EncA[1]={"",0,"", ""}
			EncB[1]={"",0,"", ""}
			EncA[2]={"",0,"", ""}
			EncB[2]={"",0,"", ""}
			EncA[3]={"",0,"", ""}
			EncB[3]={"",0,"", ""}
			EncA[4]={"",0,"", ""}
			EncB[4]={"",0,"", ""}

		elseif(EncoderBarObj.EncoderFunction == "Data Edit") then
			EncA[1]={"Auto" ,1  ,"CueDataEdit", ""}
			EncB[1]={"",0,"", ""}
			EncA[2]={"",0,"", ""}
			EncB[2]={"",0,"", ""}
			EncA[3]={"",0,"", ""}
			EncB[3]={"",0,"", ""}
			EncA[4]={"",0,"", ""}
			EncB[4]={"",0,"", ""}
			--[[
			EncA[1]={"Absolute" ,1  ,"CueDataEdit", ""}
			EncB[1]={"Relative" ,1  ,"CueDataEdit", ""}
			EncA[2]={"Fade"     ,1  ,"CueDataEdit", ""}
			EncB[2]={"Delay"    ,1  ,"CueDataEdit", ""}
			EncA[3]={"Speed"    ,1  ,"CueDataEdit", ""}
			EncB[3]={"Phase"    ,1  ,"CueDataEdit", ""}
			EncA[4]={"Accel"    ,1  ,"CueDataEdit", ""}
			EncB[4]={"Decel"    ,1  ,"CueDataEdit", ""}
]]
		end

		if(FocusedSequenceSheet.WindowSettings ~= nil) then
			EncA[5]={"XY",1,"Scroll", ""}
			EncB[5]={"YO",1,"Scroll", ""}			
		else
			EncA[5]={"XY",0,"Scroll", ""}
			EncB[5]={"YO",0,"Scroll", ""}
		end

		signalTable.SetEncoders(Lower, EncA[1], EncB[1], EncA[2], EncB[2], EncA[3], EncB[3], EncA[4], EncB[4], EncA[5], EncB[5])
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SetEncoders = function(EncGrid, Enc1a, Enc1b, Enc2a, Enc2b, Enc3a, Enc3b, Enc4a, Enc4b, Enc5a, Enc5b)
	Default = {"", 0, "CueTiming", ""};
	Enc1a = Enc1a or Default; Enc1b = Enc1b or Default; 
	Enc2a = Enc2a or Default; Enc2b = Enc2b or Default; 
	Enc3a = Enc3a or Default; Enc3b = Enc3b or Default; 
	Enc4a = Enc4a or Default; Enc4b = Enc4b or Default; 
	Enc5a = Enc5a or {"XY", 1, "Scroll", ""};
	Enc5b = Enc5b or {"XO", 1, "Scroll", ""};

	EncGrid.Encoder1a.Property = Enc1a[1];
	EncGrid.Encoder1a.Visible  = Enc1a[2];
	EncGrid.Encoder1a.System   = Enc1a[3];
	EncGrid.Encoder1b.Property = Enc1b[1];
	EncGrid.Encoder1b.Visible  = Enc1b[2];
	EncGrid.Encoder1b.System   = Enc1b[3];

	EncGrid.Encoder2a.Property = Enc2a[1];
	EncGrid.Encoder2a.Visible  = Enc2a[2];
	EncGrid.Encoder2a.System   = Enc2a[3];
	EncGrid.Encoder2b.Property = Enc2b[1];
	EncGrid.Encoder2b.Visible  = Enc2b[2];
	EncGrid.Encoder2b.System   = Enc2b[3];

	EncGrid.Encoder3a.Property = Enc3a[1];
	EncGrid.Encoder3a.Visible  = Enc3a[2];
	EncGrid.Encoder3a.System   = Enc3a[3];
	EncGrid.Encoder3b.Property = Enc3b[1];
	EncGrid.Encoder3b.Visible  = Enc3b[2];
	EncGrid.Encoder3b.System   = Enc3b[3];


	EncGrid.Encoder4a.Property = Enc4a[1];
	EncGrid.Encoder4a.Visible  = Enc4a[2];
	EncGrid.Encoder4a.System   = Enc4a[3];
	EncGrid.Encoder4b.Property = Enc4b[1];
	EncGrid.Encoder4b.Visible  = Enc4b[2];
	EncGrid.Encoder4b.System   = Enc4b[3];

	EncGrid.Encoder5a.Property = Enc5a[1];
	EncGrid.Encoder5a.Visible  = Enc5a[2];
	EncGrid.Encoder5a.System   = Enc5a[3];
	EncGrid.Encoder5b.Property = Enc5b[1];
	EncGrid.Encoder5b.Visible  = Enc5b[2];
	EncGrid.Encoder5b.System   = Enc5b[3];


	EncGrid.Encoder1a.Text     = Enc1a[4];
	EncGrid.Encoder1b.Text     = Enc1b[4];
	EncGrid.Encoder2a.Text     = Enc2a[4];
	EncGrid.Encoder2b.Text     = Enc2b[4];
	EncGrid.Encoder3a.Text     = Enc3a[4];
	EncGrid.Encoder3b.Text     = Enc3b[4];
	EncGrid.Encoder4a.Text     = Enc4a[4];
	EncGrid.Encoder4b.Text     = Enc4b[4];
	EncGrid.Encoder5a.Text     = Enc5a[4];
	EncGrid.Encoder5b.Text     = Enc5b[4];
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SelectCurrCue = function(EditButton)
	if(FocusedSequenceSheet ~= nil) then
		local Grid = GetTargetGrid(FocusedSequenceSheet)
		local Sequence = Grid.TargetObject
		local CuePart = nil
		local SelCue, CuePart = signalTable.DetectCurrCue(EditButton, CuePart)

		if(SelCue ~= nil) then
			signalTable.EditCue(Grid, Sequence, SelCue, CuePart)
		end
	end
end

local function GetCueOrPart(SelCue, Grid, selRow)
	if (IsObjectValid(SelCue) ~= true) then
		local parentId = nil;
		if (selRow ~= nil and selRow ~= "") then parentId = Grid:GridGetParentRowId(selRow); end
		if (parentId ~= nil) then
			SelCue = IntToHandle(parentId);
			if (IsObjectValid(SelCue) == true) then
				return SelCue;
			end
		end
		return nil;
	end

	return SelCue;
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.DetectCurrCue = function(EditButton)
	if(FocusedSequenceSheet ~= nil) then
		local CuePart = nil
		local Grid = GetTargetGrid(FocusedSequenceSheet)
		local selRow = Grid.SelectedRow;
		local SelCue = GetCueOrPart(IntToHandle(selRow), Grid, selRow);


		if (SelCue ~= nil and SelCue:GetClass() ~= "Cue") then
			CuePart = SelCue
			SelCue = SelCue:Parent()
		end

		if(SelCue ~= nil) then
			EditButton.Text = "Edit " .. SelCue.Name
			if(CuePart ~= nil) then
				EditButton.Text = EditButton.Text .. " " .. CuePart.Name
			end
		end
		return SelCue, CuePart
	else
		return nil, nil
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SelectPrevCue = function(EditButton)
	signalTable.SelectCue(EditButton, "Prev")
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SelectNextCue = function(EditButton)
	signalTable.SelectCue(EditButton, "Next")
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SelectCue = function(EditButton, Type)
if(FocusedSequenceSheet ~= nil) then
		local Grid = GetTargetGrid(FocusedSequenceSheet)
		local Sequence = Grid.TargetObject
		local selRow = Grid.SelectedRow;
		local CuePart = nil
		local SelCue = GetCueOrPart(IntToHandle(selRow), Grid, selRow);

		if (SelCue ~= nil and SelCue:GetClass() == "CuePart") then
			CuePart = SelCue
			SelCue = SelCue:Parent()
		end

		local CueIdx
		if(SelCue ~= nil) then
			CueIdx = SelCue:Index()
		else
			CueIdx = 0
		end
	
		local LastCue = Sequence:Count()
		local FirstCue = 2;
		local NewCue

		if(Type == "Prev") then
			if(CueIdx > FirstCue) then
				NewCue = Sequence:Ptr(CueIdx-1)
			else
				NewCue = Sequence:Ptr(LastCue)
			end
		else
			if(CueIdx < LastCue) then
				NewCue = Sequence:Ptr(CueIdx+1)
			else
				NewCue = Sequence:Ptr(FirstCue)
			end
		end

		if(NewCue ~= nil) then
			signalTable.EditCue(Grid, Sequence, NewCue, CuePart)
		end
		signalTable.DetectCurrCue(EditButton:Parent().CurrCue)

	end
end
-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.EditCue = function(Grid, Sequence, NewCue, CuePart)
	if(NewCue ~= nil) then
		Grid:ClearSelection()
		local Command="Edit Sequence \""  .. Sequence.Name .. "\" Cue \"" .. NewCue.Name .. "\""
		if(CuePart ~= nil) then
			Command = Command .. " Part \"" .. CuePart.Name .. "\""
			Grid:SelectRow(HandleToInt(CuePart))
		else
			Grid:SelectRow(HandleToInt(NewCue))
		end
		CmdIndirect(Command)
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.GoFirst = function(Button)
	if(FocusedSequenceSheet ~= nil) then
		local Sequence = GetTargetGrid(FocusedSequenceSheet).TargetObject
		if(Sequence ~= nil) then
			local FirstCueIdx = 2;
			local FirstCue = Sequence:Ptr(FirstCueIdx)
			if(FirstCue ~= nil) then
				CmdIndirect("Go Cue \"" .. FirstCue.Name .. "\"")
			else
				Echo("Unable to find first cue!")
			end
		else
			Echo("Unable to find current sequence!")
		end
	end
end



-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.GoLast = function(Button)
	if(FocusedSequenceSheet ~= nil) then
		local Sequence = GetTargetGrid(FocusedSequenceSheet).TargetObject
		if(Sequence ~= nil) then
			local FirstCueIdx = 2;
			local LastCueIdx = Sequence:Count()
			if(LastCueIdx ~= nil or FirstCueIdx <= LastCueIdx) then
				local LastCue = Sequence:Ptr(LastCueIdx)
				if(LastCue ~= nil) then
					CmdIndirect("Go Cue \"" .. LastCue.Name .. "\"")
				else
					Echo("Unable to find last cue!")
				end
			else
				Echo("Unable du find last cue!")
			end
		else
			Echo("Unable to find current sequence!")
		end
	end
end

