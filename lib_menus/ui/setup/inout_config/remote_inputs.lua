local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local RemoteName = {
	DC = "DCGrid",
	MIDI = "MIDIGrid",
	Dmx = "DmxGrid",
	OSC = "OSCData",
	PSN = "PSNData",
	MVR = "MVRxchange"
	}

signalTable.setRemoteTargets = function(caller)
	local remoteCollect = Root().ShowData.Remotes
	local subCollect

	if(caller.Name == RemoteName.DC) then
		subCollect = remoteCollect.DCRemotes
	elseif(caller.Name == RemoteName.MIDI) then
		subCollect = remoteCollect.MIDIRemotes
	elseif(caller.Name == RemoteName.Dmx) then
		subCollect = remoteCollect.DmxRemotes
	elseif(caller.Name == RemoteName.OSC) then
		subCollect = Root().ShowData.OSCBase
	else
		subCollect = Root().ShowData.PSNProtocol
	end

	caller.TargetObject = subCollect
end

signalTable.ContentChange = function( caller,status,creator )
	local overlay = caller:GetOverlay()
	if caller.SelectedItemIdx == 3 then
		overlay.FunctionButtons.empty.Visible = false;
		overlay.FunctionButtons.osc.Visible = true;
		overlay.FunctionButtons.mvr.Visible = false;
		overlay.FunctionButtons.FunctionLeft.ButtonBack.Visible = false;
		overlay.FunctionButtons.FunctionLeft:Find("Insert").Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Delete").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Cut.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Copy").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Paste.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Import").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Undo.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Export").Visible = true;
	elseif caller.SelectedItemIdx == 5 then
		overlay.FunctionButtons.empty.Visible = false;
		overlay.FunctionButtons.osc.Visible= false;
		overlay.FunctionButtons.mvr.Visible= true;
		overlay.FunctionButtons.FunctionLeft.ButtonBack.Visible = true;
		signalTable.MVRTabChanged(overlay.Content.Dialogs.MVRxchange.MvrTabs, status, creator)
	else
		overlay.FunctionButtons.empty.Visible = true;
		overlay.FunctionButtons.osc.Visible= false;
		overlay.FunctionButtons.mvr.Visible = false;
		overlay.FunctionButtons.FunctionLeft.ButtonBack.Visible = false;
		overlay.FunctionButtons.FunctionLeft:Find("Insert").Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Delete").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Cut.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Copy").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Paste.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Import").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Undo.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Export").Visible = true;
	end
end

signalTable.SendServiceCommand = function(overlay, ObjectType, Command)
	local grid = overlay.Content.Dialogs.MVRxchange.Grids.Services.MvrServicesGrid;
	local grSel = grid:GridGetSelection();
	local selectedItems = grSel.SelectedItems;

	for i,v in ipairs(selectedItems) do
		local object = IntToHandle(v.row);
		if object~=-1 and object:IsClass(ObjectType) then
			Echo(Command .. " ".. object.Name .. "   " .. object.UUID)
			CmdIndirect("SendMVR '"..Command.."' '"..object.No.."'")
		else
			Echo("No Service selected")
		end
	end
end

signalTable.RequestClicked = function(caller,signal)
	local grid = caller:GetOverlay().Content.Dialogs.MVRxchange.Grids.Files.MvrFilesGrid;
	local grSel = grid:GridGetSelection();
	local selectedItems = grSel.SelectedItems;

	for i,v in ipairs(selectedItems) do
		local object = IntToHandle(v.row);
		if object~=-1 and object:IsClass("MVRFile") then
			Echo("Requesting ".. object.Name .. "   " .. object.UUID)
			CmdIndirect("SendMVR 'Request' '"..object.No.."'")
		else
			Echo("No FIle selected")
		end
	end
end

signalTable.LeaveClicked = function(caller,signal)
	signalTable.SendServiceCommand(caller:GetOverlay(), "MVRService", "Leave")
end

signalTable.JoinClicked = function(caller,signal)
	signalTable.SendServiceCommand(caller:GetOverlay(), "MVRService", "Join")
end

signalTable.OnLoaded = function(caller,status,creator)
	local FilesGrid = caller:GetOverlay().Content.Dialogs.MVRxchange.Grids.Files.MvrFilesGrid;
	local FilesGrSel = FilesGrid:GridGetSelection();
	HookObjectChange(signalTable.FilesGridSelectionChanged, FilesGrSel, my_handle:Parent(), caller:GetOverlay());
	signalTable.FilesGridSelectionChanged(FilesGrSel, my_handle:Parent(), caller:GetOverlay())

	local ServicesGrid = caller:GetOverlay().Content.Dialogs.MVRxchange.Grids.Services.MvrServicesGrid;
	local ServicesGrSel = ServicesGrid:GridGetSelection();
	HookObjectChange(signalTable.ServicesGridSelectionChanged, ServicesGrSel, my_handle:Parent(), caller:GetOverlay());
	signalTable.ServicesGridSelectionChanged(ServicesGrSel, my_handle:Parent(), caller:GetOverlay())

	local MVRExchangeEnabled = Root().ShowData.MVRxchange
	HookObjectChange(signalTable.MVRExchangeChanged, MVRExchangeEnabled, my_handle:Parent(), caller:GetOverlay());

end

signalTable.FilesGridSelectionChanged = function(grSel,signal, overlay)
	local selectedItems = grSel.SelectedItems;
	local RequestButton = overlay.FunctionButtons.mvr.RequestButton

	for i,v in ipairs(selectedItems) do
		local object = IntToHandle(v.row);
		if IsObjectValid(object)  and object:IsClass("MVRFile") then
			RequestButton.Enabled = true
		else
			RequestButton.Enabled = false
		end
	end
end

signalTable.ServicesGridSelectionChanged = function(grSel,signal, overlay)
	local selectedItems = grSel.SelectedItems;
	local JoinButton = overlay.FunctionButtons.mvr.JoinButton
	local LeaveButton = overlay.FunctionButtons.mvr.LeaveButton

	for i,v in ipairs(selectedItems) do
		local object = IntToHandle(v.row);
		if IsObjectValid(object) and object:IsClass("MVRService") and not object.IsMyself then
			if not object.Joined then
				JoinButton.Enabled = true
				LeaveButton.Enabled = false
			elseif not object.Left then
				JoinButton.Enabled = false
				LeaveButton.Enabled = true
			else
				JoinButton.Enabled = false
				LeaveButton.Enabled = false
			end
		else
			JoinButton.Enabled = false
			LeaveButton.Enabled = false
		end
	end
end

signalTable.MVRTabChanged = function( caller,status,creator )
	local overlay = caller:GetOverlay()
	local CommitsTabIndex = 0
	local ServicesTabIndex = 1
	local FilesTabIndex = 2
	local MVRExchangeEnabled = Root().ShowData.MVRxchange.Enabled
	overlay.FunctionButtons.FunctionLeft:Find("Insert").Visible = false;
	overlay.FunctionButtons.FunctionLeft.Cut.Visible = false;
	overlay.FunctionButtons.FunctionLeft:Find("Copy").Visible = false;
	overlay.FunctionButtons.FunctionLeft.Paste.Visible = false;
	overlay.FunctionButtons.FunctionLeft:Find("Import").Visible = false;
	overlay.FunctionButtons.FunctionLeft:Find("Export").Visible = false;
	if caller.SelectedItemIdx == ServicesTabIndex then
		overlay.FunctionButtons.mvr.RequestButton.Enabled = false;
		overlay.FunctionButtons.mvr.RequestButton.Visible = false;
		overlay.FunctionButtons.mvr.CommitButton.Enabled = false;
		overlay.FunctionButtons.mvr.CommitButton.Visible = false;
		overlay.FunctionButtons.mvr.JoinButton.Enabled = MVRExchangeEnabled;
		overlay.FunctionButtons.mvr.JoinButton.Visible = true;
		overlay.FunctionButtons.mvr.LeaveButton.Enabled = MVRExchangeEnabled;
		overlay.FunctionButtons.mvr.LeaveButton.Visible = true;
		overlay.FunctionButtons.FunctionLeft:Find("Delete").Visible = false;
		overlay.FunctionButtons.FunctionLeft.Undo.Visible = false;
	elseif caller.SelectedItemIdx == FilesTabIndex then
		overlay.FunctionButtons.mvr.RequestButton.Enabled = MVRExchangeEnabled;
		overlay.FunctionButtons.mvr.RequestButton.Visible = true;
		overlay.FunctionButtons.mvr.CommitButton.Enabled = MVRExchangeEnabled;
		overlay.FunctionButtons.mvr.CommitButton.Visible = true;
		overlay.FunctionButtons.mvr.JoinButton.Enabled = false;
		overlay.FunctionButtons.mvr.JoinButton.Visible = false;
		overlay.FunctionButtons.mvr.LeaveButton.Visible = false;
		overlay.FunctionButtons.mvr.LeaveButton.Enabled = false;
		overlay.FunctionButtons.FunctionLeft:Find("Delete").Visible = false;
		overlay.FunctionButtons.FunctionLeft.Undo.Visible = false;
	else -- Local Tab
		overlay.FunctionButtons.mvr.RequestButton.Enabled = false;
		overlay.FunctionButtons.mvr.RequestButton.Visible = false;
		overlay.FunctionButtons.mvr.CommitButton.Enabled = false;
		overlay.FunctionButtons.mvr.CommitButton.Visible = false;
		overlay.FunctionButtons.mvr.LeaveButton.Enabled = false;
		overlay.FunctionButtons.mvr.LeaveButton.Visible = false;
		overlay.FunctionButtons.mvr.JoinButton.Enabled = false;
		overlay.FunctionButtons.mvr.JoinButton.Visible = false;
		overlay.FunctionButtons.FunctionLeft:Find("Delete").Visible = true;
		overlay.FunctionButtons.FunctionLeft.Undo.Visible = true;
	end
	
	if(MVRExchangeEnabled) then
		local FilesGrid = overlay.Content.Dialogs.MVRxchange.Grids.Services.MvrServicesGrid;
		local FilesGrSel = FilesGrid:GridGetSelection();
		signalTable.FilesGridSelectionChanged(FilesGrSel, my_handle:Parent(), overlay)

		local ServicesGrid = overlay.Content.Dialogs.MVRxchange.Grids.Services.MvrServicesGrid;
		local ServicesGrSel = ServicesGrid:GridGetSelection();
		signalTable.ServicesGridSelectionChanged(ServicesGrSel, my_handle:Parent(), overlay)
	end
end

signalTable.MVRExchangeChanged = function( caller,status,overlay )
	signalTable.MVRTabChanged(overlay.Content.Dialogs.MVRxchange.MvrTabs, caller, caller)
end
