local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function UpdateConflictsButton(btn, fixtureType)
	local modes = fixtureType.DMXModes;
	local conflicts = 0;
	for i,v in ipairs(modes:Children()) do
		conflicts = conflicts + v.ConflictCount;
	end
		
	if fixtureType.CircleInGeometries then 
		conflicts = conflicts + 1
	end

	local blindbutton = btn:GetOverlay().Functions.Right.Blindbutton;

	if (conflicts > 0 ) then
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

local function OnFixtureTypeChanged(obj, change, ctx)
	if (IsObjectValid(obj) and IsObjectValid(ctx)) then
		UpdateConflictsButton(ctx, obj);
	end
end

signalTable.TopLevelDefintions=
{
	{ LevelLimit = 255; Edit=false; ShowVisualizer=false }, -- attribute definitions
	{ LevelLimit = 255; Edit=false; ShowVisualizer=false }, -- wheels
	{ LevelLimit = 255; Edit=true;  ShowVisualizer=false }, -- physical desc
	{ LevelLimit = 255; Edit=false; ShowVisualizer=false }, -- models
	{ LevelLimit = 255; Edit=false; ShowVisualizer=true  }, -- geometries
	{ LevelLimit = 0;   Edit=true;  ShowVisualizer=false }, -- dmx modes
	{ LevelLimit = 255; Edit=false; ShowVisualizer=false }, -- revisions
	{ LevelLimit = 255; Edit=false; ShowVisualizer=false }, -- protocols
};


signalTable.OnFixtureTypeEditorLoaded = function(caller,status,creator)
	local Content      = caller.Content;
	local TopLevelTab  = Content.TopLevelTab;
	local fixtureType  = TopLevelTab.Target;
	local dmx_modes    = fixtureType:Ptr(6);

	local conflictBtn = caller:FindRecursive("Conflicts", "Button");
	HookObjectChange(OnFixtureTypeChanged, fixtureType, my_handle:Parent(), conflictBtn);
	UpdateConflictsButton(conflictBtn, fixtureType);

	for i = 1,fixtureType:Count(),1 do
		local child = fixtureType:Ptr(i);
		TopLevelTab:AddListNumericItem(child.Name, HandleToInt(child), child);
	end

	TopLevelTab:SelectListItemByName(dmx_modes.Name);
	Content.MiddleContent.TopLevelGrid.TargetObject = dmx_modes;

	caller.Functions.Right.DMXReadout.Target = CmdObj();
end

signalTable.OnTopLevelTabChanged = function(caller,_,tab_id,tab_index)
	local Content = caller:Parent();
	local Overlay = caller:GetOverlay();

	local grid     = Content.MiddleContent.TopLevelGrid;
	local def      = signalTable.TopLevelDefintions[tab_index+1];
	
	grid.TargetObject = IntToHandle(tab_id);
	grid.LevelLimit   = def.LevelLimit;
	grid.AllowAddNewline = def.Edit;

	if Content.MiddleContent.Visualizer then
		Content.MiddleContent.Visualizer.Visible = def.ShowVisualizer
		Content.MiddleContent.Resizer.Visible = def.ShowVisualizer
	end
	Overlay.Functions.Right.Edit.Visible=def.Edit;
	Overlay.Functions.Right.EditBlind.Visible= not def.Edit;
end

signalTable.ShowConflicts = function(caller)
	local ed = caller:GetOverlay();
	local di = ed:GetDisplayIndex();
	local fixtureType = ed.EditTarget;
	if (fixtureType) then
		local msg = "";
		local first = true;
		if(fixtureType.CircleInGeometries) then
			if first == true then first = false;
			else msg = msg .. "\n\n";
			end
			msg = msg .. "The fixture type has an infinite loop in its geometric structure caused by geometry references.";
		end
		local modes = fixtureType.DMXModes;
		for i,v in ipairs(modes:Children()) do
			if (v.ConflictCount > 0) then
				if first == true then first = false;
				else msg = msg .. "\n\n";
				end
				msg = msg .. "DMX Module '".. v.Name .. "':\n" .. v.ConflictSummary;
			end
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

signalTable.SetVisualizerTarget = function(caller)
	caller.Target = caller:Parent():Parent().Visualizer;
end