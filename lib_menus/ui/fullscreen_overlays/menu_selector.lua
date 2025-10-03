local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function Main(display_handle)
	local plugin     = my_handle:Parent();
	local displays 	 = display_handle:Parent();

	plugin[2]:CommandCall(display_handle, false);
	plugin[3]:CommandCall(display_handle, false);
	if (displays[6]) then
		plugin[4]:CommandCall(displays[6], false);
	end
	if (displays[7]) then
		plugin[4]:CommandCall(displays[7], false);
	end

	local UserProfile=CurrentProfile();
	UserProfile.TemporaryWindowSettings.PatchEditorSettings.Show3DPositions=false;
	UserProfile.TemporaryWindowSettings.PatchLiveSettings.Show3DPositions=false;
end

local popups = {
				["SettingsPopup"] = { { "str", "User Configuration", "menu 'UserConfiguration'" },
									{ "str", "Date and Time", "menu 'DateTimeLocation'" },
									{ "str", "USB Configuration", "menu 'UsbConfiguration'" },
									{ "str", "Software Update", "menu 'SoftwareUpdate'" } ,
									{ "str", "Touch Configuration", "menu 'TouchConfig'" },
									{ "str", "Extension Configuration", "menu 'ExtensionConfiguration'" },
									},
				};
				if ((HostOS() == "Windows") or (HostOS()=="Mac")) then	table.insert(popups["SettingsPopup"], { "str", "onPC Local Settings", "menu 'OnpcSettings'" })   table.remove(popups["SettingsPopup"], 5)
				else	table.insert(popups["SettingsPopup"], { "str", "Local Settings", "menu 'LocalSettings'" })
				end


signalTable.OnOpenPopup = function(caller, value, buttonType, x, y)
	local sel_index, res_val;
	x = caller.AbsRect.x + x + 100;
	y = caller.AbsRect.y + y + 25;
	local props = {}
	props["Popup.ItemSize"] = "80";
	sel_index, res_val = PopupInput({items=popups[value], x=x, y=y, target=caller, caller=caller, properties=props});


	--obsolete with this commit
	--SHA-1: 3d94fab86aae902564104d71172282af27a024ff remove Start Windows Gui from onPC settings
	--if (sel_index and sel_index == 6) then
	--	signalTable.onWindowsGui()
	--else
		if (res_val) then
			Echo (res_val)
			Cmd("menu 'MenuSelector'", caller:GetDisplay());
			Cmd(res_val, caller:GetDisplay());
		end
	--end
end

--signalTable.onWindowsGui = function(caller)
--	local handle = io.popen("start explorer.exe");
--	handle:close();
--end


signalTable.OnTitleLoaded = function(caller)
	caller.Text = "Menu [".. Root().ManetSocket.Showfile .."]";
	caller.ShowAdditionalInfo = true;
	local relType = ReleaseType();
	local addDetails = ""
	if (relType == "Release") then
		addDetails = "Software Version "..Version();
	else
		addDetails = "Software Version "..Version() .. ": " .. relType;
	end
	local bd = BuildDetails()
	if bd.BranchName ~= nil then
		addDetails = addDetails .. "; Branch: "..bd.BranchName.." v"..bd.BranchVersion
	end
	caller.AdditionalInfo = addDetails
end

signalTable.MenuConfigDisplay = function(caller)
	CmdIndirect("menu 'DisplayConfig'", nil, caller:GetDisplay());
end

signalTable.EncoderMenuLoaded = function(caller)
	local CurrentDisplay = caller:GetDisplay()
	local isConsole = HostType() == "Console";
	local TargetDisplayIndex;
	if(isConsole) then
		TargetDisplayIndex = 8
	else
		TargetDisplayIndex = 1
	end
	if(CurrentDisplay:Index() ~= TargetDisplayIndex) then
		caller.Visible="No"
	end
end

signalTable.ResetMainDialogsToThis = function(caller)
	local plugPrefs = CurrentScreenConfig():Ptr(3);
	local di = caller:GetDisplayIndex();
	for i,c in ipairs(plugPrefs:Children()) do
		c.DisplayIndex = di;
	end
end

signalTable.ResetMainDialogsToDefault = function(caller)
	local plugPrefs = CurrentScreenConfig():Ptr(3);
	for i,c in ipairs(plugPrefs:Children()) do
		c.DisplayIndex = "None";
	end
end

return Main;
