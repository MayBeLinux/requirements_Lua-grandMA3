local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.TabChanged = function( caller,status,creator )
	local maindlgContent = caller:Parent();
	local discoveryCount   = DeviceConfiguration().DMXProtocols.sACN.sACNDiscoveryCollect:Count()
	if caller.SelectedItemIdx == 1 and discoveryCount == 0 then
		maindlgContent.NoDiscoveryInfo.Visible = "Yes"
		maindlgContent.TabData.Visible = "No"
	else
		maindlgContent.NoDiscoveryInfo.Visible = "No"
		maindlgContent.TabData.Visible = "Yes"
	end
	local overlay = caller:GetOverlay()
	if caller.SelectedItemIdx == 0 then
		overlay.FunctionButtons.FunctionRight.DeleteNodes.Enabled = false;
		overlay.FunctionButtons.FunctionRight.DeleteInactiveNodes.Enabled = false;
		overlay.FunctionButtons.FunctionLeft.Enabled = true;
	else
		overlay.FunctionButtons.FunctionRight.DeleteNodes.Enabled = true;
		overlay.FunctionButtons.FunctionRight.DeleteInactiveNodes.Enabled = true;
		overlay.FunctionButtons.FunctionLeft.Enabled = false;
	end
	local sACN = DeviceConfiguration().DMXProtocols.sACN
	if caller.SelectedItemIdx == 1 and sACN.In == false and sACN.SetupMode==false then
		maindlgContent.NoInputInfo.Visible = "Yes"
	else
		maindlgContent.NoInputInfo.Visible = "No"
	end
end

signalTable.sACNLoaded = function( caller,status,creator )
	caller.sACN:SetChildren("Target", DeviceConfiguration().DMXProtocols.sACN)
	caller.TabData.Data.ObjectGrid.TargetObject =  DeviceConfiguration().DMXProtocols.sACN.sACNDataCollect
	caller.TabData.Discovery.ObjectGrid.TargetObject =  DeviceConfiguration().DMXProtocols.sACN.sACNDiscoveryCollect

	HookObjectChange(signalTable.sACNDiscoChanged   ,DeviceConfiguration().DMXProtocols.sACN.sACNDiscoveryCollect  ,my_handle:Parent(), caller);
	HookObjectChange(signalTable.InputInfosACNChanged   ,DeviceConfiguration().DMXProtocols.sACN.sACNDataCollect  ,my_handle:Parent(), caller);
	HookObjectChange(signalTable.InputInfosACNChanged   ,DeviceConfiguration().DMXProtocols.sACN  ,my_handle:Parent(), caller);
	signalTable.sACNDiscoChanged(caller, my_handle:Parent(), caller)
	signalTable.InputInfosACNChanged(caller, my_handle:Parent(), caller)
end

signalTable.DeleteInactive = function( caller,status,creator )
	local sACNNodes = DeviceConfiguration().DMXProtocols.sACN.sACNDiscoveryCollect
	local NodeCount = sACNNodes:Count()
	for i = NodeCount, 1, -1 do
		local Node = sACNNodes[i]
		local PageCount = Node:Count()
		for k = PageCount, 1, -1 do
			if (Node[k].Active == false) then
				Node:Remove(k)
			end
		end
		if (Node.Active == false) then
			sACNNodes:Remove(i)
		end
	end
end

signalTable.sACNDiscoChanged = function( caller,status,maindlgContent )
	local tabContainer = maindlgContent.sACNTabs
	local discoveryCount   = DeviceConfiguration().DMXProtocols.sACN.sACNDiscoveryCollect:Count()
	if tabContainer.SelectedItemIdx == 1 and discoveryCount == 0 then
		maindlgContent.NoDiscoveryInfo.Visible = "Yes"
		maindlgContent.TabData.Visible = "No"
	else
		maindlgContent.NoDiscoveryInfo.Visible = "No"
		maindlgContent.TabData.Visible = "Yes"
	end
end

signalTable.InputInfosACNChanged = function( caller,status,maindlgContent )
	local sACN = DeviceConfiguration().DMXProtocols.sACN
	local tabContainer = maindlgContent.sACNTabs
	if tabContainer.SelectedItemIdx == 1 and sACN.In == false and sACN.SetupMode==false then
		maindlgContent.NoInputInfo.Visible = "Yes"
	else
		maindlgContent.NoInputInfo.Visible = "No"
	end
	if tabContainer.SelectedItemIdx == 0 and sACN.DataValid == false then
		maindlgContent.NoInputInfo2.Visible = "Yes"
	else
		maindlgContent.NoInputInfo2.Visible = "No"
	end
end

signalTable.SendIfIdleButtonLoaded = function(caller,status,creator)
	HookObjectChange(signalTable.OutputStationChanged, DeviceConfiguration().OutputStations, my_handle:Parent(), caller);
	signalTable.OutputStationChanged(nil, nil, caller)
end

signalTable.OutputStationChanged=function(signal, dummy, caller)
    local MyOutputStation = DeviceConfiguration().OutputStations.MyOutputStation;
	if (IsObjectValid(MyOutputStation) == true) then
		caller.Target = MyOutputStation
	end
end

signalTable.SacnMenuLoaded = function(caller, str)
	HookObjectChange(signalTable.DeviceConfigurationChanged, DeviceConfiguration(), my_handle:Parent(), caller);
	signalTable.DeviceConfigurationChanged(nil, nil, caller)
end

signalTable.DeviceConfigurationChanged=function(signal, dummy, caller)
    local DeviceConfigName = DeviceConfiguration().FileName
	if (DeviceConfigName ~= "") then
		caller.TitleBar.TitleButton.Text = DeviceConfigName .. " - sACN"
	else
		caller.TitleBar.TitleButton.Text = "sACN"
	end

end