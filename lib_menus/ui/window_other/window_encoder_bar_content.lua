local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local HookMatrickId;
local settings = nil;
local left_SideOfEncoderBarTop = true;
local middle_OfEncoderBarTop = true;
local right_SideOfEncoderBarTop = true;

signalTable.MatricksBtnLoaded = function(caller)
	HookObjectChange(signalTable.SetMAtricksTarget,  -- 1. function to call
	CurrentProfile(),							-- 2. object to hook
	my_handle:Parent(),				-- 3. plugin object ( internally needed )
	caller);							-- 4. user callback parameter 	
	
	signalTable.SetMAtricksTarget(nil,nil,caller);
end

signalTable.SetMAtricksTarget = function(dummy,dummy2,caller)
	local Matrick = Selection();
	if (Matrick) then
		caller.Target = Matrick;
		if(caller.MatricksText) then
			caller.MatricksText.Target = Matrick;
		end
	end
end

signalTable.WindowEncoderBarContentLoaded = function(caller)
	local encoderbarcontainer = caller;
	local window = caller:FindParent("Window");

	if (window) then
		settings = window.WindowSettings;
		if (settings) then

			HookObjectChange(signalTable.ShowGrandMasterGrid,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowGrandMasterGrid(settings, nil, caller);

			HookObjectChange(signalTable.ShowUserSettings,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowUserSettings(settings, nil, caller);

			HookObjectChange(signalTable.ShowToolPopups,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowToolPopups(settings, nil, caller);

			HookObjectChange(signalTable.ShowTimeButtons,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowTimeButtons(settings, nil, caller);

			HookObjectChange(signalTable.ShowEncoderBank,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowEncoderBank(settings, nil, caller);

		end
	end 
end

signalTable.ShowGrandMasterGrid = function(settings, dummy, caller)
	local showgrandmaster = settings.ShowGrandMaster;
	local grandmastergrid = caller.GrandMasterGrid
	
	if(showgrandmaster)	 then
		grandmastergrid.Visible = true;
	else
		grandmastergrid.Visible = false;
	end
end

signalTable.ShowUserSettings = function(settings, dummy, caller)
	local showusersettings = settings.ShowUserSettings;
	local buttonsleft = caller.ButtonsLeft
	
	if(showusersettings)	 then
		buttonsleft.Visible = true;
	else
		buttonsleft.Visible = false;
	end
end

signalTable.ShowToolPopups = function(settings, dummy, caller)
	local suppressspecialdialog = settings.ShowToolPopups;
	local top = caller.Middle.Top

	if(suppressspecialdialog)	 then
		top.SelectionOverlay.Visible = true;
		top.PhaserOverlay.Visible = true;
		top.MatricksMenu.Visible = true;
		middle_OfEncoderBarTop = true;
	else
		top.SelectionOverlay.Visible = false;
		top.PhaserOverlay.Visible = false;
		top.MatricksMenu.Visible = false;
		middle_OfEncoderBarTop = false;
	end
	
	signalTable.VisibilityEncoderBarTop(caller);
	
end

signalTable.ShowTimeButtons = function(settings, dummy, caller)
	local suppressspecialdialog = settings.ShowTimeButtons;
	local top = caller.Middle.Top
	
	if(suppressspecialdialog)	 then
		top.ProgFader.Visible = true;
		top.ExecFader.Visible = true;
		right_SideOfEncoderBarTop = true;
	else
		top.ProgFader.Visible = false;
		top.ExecFader.Visible = false;
		right_SideOfEncoderBarTop = false
	end
	
	signalTable.VisibilityEncoderBarTop(caller);
	
end

signalTable.ShowEncoderBank = function(settings, dummy, caller)
	local suppressspecialdialog = settings.ShowEncoderBank;
	local top = caller.Middle.Top;

	if(suppressspecialdialog)	 then
		top.EncoderBankSelector.Visible = true;
		left_SideOfEncoderBarTop = true;
	else
		top.EncoderBankSelector.Visible = false;
		left_SideOfEncoderBarTop = false;
	end

	signalTable.VisibilityEncoderBarTop(caller);
end


signalTable.VisibilityEncoderBarTop = function(caller)
	local top = caller.Middle.Top;

	if not (left_SideOfEncoderBarTop or right_SideOfEncoderBarTop or middle_OfEncoderBarTop) then
		top.Visible = false;
	else
		top.Visible = true;
	end
end


signalTable.MatricksTextLoaded = function(caller)
	caller.Target = Selection();
end


local function trimStr(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

signalTable.OnClickedLayer = function(caller,signal,creator)
	local cmdlineText = trimStr(CmdObj().CmdText):lower();
	if (cmdlineText and (cmdlineText == "off" or cmdlineText == "on")) then
		Cmd(''..cmdlineText..' '..caller.name..'');
		CmdObj().ClearCmd();
	elseif (cmdlineText and cmdlineText == "at" and caller.name == "GridPos") then
		Cmd(''..cmdlineText..' '..caller.name..'');
		CmdObj().ClearCmd();
	else
		Cmd('Set ' ..CurrentProfile():ToAddr().. ' "'..caller.Property..'" "'..caller.value..'"')
	end
end

signalTable.SpecialGrandMasterLoaded = function(caller)
	local grandKnob = CurrentProfile().SpecialExecutorPages[1][Enums.SpecialExecutor.GrandKnob+1];

	HookObjectChange(signalTable.ShowSpecialGrandMaster,  -- 1. function to call
					grandKnob,							-- 2. object to hook
					my_handle:Parent(),				-- 3. plugin object ( internally needed )
					caller);							-- 4. user callback parameter 	

	signalTable.ShowSpecialGrandMaster(grandKnob, nil, caller);
end

signalTable.ShowSpecialGrandMaster = function(grandKnob, dummy, caller)
	if(IsObjectValid(caller)) then
		local grandFader = caller:Parent().MasterFader;
		if(grandKnob ~= nil) then
			if(grandKnob.Object ~= Root().ShowData.Masters.Grand.Master) then
				caller.Visible="Yes";
				grandFader.Anchors="0,0,0,2";
			else
				caller.Visible="No";
				grandFader.Anchors="0,0,0,3";
			end
		end
	end
end

signalTable.MatricksLoaded= function(caller)
	
	signalTable.OnMAtrickschange(nil, nil, caller)
	HookObjectChange(signalTable.OnMAtrickschange,  Selection(), my_handle:Parent(), caller);
end

signalTable.OnMAtrickschange = function(dummy, dummy2, caller)
	if(caller) then
		if(caller.Target.InitialMatricks ~= nil) then
			Echo(caller.Target.InitialMatricks.Name)
			caller.ShowLabel = "Yes";
		else
			caller.ShowLabel = "No";
		end
	end

		if(caller.Target.Active) then
		caller.ValueTextColor="Global.Selected";
		caller.TextColor="Global.Selected";
	else
		caller.ValueTextColor="Global.Text";
		caller.TextColor="Global.Text";
	end
end
