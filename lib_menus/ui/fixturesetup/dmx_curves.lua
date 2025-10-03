local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local selCurve


local function UpdateConflictsButton(btn, CurveCollection)
	local NotInvertibleCount = CurveCollection.NotInvertibleCount;
	local ApproxInvertibleCount = CurveCollection.ApproxInvertibleCount;

	local conflicts = NotInvertibleCount + ApproxInvertibleCount;

	if (NotInvertibleCount > 0) then
		btn.Text = "Show Warnings ("..conflicts..")";
		btn.TextColor = "DBObjectGrid.WrongText";
		btn.Visible = true;
		btn:Parent().FunctionsPlaceholderButton.Anchors = "2,1,3,1"
	elseif (ApproxInvertibleCount > 0 ) then
		btn.Text = "Show Warnings ("..conflicts..")";
		btn.TextColor = "DBObjectGrid.WarningText";
		btn.Visible = true;
		btn:Parent().FunctionsPlaceholderButton.Anchors = "2,1,3,1"
	else
		btn.Text = "No Warnings";
		btn.TextColor = "Global.Text";
		btn.Visible = false;
		btn:Parent().FunctionsPlaceholderButton.Anchors = "1,1,3,1"
	end
end


local function OnDmxCurvesChanged(obj, change, ctx)
	if (IsObjectValid(obj) and IsObjectValid(ctx)) then
		UpdateConflictsButton(ctx, obj);
	end
end


signalTable.OnDmxCurvesDialogLoaded = function(caller,status,creator)
	local grid = caller.Content.CurvePointGrid;
	local CurveCollection = grid.TargetObject;
	if (CurveCollection) then
		local conflictBtn = caller:FindRecursive("Conflicts", "Button");
		HookObjectChange(OnDmxCurvesChanged, CurveCollection, my_handle:Parent(), conflictBtn);
		UpdateConflictsButton(conflictBtn, CurveCollection);
	end


	--init DMXReadout
	local dmxreadout = caller.FunctionButtons.FunctionRight.DMXReadout;
	if (dmxreadout) then
		dmxreadout.Target = CmdObj();
	end
end

signalTable.SetTarget = function(caller,status,creator)
	caller.Target = caller:GetOverlay()
end

signalTable.OnSelectedRowChanged = function(caller,status,creator)
	local selection = caller:GridGetSelection();
	local items = selection.SelectedItems;
	if(#items >= 1) then
		selCurve = IntToHandle(items[1].row)
		if not (selCurve.CurveMode)then
			selCurve = selCurve:Parent()
		end
	end
	local ToolBar = caller:Parent().Square.MainToolBar
	if(selCurve.CurveMode == "Custom") then
		ToolBar.AddAbsolute.Enabled = true
		ToolBar.DelSteps.Enabled = true 
		ToolBar.MoveHandle.Enabled = true 
	else
		ToolBar.AddAbsolute.Enabled = false 
		ToolBar.DelSteps.Enabled = false
		ToolBar.MoveHandle.Enabled = false
	end
end

signalTable.ShowConflicts = function(caller)
	local ed = caller:GetOverlay();
	local di = ed:GetDisplayIndex();
	local grid = ed.Content.CurvePointGrid;
	local CurveCollection = grid.TargetObject;
	if (CurveCollection) then
		local msg = CurveCollection.ConflictSummary;

		if (msg ~= "") then
			msg = msg:gsub("^%s*(.-)%s*$", "%1");
			MessageBox(
				{title="Warning summary",
				message=msg,
				message_align_h=Enums.AlignmentH.Left,
				display = di,
				commands={{value=1, name="Ok"}}
			});
		end
	end
end