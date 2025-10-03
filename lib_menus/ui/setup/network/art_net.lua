local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.MainDlgContenLoaded = function(caller)
	caller.ArtNet:SetChildren("Target", DeviceConfiguration().DMXProtocols.ArtNet)
	caller.Grids.Data.ObjectGrid.TargetObject =  DeviceConfiguration().DMXProtocols.ArtNet.ArtNetDataCollect
	caller.Grids.Nodes.ObjectGrid.TargetObject =  DeviceConfiguration().DMXProtocols.ArtNet.ArtNetNodeCollect
end

signalTable.DeleteInactive = function( caller,status,creator )
	local ArtNetNodes = DeviceConfiguration().DMXProtocols.ArtNet.ArtNetNodeCollect
	local IpNodes = ArtNetNodes:Count()
	for i = IpNodes, 1, -1 do
		local IpNode = ArtNetNodes[i]
		local BindIndexCount = IpNode:Count()
		for k = BindIndexCount, 1, -1 do
			if (IpNode[k].IsActive == false) then
				IpNode:Remove(k)
			end
		end
		if (IpNode:Count() == 0) then
			ArtNetNodes:Remove(i)
		end
	end
end

signalTable.MainTabsLoaded = function(caller)
	signalTable.hookChangesFor_ArtNet(caller)
	signalTable.hookChangesFor_sACN(caller)
end

signalTable.TabChanged = function( caller,status,creator )
	local overlay = caller:GetOverlay()
	if caller.SelectedItemIdx == 0 then
		overlay.FunctionButtons.FunctionRight.DeleteNodes.Enabled = false;
		overlay.FunctionButtons.FunctionRight.DeleteInactiveNodes.Enabled = false;
		overlay.FunctionButtons.FunctionLeft.ImportButtonArt.AutoEnabled = "Yes";
		overlay.FunctionButtons.FunctionLeft.ExportButtonArt.AutoEnabled = "Yes";
	else
		overlay.FunctionButtons.FunctionRight.DeleteNodes.Enabled = true;
		overlay.FunctionButtons.FunctionRight.DeleteInactiveNodes.Enabled = true;
		overlay.FunctionButtons.FunctionLeft.ImportButtonArt.AutoEnabled = "No";
		overlay.FunctionButtons.FunctionLeft.ImportButtonArt.Enabled = false;
		overlay.FunctionButtons.FunctionLeft.ExportButtonArt.AutoEnabled = "No";
		overlay.FunctionButtons.FunctionLeft.ExportButtonArt.Enabled = false;
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

signalTable.ArtnetMenuLoaded = function(caller, str)
	HookObjectChange(signalTable.DeviceConfigurationChanged, DeviceConfiguration(), my_handle:Parent(), caller);
	signalTable.DeviceConfigurationChanged(nil, nil, caller)
end

signalTable.DeviceConfigurationChanged=function(signal, dummy, caller)
    local DeviceConfigName = DeviceConfiguration().FileName
	if (DeviceConfigName ~= "") then
		caller.TitleBar.TitleButton.Text = DeviceConfigName .. " - Art-Net"
	else
		caller.TitleBar.TitleButton.Text = "Art-Net"
	end

end