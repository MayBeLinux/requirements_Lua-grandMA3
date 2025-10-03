local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local pVars = nil;
local pConnectorView = nil;

local function UpdateColumnFilter(o)
	local filter = GetVar(pVars, "ColumnFilter");
	o.Content.Consoles:WaitInit(2);
	local s = o.Content.Consoles:GridGetSettings();
	local filterCollect = s:Ptr(1);
	filterCollect.SelectedFilter = filter;
end

local function LetterboxesVisible()
	local LongScreen = Pult().DisplayCollect[8]
	if LongScreen ~= nil then
		return true;
	end
	return false
end

local function ConnectorViewLoaded()
	if LetterboxesVisible() == true then
		local LongScreen = Pult().DisplayCollect[8]
		local Overlay = LongScreen.FullScreen:Find("ConnectorView")
		if Overlay ~= nil then
			return true
		end
	end
	return false
end

local function ShowConnectorView(value)
	if LetterboxesVisible() then
		if value ~= ConnectorViewLoaded() then
			Cmd("Menu 'ConnectorView'");
		end
	end
end

signalTable.ConnectorViewClick = function(caller,signal)
	local View = CurrentProfile().ShowConnectors
	ShowConnectorView(View)
end

signalTable.ButtonClicked = function(caller,signal)
	 DeviceConfiguration().OutputStations.Action(signal);
end

signalTable.ContentLoaded = function( caller,status,creator )
	caller.Consoles.SortByColumn("Asc", 4)
end

signalTable.ColumnsFilterSelected = function(caller, dummy, handleInt, idx)
	local filter = caller:GetListItemValueStr(idx + 1);
	local o = caller:GetOverlay();
	SetVar(pVars, "ColumnFilter", filter);

	UpdateColumnFilter(o);
end

signalTable.RowFilterSelected = function(caller, dummy, handleInt, idx)
	local index = caller:GetListItemValueStr(idx + 1);
	local o = caller:GetOverlay();
	local filter = o.Content.Consoles.Internals.GridBase.GridSettings.GridObjectContentFilter.InMySession
	filter.Enabled = index
end

signalTable.ConnectorConfigLoaded = function(caller, str)
	caller.Content.Consoles.TargetObject = DeviceConfiguration().OutputStations
	pVars = PluginVars():Ptr(1);
	local colFiltersBtn = caller.TitleBar.TitleButtons.ColumnsFilters;
	colFiltersBtn:ClearList();
	colFiltersBtn:AddListStringItem("Full", "Full");
	colFiltersBtn:AddListStringItem("Condensed", "Condensed");
	colFiltersBtn:AddListStringItem("XLR Only", "XLROnly");

	local selectedFilter = GetVar(pVars, "ColumnFilter");
	if (selectedFilter ~= nil) then
		colFiltersBtn:SelectListItemByValue(selectedFilter);
	else
		colFiltersBtn:SelectListItemByValue("Condensed");
		SetVar(pVars, "ColumnFilter", "Condensed");
	end

	UpdateColumnFilter(caller);

	local sessionFilterButton = caller.TitleBar.TitleButtons.StationFilters;
	sessionFilterButton.Target = caller.Content.Consoles.Internals.GridBase.GridSettings.GridObjectContentFilter.InMySession
	sessionFilterButton:ClearList();
	sessionFilterButton:AddListStringItem("All", "0");
	sessionFilterButton:AddListStringItem("InSession", "1");
	sessionFilterButton:SelectListItemByValue("0");
	local filter = caller.Content.Consoles.Internals.GridBase.GridSettings.GridObjectContentFilter.InMySession
	filter.Enabled = 0



	HookObjectChange(signalTable.DeviceConfigurationChanged, DeviceConfiguration(), my_handle:Parent(), caller);
	signalTable.DeviceConfigurationChanged(nil, nil, caller)


	-- ShowConnectors button
	local hType = HostType()
    local hSubType = HostSubType()
	local isSupportedConsole = (hType == "Console") and ((hSubType == "FullSize") or (hSubType == "FullSizeCRV") or (hSubType == "Light") or (hSubType == "LightCRV"));
	if isSupportedConsole then
		signalTable.ConnectorViewClick(nil, nil)
		FindBestFocus(caller.Content.Consoles)
		local dep = {}
		dep[1] = "ConnectorView" --ConnectorView buddy id
		caller.DependentBuddies = dep
	else
		caller.FunctionButtons.FunctionRight.ShowConnectors.Visible = false;
	end
end

signalTable.SaveDeviceConfiguration = function(caller,dummy,target)
	local libExport = Root().Menus.LibraryExport;
	if (libExport) then
		local libExportUI = libExport:CommandCall(caller,false);
		if (libExportUI) then
			libExportUI.Context = DeviceConfiguration();
			libExportUI:InputSetAdditionalParameter("PathType", "deviceconfigurations");
			libExportUI:InputSetAdditionalParameter("HelpText", "Pressing Save will export the Output Configuration and DMX Protocols. \nAll listed stations will be saved.");
			libExportUI:InputSetAdditionalParameter("SaveInsteadOfExport", "1");
			libExportUI:InputSetTitle("Save Device Configuration as:");
			libExportUI:InputRun();

			libExportUI:Parent():Remove(libExportUI:Index());
			WaitObjectDelete(libExportUI, 1);
			FindNextFocus();
		end
	end
end

signalTable.LoadDeviceConfiguration = function(caller,dummy,target)
	local libImport = Root().Menus.LibraryImport;
	if (libImport) then
		local libImportUI = libImport:CommandCall(caller,false);
		if (libImportUI) then
			local currentDest = CmdObj().Destination;
			Cmd("cd Root DeviceConfigurations")
			libImportUI:InputSetAdditionalParameter("Destination", "Root DeviceConfigurations");
			libImportUI:InputSetAdditionalParameter("Library", "Library");
			libImportUI:InputSetAdditionalParameter("HelpText", "Pressing Load will import the Output Configuration and DMX Protocols from the selected file. \nAll stations in the file will be loaded.");
			libImportUI:InputSetAdditionalParameter("LoadInsteadOfImport", "1");
			libImportUI:InputSetTitle("Load Device Configuration from:");
			libImportUI:InputRun();

			libImportUI:Parent():Remove(libImportUI:Index());
			WaitObjectDelete(libImportUI, 1);
			Cmd("cd Root ".. ToAddr(currentDest))
			FindNextFocus();
		end
	end
end

signalTable.DeviceConfigurationChanged=function(signal, dummy, caller)
    if(caller) then
		local DeviceConfigName = DeviceConfiguration().FileName
		if (DeviceConfigName ~= "") then
			caller.TitleBar.TitleButton.Text = DeviceConfigName .. " - Output Configuration"
		else
			caller.TitleBar.TitleButton.Text = "Output Configuration"
		end
	end
end

--return Main
