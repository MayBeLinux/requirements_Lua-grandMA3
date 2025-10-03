local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.BarLoaded = function(caller,status,context)
	local UserProfile=CurrentProfile();
	HookObjectChange(signalTable.OnUserProfileChanged,UserProfile,my_handle:Parent(),caller);

	if(context.Name == "DmxSheet") then
		caller.LinkedObject = context;
		local DMXSheet = caller.LinkedObject;

		if(DMXSheet ~= nil) then
			local DMXSheetWindow = DMXSheet:FindParent("Window");

			local settings = DMXSheetWindow.WindowSettings;
			if(settings ~= nil) then
				if(settings:IsClass("DMXSheetSettings")) then
					HookObjectChange(signalTable.OnDmxSheetSettingsChanged,settings,my_handle:Parent(),caller);

					if (caller.Lower ~= nil) then 
						if (caller.Lower.DmxTesterEncoderAddress ~= nil) then
							caller.Lower.DmxTesterEncoderAddress.Target = DMXSheet;
							caller.Lower.DmxTesterEncoderAddress.Property = "Address";
							caller.Lower.DmxTesterEncoderAddress.System = "DmxTester";
						end
						if (caller.Lower.DmxTesterEncoderTestValue ~= nil) then
							caller.Lower.DmxTesterEncoderTestValue.Target = DMXSheet;
							caller.Lower.DmxTesterEncoderTestValue.Property = "TestValue";
							caller.Lower.DmxTesterEncoderTestValue.System = "DmxTester";
						end
						if (caller.Lower.DmxTesterPatchTo ~= nil) then
							caller.Lower.DmxTesterPatchTo.Target = DMXSheet;
							caller.Lower.DmxTesterPatchTo.Property = "Patch";
							caller.Lower.DmxTesterPatchTo.System = "DmxTester";
						end
					end

					signalTable.OnDmxSheetSettingsChanged(settings, my_handle:Parent(), caller);
				end
			end
		end
	end

	signalTable.OnUserProfileChanged(UserProfile, my_handle:Parent(), caller);
end

signalTable.OnUserProfileChanged = function(UserProfile, signal, caller)
	if (caller.Lower ~= nil) then 
		if (caller.Lower.DmxTesterEncoderUniverseGrid ~= nil) then
			if (caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse ~= nil) then
				if (UserProfile.DmxTesterAddressMode) then
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Target = "";
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Property = "";
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.System = "";
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Enabled = false;
				else
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Target = caller.LinkedObject;
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Property = "Universe";
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.System = "DmxTester";
					caller.Lower.DmxTesterEncoderUniverseGrid.DmxTesterEncoderUniverse.Enabled = true;
				end
			end
		end
	end
end

signalTable.OnDmxSheetSettingsChanged = function(settings, signal, caller)
	local selAddr = settings.Address;
	Echo("OnDmxSheetSettingsChanged - selAddr = " .. selAddr);
	caller.SelectedAddr = selAddr;
end

signalTable.CallAllSelectionMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:AllSelection();
end

signalTable.CallReleaseCurrentMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:ReleaseCurrent();
end

signalTable.CallReleaseOthersMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:ReleaseOthers();
end

signalTable.CallReleaseAllMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:ReleaseAll();
end

signalTable.CallParkCurrentMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:ParkCurrent();
end

signalTable.CallUnparkCurrentMethod = function(caller)
	local bar = caller:Parent():Parent();
	bar:UnparkCurrent();
end