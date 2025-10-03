local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.hookChangesFor_sACN = function(tabList)
	HookObjectChange(signalTable.sACNChanged   ,DeviceConfiguration().DMXProtocols.sACN  ,my_handle:Parent(), tabList);
	HookObjectChange(signalTable.sACNChanged   ,DeviceConfiguration().DMXProtocols.sACN.sACNDataCollect  ,my_handle:Parent(), tabList);
	HookObjectChange(signalTable.ManetsACN   ,Root().ManetSocket  ,my_handle:Parent(), tabList);
	signalTable.sACNChanged(tabList, my_handle:Parent(), tabList)	
end

signalTable.sACNChanged = function(caller,status, tabList)
	local ColorTheme = Root().ColorTheme.ColorGroups;
	local sACN = DeviceConfiguration().DMXProtocols.sACN;
	local ManetSocket=Root().ManetSocket;
	local SendIfIdle = false;

	local HasRequestedData = false
	local sACNDataCollect = sACN.sACNDataCollect
	for i,sACNData in ipairs(sACNDataCollect:Children()) do
		HasRequestedData = sACNData.Enabled
		if (HasRequestedData  == "Yes") then
			break
		end
	end
	local Outputstation = DeviceConfiguration().OutputStations.MyOutputStation;
	if (IsObjectValid(Outputstation) == true) then 
		SendIfIdle = Outputstation.SendSacnIfIdleMaster
	end

	local addInfo = ""
	if (sACN.In == true) then
		addInfo = "in"
	end
	if (sACN.Out == true) then
		if addInfo ~= "" then addInfo = addInfo.."/" end
		addInfo = addInfo.."out"
	end

	local color = nil;
	if (HasRequestedData=="Yes" and (ManetSocket.Status == "LocalMaster" or ManetSocket.Status == "IdleMaster" or ManetSocket.Status == "GlobalMaster" or ManetSocket.Status == "Connected")) then
		if (sACN.In==true) then
			if(sACN.Out==true and (ManetSocket.Status ~= "IdleMaster" or SendIfIdle)) then
				color=ColorTheme.DMXState.InAndOutActive;
			else
				color=ColorTheme.DMXState.In;
			end
		else 
			if(sACN.Out==true and (ManetSocket.Status ~= "IdleMaster" or SendIfIdle)) then
				color=ColorTheme.DMXState.Out;
			else
				color=ColorTheme.DMXState.Off;
			end
		end
	else
			color=ColorTheme.DMXState.Off;
	end

	tabList:SetListItemAppearance(2, {left={back_color=color.Val32}})
	tabList:SetListItemAdditionalInfo(2, addInfo)
end

signalTable.ManetsACN = function(caller,status, tabList)
	signalTable.sACNChanged(caller, status, tabList)
end

signalTable.hookChangesFor_ArtNet = function(tabList)
	HookObjectChange(signalTable.ArtNetChanged   ,DeviceConfiguration().DMXProtocols.ArtNet  ,my_handle:Parent(), tabList);
	HookObjectChange(signalTable.ArtNetChanged   ,DeviceConfiguration().DMXProtocols.ArtNet.ArtNetDataCollect  ,my_handle:Parent(), tabList);
	HookObjectChange(signalTable.ManetArtNet   ,Root().ManetSocket  ,my_handle:Parent(), tabList);
	signalTable.ArtNetChanged(tabList, my_handle:Parent(), tabList)	
end

signalTable.ArtNetChanged = function(caller,status, tabList)
	local ColorTheme = Root().ColorTheme.ColorGroups;
	local ArtNet = DeviceConfiguration().DMXProtocols.ArtNet;
	local ManetSocket=Root().ManetSocket;
	local SendIfIdle = false;

	local addInfo = ""

	local HasRequestedData = false
	local ArtNetDataCollect = ArtNet.ArtNetDataCollect
	for i,ArtnetData in ipairs(ArtNetDataCollect:Children()) do
		HasRequestedData = ArtnetData.Enabled
		if (HasRequestedData  == "Yes") then
			break
		end
	end
	local Outputstation = DeviceConfiguration().OutputStations.MyOutputStation;
	if (IsObjectValid(Outputstation) == true) then 
		SendIfIdle = Outputstation.SendArtnetIfIdleMaster
	end

	if (ArtNet.In == true) then
		addInfo = "in"
	end
	if (ArtNet.Out == true) then
		if addInfo ~= "" then addInfo = addInfo.."/" end
		addInfo = addInfo.."out"
	end

	local color = nil
	if (HasRequestedData=="Yes" and (ManetSocket.Status == "LocalMaster" or ManetSocket.Status == "IdleMaster" or ManetSocket.Status == "GlobalMaster" or ManetSocket.Status == "Connected")) then
		if (ArtNet.In==true) then
			if(ArtNet.Out==true and (ManetSocket.Status ~= "IdleMaster" or SendIfIdle)) then
				color=ColorTheme.DMXState.InAndOutActive;
			else
				color=ColorTheme.DMXState.In;
			end
		else 
			if(ArtNet.Out==true and (ManetSocket.Status ~= "IdleMaster" or SendIfIdle)) then
				color=ColorTheme.DMXState.Out;
			else
				color=ColorTheme.DMXState.Off;
			end
		end
	else 
		color=ColorTheme.DMXState.Off;
	end

	tabList:SetListItemAppearance(1, {left={back_color=color.Val32}})
	tabList:SetListItemAdditionalInfo(1, addInfo)
end

signalTable.ManetArtNet = function(caller,status, tabList)
	signalTable.ArtNetChanged(caller, status, tabList)
end
