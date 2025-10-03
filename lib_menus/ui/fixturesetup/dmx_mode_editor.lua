local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);


local function UpdateConflictsButton(btn, ft)
	local ed = btn:GetOverlay();
	local mode = ed.EditTarget;
	local blindbutton = ed.Functions.Right.Blindbutton;

	local conflicts = mode.ConflictCount;
	if (conflicts > 0) then
		btn.Text = "Show Conflicts ("..conflicts..")";
		btn.TextColor = "Global.AlertText";
		btn.Visible = true;
		blindbutton.Visible = false;
	else
		btn.Text = "No conflicts";
		btn.TextColor = "Global.Text";
		btn.Visible = false;
		blindbutton.Visible = true;
	end
end

local function OnDmxModeChanged(obj, change, ctx)
	if (IsObjectValid(obj) and IsObjectValid(ctx)) then
		UpdateConflictsButton(ctx, obj);
	end
end

signalTable.OnDmxModeEditorLoaded = function(caller,status,creator)
	local Content      = caller.Content;
	local TopLevelTab  = Content.TopLevelTab;
	local dmx_mode     = TopLevelTab.Target;
	local dmx_channels = dmx_mode:Ptr(1);

	for i = 1,dmx_mode:Count(),1 do
		local child = dmx_mode:Ptr(i);
		local name = child.Name
		if(child:IsClass("DMXChannels") == true) then
			name = name.. " ("..dmx_mode.TotalFootPrint..")"
		end
		if (not BuildDetails().IsRelease or ReleaseType() == "Alpha") then
			TopLevelTab:AddListNumericItem(name, HandleToInt(child), child);
		else
			if (child:IsClass("FTMacros") == false) then
				TopLevelTab:AddListNumericItem(name, HandleToInt(child), child);
			end
		end

	end
	TopLevelTab:SelectListItemByName(dmx_channels.Name);
	Content.TopLevelGrid.TargetObject = dmx_channels;
	Content.TopLevelGrid:GridGetData().UseLocalExpandedState = true;

	caller.Functions.Right.DMXReadout.Target = CmdObj();

	local ft = dmx_mode:Parent():Parent()
	local conflictBtn = caller:FindRecursive("Conflicts", "Button");
	HookObjectChange(OnDmxModeChanged, ft, my_handle:Parent(), conflictBtn);
	UpdateConflictsButton(conflictBtn, ft);
end

signalTable.ShowConflicts = function(caller)
	local ed = caller:GetOverlay();
	local di = ed:GetDisplayIndex();
	local mode = ed.EditTarget;
	if (mode) then
		local msg = "";
		local first = true;
		if (mode.ConflictCount > 0) then
			if first == true then first = false;
			else msg = msg .. "\n\n";
			end
			msg = msg .. "DMX Module '".. mode.Name .. "':\n" .. mode.ConflictSummary;
		end

		if (msg ~= "") then
			msg = msg:gsub("^%s*(.-)%s*$", "%1");
			MessageBox(
				{title="Conflicts summary",
				message=msg,
				message_align_h=Enums.AlignmentH.Left,
				display = di,
				commands={{value=1, name="Ok"}}
			});
		end
	end
end


