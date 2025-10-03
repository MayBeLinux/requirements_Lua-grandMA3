local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.NumericInputLoaded = function(caller,status,creator)
	local modeHexBtn = caller.Content.Editor.ModeHex;
	local modeHexBtn2 = caller.Content.Editor.ModeHex2;
	local modeTimeBtn = caller.Content.Editor.ModeTime;

	local isDec = caller.Mode == Enums.CalculatorMode.Decimal;
	local isHex = caller.Mode == Enums.CalculatorMode.Hex;

	local isHex8 = caller.Mode == Enums.CalculatorMode.Hex8;
	local isHex16 = caller.Mode == Enums.CalculatorMode.Hex16;
	local isHex24 = caller.Mode == Enums.CalculatorMode.Hex24;
	local isDec8 = caller.Mode == Enums.CalculatorMode.Dec8;
	local isDec16 = caller.Mode == Enums.CalculatorMode.Dec16;
	local isDec24 = caller.Mode == Enums.CalculatorMode.Dec24;
	local isPercent = caller.Mode == Enums.CalculatorMode.Percent;
	local isTime = caller.Mode == Enums.CalculatorMode.Seconds;
	local isSpeedSec = caller.Mode == Enums.CalculatorMode.SpeedSec;
	local isSpeedHz = caller.Mode == Enums.CalculatorMode.SpeedHz;
	local isSpeedBPM = caller.Mode == Enums.CalculatorMode.SpeedBPM;
	local isJointTime = caller.Mode == Enums.CalculatorMode.JointTime;
	local isTime24 = caller.Mode == Enums.CalculatorMode.fps24;
	local isTime25 = caller.Mode == Enums.CalculatorMode.fps25;
	local isTime30 = caller.Mode == Enums.CalculatorMode.fps30;
	local isTime60 = caller.Mode == Enums.CalculatorMode.fps60;

	local addArgs = caller.AdditionalArgs
	if (addArgs and addArgs.ShowEnumFilter == "Yes") then
		caller.Content.ButtonsArea.EnumsParent.EnumFilter.Visible=true
	end

	if (caller:GetDisplayIndex() >= 6) then
		caller.W = "800";
		caller.H = "480";
		caller.Content.ButtonsArea.Keys.W = "400";
		caller.Content.ButtonsArea.EnumsParent.Enums.Box.EnumsContainer.EnumsLayout.MinCellSize = "100";
		if caller.Content.ButtonsArea.EnumGroupsTabs.Visible == false then
			caller.W = "300";--trying to make it as small as possible
		end
	elseif caller.Content.ButtonsArea.AdditionalOptions.Visible == true then
		caller.W = "1250";
	elseif caller.Content.ButtonsArea.EnumGroupsTabs.Visible == false then
		local layout = caller.Content.ButtonsArea.EnumsParent.Enums.Box.EnumsContainer.EnumsLayout;
		if (layout and layout:GetUIChildrenCount() > 1) then
			caller.W = "800";--trying to make it in 2 columns for enums
		elseif(layout and layout:GetUIChildrenCount() > 0) then
			caller.W = "600";
		else
			caller.W = "300";--trying to make it as small as possible
		end
	end

	if (caller.SuppressModeSwitch == true) then
		modeHexBtn.Visible = false;
		modeHexBtn2.Visible = false;
		modeTimeBtn.Visible = false;

		if (isHex or isHex8 or isHex16 or isHex24) then
			caller.Content.ButtonsArea.Keys.HexKeys.Visible = true;
		elseif (isTime or isTime24 or isTime25 or isTime30 or isTime60) then
			caller.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		end
	else
		--TODO: this might be outdated. check
		if (modeHexBtn) then
			modeHexBtn.Visible = false;
			if (isDec or isHex) then
				modeHexBtn.Visible = true;
				modeHexBtn:AddListNumericItem("Dec", Enums.CalculatorMode.Decimal);
				modeHexBtn:AddListNumericItem("Hex", Enums.CalculatorMode.Hex);
				modeHexBtn:SelectListItemByValue(caller.Mode);
				if (isHex) then
					caller.Content.ButtonsArea.Keys.HexKeys.Visible = true;
				end
			end
		end

		if (modeHexBtn2) then
			modeHexBtn2.Visible = false;
			local percentWithHexDec = caller.MixPercentAndHexDecModesAllowed
			local isPercentLocal = isPercent and percentWithHexDec
			if (isPercentLocal or isDec8 or isHex8 or isDec16 or isHex16 or isDec24 or isHex24) then
				modeHexBtn2.Visible = true;
				if percentWithHexDec == true then
					modeHexBtn2:AddListNumericItem("Percent", Enums.CalculatorMode.Percent);
				end
				modeHexBtn2:AddListNumericItem("Dec8", Enums.CalculatorMode.Dec8);
				modeHexBtn2:AddListNumericItem("Dec16", Enums.CalculatorMode.Dec16);
				modeHexBtn2:AddListNumericItem("Dec24", Enums.CalculatorMode.Dec24);
				modeHexBtn2:AddListNumericItem("Hex8", Enums.CalculatorMode.Hex8);
				modeHexBtn2:AddListNumericItem("Hex16", Enums.CalculatorMode.Hex16);
				modeHexBtn2:AddListNumericItem("Hex24", Enums.CalculatorMode.Hex24);
				modeHexBtn2:SelectListItemByValue(caller.Mode);
				if (isHex8 or isHex16 or isHex24) then
					caller.Content.ButtonsArea.Keys.HexKeys.Visible = true;
				end
			end
		end

		if (modeTimeBtn) then
			modeTimeBtn.Visible = false;
			if (isTime or isTime24 or isTime25 or isTime30 or isTime60) then
				modeTimeBtn.Visible = true;
				modeTimeBtn:AddListNumericItem("Seconds", Enums.CalculatorMode.Seconds);
				modeTimeBtn:AddListNumericItem("24 fps", Enums.CalculatorMode.fps24);
				modeTimeBtn:AddListNumericItem("25 fps", Enums.CalculatorMode.fps25);
				modeTimeBtn:AddListNumericItem("30 fps", Enums.CalculatorMode.fps30);
				modeTimeBtn:AddListNumericItem("60 fps", Enums.CalculatorMode.fps60);
				modeTimeBtn:SelectListItemByValue(caller.Mode);
				modeTimeBtn.SelectionChanged = "TimeModeChanged";
				if (isTime or isTime24 or isTime25 or isTime30 or isTime60) then
					caller.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
				end
			elseif (isSpeedBPM or isSpeedHz or isSpeedSec) then
				modeTimeBtn.Visible = true;
				modeTimeBtn:AddListNumericItem("Seconds", Enums.CalculatorMode.SpeedSec);
				modeTimeBtn:AddListNumericItem("Hz", Enums.CalculatorMode.SpeedHz);
				modeTimeBtn:AddListNumericItem("BPM", Enums.CalculatorMode.SpeedBPM);
				modeTimeBtn:SelectListItemByValue(caller.Mode);
				modeTimeBtn.SelectionChanged = "SpeedModeChanged";
				if (isSpeedSec) then
					caller.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
				end
			end
		end

		if (isJointTime) then
			caller.Content.ButtonsArea.Keys.TimeKeys.Visible = true;

			local ok = caller.Content.ButtonsArea.Keys.OperationKeys;
			ok.PlusMinus.Visible = false;
			ok.Modulo.Visible = false;
			ok.Equal.Visible = false;
		end

		caller.TitleBar.TitleButtons.ApplyEnumFilter.Target = caller
	end
end

signalTable.CalculatorModeChanged = function(caller,name,id,index)
	local overlay = caller:GetOverlay();
	if (overlay) then
		if (name == "Dec") then --Dec
			overlay.Mode = Enums.CalculatorMode.Decimal;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = false;
		elseif (name == "Hex") then --Hex
			overlay.Mode =Enums.CalculatorMode.Hex;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = true;
		elseif (name == "Percent") then --Percent
			overlay.Mode =Enums.CalculatorMode.Percent;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = false;
		elseif (name == "Dec8") then --Dec8
			overlay.Mode =Enums.CalculatorMode.Dec8;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = false;
		elseif (name == "Dec16") then --Dec16
			overlay.Mode =Enums.CalculatorMode.Dec16;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = false;
		elseif (name == "Dec24") then --Dec24
			overlay.Mode =Enums.CalculatorMode.Dec24;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = false;
		elseif (name == "Hex8") then --Hex8
			overlay.Mode =Enums.CalculatorMode.Hex8;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = true;
		elseif (name == "Hex16") then --Hex16
			overlay.Mode =Enums.CalculatorMode.Hex16;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = true;
		elseif (name == "Hex24") then --Hex24
			overlay.Mode =Enums.CalculatorMode.Hex24;
			overlay.Content.ButtonsArea.Keys.HexKeys.Visible = true;
		else
			Echo("Unknown mode");
		end
	end
end

signalTable.TimeModeChanged = function(caller,name,id,index)
	local overlay = caller:GetOverlay();
	if (overlay) then
		if (name == "Seconds") then --Time
			overlay.Mode = Enums.CalculatorMode.Seconds;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		elseif (name == "Hz") then --Hz
			overlay.Mode =Enums.CalculatorMode.Hz;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = false;
		elseif (name == "BPM") then --BPM
			overlay.Mode =Enums.CalculatorMode.BPM;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = false;
		elseif (name == "60 fps") then --Time
			overlay.Mode = Enums.CalculatorMode.fps60;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		elseif (name == "24 fps") then --Time
			overlay.Mode = Enums.CalculatorMode.fps24;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		elseif (name == "30 fps") then --Time
			overlay.Mode = Enums.CalculatorMode.fps30;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		elseif (name == "25 fps") then --Time
			overlay.Mode = Enums.CalculatorMode.fps25;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		else
			Echo("Unknown mode");
		end
	end
end

signalTable.EnumFilterChanged = function(caller,name,id,index)
   local overlay = caller:GetOverlay();
   overlay:Changed();
end

signalTable.SpeedModeChanged = function(caller,name,id,index)
	local overlay = caller:GetOverlay();
	if (overlay) then
		if (name == "Seconds") then --Time
			overlay.Mode = Enums.CalculatorMode.SpeedSec;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = true;
		elseif (name == "Hz") then --Hz
			overlay.Mode =Enums.CalculatorMode.SpeedHz;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = false;
		elseif (name == "BPM") then --BPM
			overlay.Mode =Enums.CalculatorMode.SpeedBPM;
			overlay.Content.ButtonsArea.Keys.TimeKeys.Visible = false;
		else
			Echo("Unknown mode");
		end
	end
end

signalTable.PlusMinusClicked = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local editLine = overlay.Content.Editor.EditField;
		local keys = overlay.Content.ButtonsArea.Keys;

		if (editLine and keys) then
			local s = editLine.ContentBeforeCursor;
			local lastChar = string.sub(s,-1);
			local addChar = '-';

			if (lastChar == '-' or lastChar == '+') then
				keys.KeyPress('Backspace');
				if (lastChar == '-') then
					addChar = '+';
				end
			end
			editLine.InsertText(addChar);
		end
	end
end

return Main;
