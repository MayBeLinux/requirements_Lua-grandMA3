local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function Main(display_handle)
	local plugin     =my_handle:Parent();
	plugin[2]:CommandCall(display_handle);
	if display_handle:GetUIChildrenCount() == 0 then
		Echo("Empty display after calling uixml for "..pluginName);
	end
	signalTable.CreateEncoderBar(display_handle);
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.CreateEncoderBar = function(display_handle)
	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent();
	local Index	= 1;
	local display_index = display_handle:Index();
	
	local isConsole = HostType() == "Console";
	local subType = HostSubType();
	local isLightOrFull = (subType == "FullSizeCRV") or (subType == "FullSize") or (subType == "Light") or (subType == "LightCRV");
	
	if(display_handle.EncoderBarContainer.EncoderBarGrid.EncoderBarBase) then
			display_handle.EncoderBarContainer.EncoderBarGrid.EncoderBarBase.Visible = true;
	end


	plugin[3]:CommandCall(display_handle);

	local Bars	= {"PresetBar", "ExecutorBar", "ExecutorBarXKeys"};

    if(display_index==1) then
		if (isConsole and isLightOrFull) then
			BarIndex = 1;--always preset bar. according to testers it makes no sense on these types
		else
			local eVal = Enums.ShowUserEncoder[CurrentProfile().ShowUserEncoder]
			BarIndex = eVal+1; -- +1 for lua tables starts with 1 instead of 0
		end
		if(BarIndex == 2 or BarIndex == 3) then
			display_handle.EncoderBarContainer.EncoderBarGrid.EncoderBar.Visible = false;
		else 
			display_handle.EncoderBarContainer.EncoderBarGrid.EncoderBar.Visible = true;
		end
	elseif(display_index == 7) then
		BarIndex = 3;
    else
		BarIndex = 2;
    end

	display_handle.EditEncoderBar = Bars[BarIndex];
	plugin_pool[Bars[BarIndex]]:CommandCall(display_handle);
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.SaveShow = function(caller,dummy)
	CmdIndirect("SaveShow");
end

local function OnWebCmdChanged(webCmd, lev, disp)
	local mainPult = Root().GraphicsRoot.PultCollect:Ptr(1);
	local mainCmd = mainPult.Cmd;
	local mainP = mainCmd.Profile;

	local webP = webCmd.Profile;
	local same = mainP == webP;
	disp.CmdLineSection.LinkCmd.Visible = same;
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.DisplayLoaded = function(display,status,creator)
	local display_index = display:Index();
	local hostType = HostType();

	HookObjectChange(signalTable.MainDialogChanged,display.MainDialog,my_handle:Parent());
	HookObjectChange(signalTable.ManetStatusChanged,Root().ManetSocket,my_handle:Parent());
	signalTable.ManetStatusChanged();
	signalTable.DisplayVisible(display);

	local cs = display.CmdLineSection;
	local mm = display.MainMenuCnt.SB.MainMenu;
	local pultType = Pult().PultType;
	local encbar = display.EncoderBarContainer;
	if (pultType == "Web") then
	--turning off some buttons not relevant for web
		local rows = mm:Ptr(1);
		rows:Ptr(1).Size="0";--shutdown
		rows:Ptr(2).Size="0";--space filler
		mm.OpenMenuSelector.Texture="corner3";
		mm.DisplaySelectorBtn.SignalValue = "menu WebDisplaySelectOverlay";

		local c = Pult().Cmd;
		HookObjectChange(OnWebCmdChanged, c, my_handle:Parent(), display);
		OnWebCmdChanged(c, nil, display);
		encbar.Visible = false;
	end

	if ((hostType ~= "onPC") and (pultType ~= "Web")) then
		mm.DisplaySelectorBtn.Visible = false;
		mm.FillerDispSelector.Anchors = "0,9,0,10";
	end

    local builddetails = BuildDetails();
	if (builddetails["CodeType"] == "Internal Production") then
        display.ScreenContainer.ScrollIndicatorBox.ScreenScroll.ScrollBox.UiScreen.BackColor = Root().ColorTheme.ColorGroups.Global.PartlySelected;
	end
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************
local initialMainMenuSize = "50";

--these are lua-side hacks as SizeDescriptor doesn't support proper lua communiation yet
--parses passed string to find 1st number in it. returns as string though
local function Get1stNumber(str)
	local n = nil;
	local f = function(s) n = s; end;
	str:gsub("%d+", f, 1);
	return n;
end

local function GetRequestedSize(str)
	local n = nil;
	local f = function(s) n = s; end;
	str:gsub("(%d+)!%(%d+%)", f, 1);
	return n;
end

signalTable.MainMenuLoaded = function(mmenu)
	local w = tostring(mmenu.W);
	initialMainMenuSize = GetRequestedSize(w);
	if (initialMainMenuSize == nil) then initialMainMenuSize = Get1stNumber(w); end
	if (initialMainMenuSize == nil or initialMainMenuSize == "0") then initialMainMenuSize = "50"; end
end

signalTable.DisplayVisible = function(display)
	if(display.EncoderBarContainer.EncoderBarGrid.EncoderBarBase) then
		signalTable.BarLoaded(display.EncoderBarContainer.EncoderBarGrid.EncoderBarBase:GetUIChild(1))
	end
	local display_index=display:Index();
	local default_display_position=DefaultDisplayPositions():Ptr(display_index);
	if(default_display_position) then
			
		local screen = display.ScreenContainer.ScrollIndicatorBox
		local viewbar = display.ScreenContainer.ViewBar;
		local gotofirst = display.ScreenContainer.GoToFirst;
		local viewBarNextPage = display.ScreenContainer.ViewBarNextPage;
		if(viewbar) then
			if(viewbar.Visible ~= default_display_position.ShowViewBar) then 
				viewbar.Visible = default_display_position.ShowViewBar; 
			end

			if(default_display_position.TurnViewBar) then 
				viewbar.Anchors = "0,0,1,0";
				if(gotofirst) then
					gotofirst.Anchors = "0,0,1,0"; 
					gotofirst.AlignmentH = "Left";
					gotofirst.Icon = "PlaybackFastbackward";
				end
				if(viewBarNextPage)then
					viewBarNextPage.Anchors = "0,0,1,0";
					viewBarNextPage.AlignmentH= "Right";
					viewBarNextPage.AlignmentV= "Top";
					viewBarNextPage.Icon = "triangle_right";
				end
				display.CmdLineSection.RightTriangle.Icon = "triangle_up"
			else 
				viewbar.Anchors = "1,0,1,1";
				if(gotofirst) then 
					gotofirst.Anchors = "1,0,1,1";
					gotofirst.AlignmentH = "Right";
					gotofirst.Icon = "PlaybackFastupward";
				end
				if(viewBarNextPage)then
					viewBarNextPage.Anchors = "1,0,1,1";
					viewBarNextPage.AlignmentH= "Right";
					viewBarNextPage.AlignmentV = "Bottom";
					viewBarNextPage.Icon = "triangle_down";
				end
				display.CmdLineSection.RightTriangle.Icon = "triangle_right"
			end
		end

		local cmdline = display.CmdLineSection;
		if(cmdline and (cmdline.Visible ~= default_display_position.ShowCmdline)) then	
			cmdline.Visible = default_display_position.ShowCmdline; 
		end

		local mainmenu = display.MainMenuCnt;
		if (mainmenu) then
			local w = Get1stNumber(tostring(mainmenu.W));
			local mainMenuVisible = mainmenu and (w ~= "0");
			if(mainmenu and (mainMenuVisible ~= default_display_position.ShowMainMenu)) then
				if (default_display_position.ShowMainMenu) then
					mainmenu.W = initialMainMenuSize;
				else
					mainmenu.W = "0";
				end
				mainmenu:Changed();
			end
		end
	end
end


-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.ToggleMainDialog= function(caller,signal)
    Cmd("menu '" .. signal.."'");	
end

signalTable.ToggleMainMenu= function(caller,signal)
	local display_index = caller:GetDisplayIndex();
	local default_display_position=DefaultDisplayPositions():Ptr(display_index);
	if(default_display_position) then
	    local status=default_display_position.ShowMainMenu;
		default_display_position.ShowMainMenu=not status;
	end
end

signalTable.ToggleViewBar= function(caller,signal)
	local display_index = caller:GetDisplayIndex();
	local default_display_position=DefaultDisplayPositions():Ptr(display_index);
	if(default_display_position) then
	    local status=default_display_position.ShowViewBar;
		default_display_position.ShowViewBar=not status;
	end
end




-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.CloseMainDialog= function(caller,signal)
	local display = caller:GetDisplay();
	local dialog  = display.MainDialog[signal];
	if(dialog and dialog:IsValid() ) then
	    if(dialog.UserInteracted) then
		   Cmd("menu "..signal);
        end
	end
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.MainDialogChanged= function(caller,signal)

	local displaycollect = Pult().DisplayCollect;
    local displayCount   = displaycollect:Count();

    for i = 1, displayCount do
        local display = displaycollect[i];
		if display then
			if(display.MainMenuCnt) then
				local menu = display.MainMenuCnt.SB.MainMenu;
				signalTable.SetButtonStatus(menu.OpenCommand,"CommandControl");
				signalTable.SetButtonStatus(menu.OpenPlayback,"PlaybackControl");
				signalTable.SetButtonStatus(menu.OpenMaster,"MasterControl");
			end
		end
	end
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.SetButtonStatus=function(button,maindialogname)
	if button then
		local display = button:GetDisplay();
		local dialog  = display.MainDialog[maindialogname];
		button.State = (dialog~=nil);
	end
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.ManetStatusChanged=function(caller,signal)
	
	local root = Root();
	local ManetSocket=root.ManetSocket;
	local ColorTheme =root.ColorTheme.ColorGroups;
	local network_color=ColorTheme.Network[ManetSocket.Status];
	local displaycollect = Pult().DisplayCollect;
    local displayCount   = displaycollect:Count();
    for i = 1, displayCount do
        local display = displaycollect[i];
        if display then
		    local CmdLineSection=display.CmdLineSection;
			if CmdLineSection then
				CmdLineSection.StatusScrollContainer.StatusScrollBox.StatusScrollContent.Network.IconColor=network_color;
			end
		end
	end
end

signalTable.AutoTest = function()
	if (Confirm("Automatic tests", "Start automatic tests?") == true) then
		CmdIndirect("NewShow");
		CmdIndirect("cd pl");
		CmdIndirect("list lib");
		CmdIndirect("import lib 'system_test.xml'");
		CmdIndirect("cd root");
		CmdIndirect("pl 1.2");
	end
end
-- ***************************************************************************************************
--
-- ***************************************************************************************************
signalTable.SetCommandWingBarButton = function(caller)
	local display_index= caller:GetDisplay():Index();
	local default_display_position=DefaultDisplayPositions():Ptr(display_index);
	caller.Target = default_display_position;
	if(signalTable.ShowOnlyOnPcDisplay1(caller)) then

		local display = caller:GetDisplay();
		HookObjectChange(signalTable.EnableCommandWingBarButton, display.EncoderBarContainer, my_handle:Parent(), caller);
		signalTable.EnableCommandWingBarButton(display.EncoderBarContainer, nil, caller);
	end
end


signalTable.EnableCommandWingBarButton = function(EncoderBarContainer, dummy, caller)
	if(EncoderBarContainer.Visible) then
		caller.Enabled= true;
	else
		caller.Enabled= false;
	end
end

signalTable.ShowOnlyOnPcDisplay1 = function(caller)
	local visible = false;
	local display_index= caller:GetDisplay():Index();
	if (display_index == 1 and HostType() == "onPC") then
		visible	= true;
	end

	caller.Visible = visible;
	return visible;
end

signalTable.OpenHelpPopup = function(caller)

    Cmd("Help _LAST_OPENED_HTML_");
	
end

-- ***************************************************************************************************
--
-- ***************************************************************************************************
return Main;
