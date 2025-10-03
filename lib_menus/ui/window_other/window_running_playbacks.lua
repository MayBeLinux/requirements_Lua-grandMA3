local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local PlaybackToPoolColor = 
{
	["All"] = "PoolWindow.Default",
	["Sequences"] = "PoolWindow.Sequences",
	["Macros"] = "PoolWindow.Macros",
	["Timecodes"] = "PoolWindow.Timecodes",
	["Presets"] = "PoolWindow.Presets",
	["Timers"] = "PoolWindow.Timers",
	["SoundFiles"] = "PoolWindow.Sounds"
}

local ButtonNameToPlaybackType = 
{
	["ButtonOffSequences"] = "Sequence",
	["ButtonOffMacros"]	= "Macro",
	["ButtonOffTimecodes"] = "Timecode",
	["ButtonOffPresets"] = "Preset",
	["ButtonOffTimers"] = "Timer",
	["ButtonOffSoundFiles"] = "SoundFile",
	["ButtonOffEverything"] = "All",
}

local GetOffButtonSignalValue
GetOffButtonSignalValue = function(PlaybackType, MyPlaybacksOnly)
	local signalStr = ""
	local MPOStr = ""
	local Semicolon = "; "

	if(MyPlaybacksOnly)then
		MPOStr = "My"
	end

	if(PlaybackType == "All")then
		signalStr = GetOffButtonSignalValue("Sequence", MyPlaybacksOnly) .. Semicolon
		signalStr = signalStr .. GetOffButtonSignalValue("Macro", MyPlaybacksOnly) .. Semicolon
		signalStr = signalStr .. GetOffButtonSignalValue("Timecode", MyPlaybacksOnly) .. Semicolon
		signalStr = signalStr .. GetOffButtonSignalValue("Preset", MyPlaybacksOnly) .. Semicolon
		signalStr = signalStr .. GetOffButtonSignalValue("Timer", MyPlaybacksOnly) .. Semicolon
		signalStr = signalStr .. GetOffButtonSignalValue("SoundFile", MyPlaybacksOnly) .. Semicolon
	else
		signalStr = "Off " .. MPOStr .. "Running" .. PlaybackType
	end

	return signalStr
end

local GetOffButtonText = function(PlaybackType, MyPlaybacksOnly)
	local textStr = ""
	local MPOStr = ""
	if(MyPlaybacksOnly)then
		MPOStr = "My"
	end
	if(PlaybackType == "All")then
		if(MyPlaybacksOnly)then
			textStr = "All My Playbacks"
		else
			textStr = "Everything"
		end
	elseif(PlaybackType == "SoundFile")then
		textStr = "All " .. MPOStr .. " Sounds"
	else
		textStr = "All " .. MPOStr .. " " .. PlaybackType .. "s"
	end
	textStr = textStr .. " Off"
	return textStr
end

signalTable.SetUITabTarget = function(caller)
	local WindowRunningPlaybacksObj 
	if(caller:GetOverlay())then
		WindowRunningPlaybacksObj = caller:Parent().WindowArea.WindowRunningPlaybacks
	else
		WindowRunningPlaybacksObj = caller:FindParent("RunningPlaybacksWindow")
	end
	caller.Target = signalTable.Settings
end

signalTable.OnLoad = function(WindowRunningPlaybacksObj, status, creator)
	local IsOverlay = false
	local SheetStyleControl
	local TitleButtons

	if(WindowRunningPlaybacksObj:GetOverlay()) then
		IsOverlay = true
		signalTable.Settings	= CurrentProfile().TemporaryWindowSettings.RunningPlaybacksSettings
		signalTable.SetUITabTarget(WindowRunningPlaybacksObj:Parent():Parent().PagesTab)
		TitleButtons 			= WindowRunningPlaybacksObj:Parent():Parent().Title
	else
		signalTable.Settings	= WindowRunningPlaybacksObj.WindowSettings;
		TitleButtons 			= WindowRunningPlaybacksObj.Title.TitleButtons
		TitleButtons.OffModeControl.Target = WindowRunningPlaybacksObj.WindowSettings;
	end

	if(TitleButtons)then
		SheetStyleControl = TitleButtons.SheetStyleControl
		SheetStyleControl.Target = signalTable.Settings
		TitleButtons.UserControl.Target = signalTable.Settings
		TitleButtons.DataPoolControl.Target = signalTable.Settings
		TitleButtons.MyPlaybacksOnlyControl.Target = signalTable.Settings
		TitleButtons.LockListControl.Target = signalTable.Settings
	end

	if(SheetStyleControl) then
		signalTable.ChangeView(signalTable.Settings, '', SheetStyleControl)
		HookObjectChange(signalTable.ChangeView,	-- 1. function to call
				signalTable.Settings,				-- 2. object to hook
				my_handle:Parent(),					-- 3. plugin object ( internally needed )
				SheetStyleControl);					-- 4. user callback parameter 
	end

	if(WindowRunningPlaybacksObj) then
		signalTable.ChangeGridSelection(signalTable.Settings, '', WindowRunningPlaybacksObj)
		HookObjectChange(signalTable.ChangeGridSelection,	-- 1. function to call
				signalTable.Settings,						-- 2. object to hook
				my_handle:Parent(),							-- 3. plugin object ( internally needed )
				WindowRunningPlaybacksObj);					-- 4. user callback parameter 
	end	
end


signalTable.ChangeView = function(Settings, Signal, ViewButton) -- 
	local WindowRunningPlaybacksObj
	local OverlayObj
	local Overlay
	local GridObj
	local PoolObj

	local PoolPagesTabObj
	local SheetPagesTabObj
	local OverlayPagesTabObj

	local BtnOffAll
	local BtnOffSel
	local BtnEverythingOff
	local BtnMaskOffSelected
	local IsOverlay = false

	if(ViewButton:GetOverlay()) then -- OFF-Menu
		OverlayObj = ViewButton:Parent():Parent()
		WindowRunningPlaybacksObj = OverlayObj.WindowArea.WindowRunningPlaybacks
		Overlay = WindowRunningPlaybacksObj:Parent():Parent()
		OverlayPagesTabObj = OverlayObj.PagesTab
		GridObj = WindowRunningPlaybacksObj.Grid
		PoolObj = WindowRunningPlaybacksObj.Pool
		IsOverlay = true
	else -- Running Playbacks
		WindowRunningPlaybacksObj = ViewButton:Parent():Parent():Parent()
		GridObj = WindowRunningPlaybacksObj.Frame
		PoolObj = WindowRunningPlaybacksObj.Pool
		PoolPagesTabObj = WindowRunningPlaybacksObj.PoolPagesTab
		SheetPagesTabObj = WindowRunningPlaybacksObj.Frame.SheetPagesTab

	end
	GridObj:Changed();
	PoolObj:Changed();
	-- realize the changes
	if(Settings.SheetStyle) then
		if(not IsOverlay) then
			PoolPagesTabObj.Visible = "No"
			SheetPagesTabObj.Visible = "Yes"
		end
		GridObj.Visible = "Yes"
		PoolObj.Visible = "No"
	else
		if(not IsOverlay) then
			SheetPagesTabObj.Visible = "No"
			PoolPagesTabObj.Visible = "Yes"
		end
		GridObj.Visible = "No"
		PoolObj.Visible = "Yes"
	end
end

signalTable.ChangeGridSelection = function(Settings, Signal, WindowRunningPlaybacksObj)
	local GridObj
	local PoolObj = WindowRunningPlaybacksObj.Pool
	local DataObj
	local FunctionButtons = nil
	local IsOverlay = false

	if(WindowRunningPlaybacksObj:GetOverlay()) then -- OFF-Menu
		IsOverlay = true
		FunctionButtons = WindowRunningPlaybacksObj:Parent():Parent().FunctionButtons
		GridObj = WindowRunningPlaybacksObj.Grid
	else
		GridObj	= WindowRunningPlaybacksObj.Frame.Grid
	end

	if(FunctionButtons ~= nil)then
		FunctionButtons.ButtonOffEverything.SignalValue = 	GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffEverything.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffEverything.Text = 			GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffEverything.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffSequences.SignalValue = 	GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffSequences.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffSequences.Text =			GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffSequences.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffMacros.SignalValue = 		GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffMacros.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffMacros.Text =				GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffMacros.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffPresets.SignalValue = 		GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffPresets.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffPresets.Text =				GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffPresets.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffTimecodes.SignalValue = 	GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffTimecodes.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffTimecodes.Text =			GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffTimecodes.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffTimers.SignalValue =		GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffTimers.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffTimers.Text =				GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffTimers.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffSoundFiles.SignalValue =	GetOffButtonSignalValue(ButtonNameToPlaybackType[FunctionButtons.ButtonOffSoundFiles.Name], Settings.MyPlaybacksOnly)
		FunctionButtons.ButtonOffSoundFiles.Text =			GetOffButtonText(ButtonNameToPlaybackType[FunctionButtons.ButtonOffSoundFiles.Name], Settings.MyPlaybacksOnly)
	end

	PoolObj.PoolColor = PlaybackToPoolColor[Settings.PlaybacksToShow]

	GridObj.TargetObject = WindowRunningPlaybacksObj
end

signalTable.SetGridTarget = function(GridObj)
	local WindowRunningPlaybacksObj
	if(GridObj:GetOverlay()) then -- OFF-Menu
		GridObj.OnSelectedItem	= ""
		GridObj.SignalValue		= ""
		WindowRunningPlaybacksObj = GridObj:Parent():Parent():Parent().WindowArea.WindowRunningPlaybacks
	else
		WindowRunningPlaybacksObj = GridObj:Parent():Parent()
	end

	GridObj.TargetObject = WindowRunningPlaybacksObj
end

signalTable.PoolLoaded = function(PoolObj)
	if(PoolObj:GetOverlay()) then -- OFF-Menu
		signalTable.Settings.OffMode = true
	end
	PoolObj.PoolColor = PlaybackToPoolColor[signalTable.Settings.PlaybacksToShow]
end

signalTable.MyPlaybacksOnlyClick = function(MyPlaybacksOnlyControl, status)
	local TitleButtonsObj = MyPlaybacksOnlyControl:Parent()
	if(signalTable.Settings.MyPlaybacksOnly)then
		TitleButtonsObj.UserControl.Enabled="false"
	else
		TitleButtonsObj.UserControl.Enabled="true"
	end
end

signalTable.CloseOverlay = function(caller)
	caller:GetOverlay().Close();
end

signalTable.OnEverythingOffClick = function (ButtonOffEverything, status)
	Cmd(ButtonOffEverything.SignalValue);
	ButtonOffEverything:GetOverlay().Close();
end

signalTable.OnPlaybackOffClick = function (Button, status)
	Cmd(Button.SignalValue);
end