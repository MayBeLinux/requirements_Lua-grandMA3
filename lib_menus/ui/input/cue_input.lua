local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function updateTitle(overlay,target)
	if target and IsObjectValid(target) then
		local oldInfo = overlay.TitleBar.Title.Text;
		local addInfo = target:Get("Name",Enums.Roles.Display);
		if oldInfo and addInfo and addInfo ~= "" then
			overlay.TitleBar.Title.Text = string.format("%s of %s",oldInfo,addInfo);
		end
	end
end

signalTable.OnLoaded = function(caller,status,creator)
	caller.Frame.CueGrid.TargetObject = caller.context;

	updateTitle(caller,caller.context);

	local cue = caller.context.CurrentCue;
	if cue then
		local grid = caller.Frame.CueGrid
		grid.ItemPlacementOffsetFactorH=0.5 -- so that selected row is in middle
		local CueToSelect = StrToHandle(caller.Value);
		if IsObjectValid(CueToSelect) then
		   grid:SelectRow(HandleToInt(CueToSelect));
		else
		   grid:SelectRow(HandleToInt(caller.context.CurrentCue))
		end
		local sel = grid:GridGetSelectedCells()[1];
		grid:GridScrollCellIntoView(sel);
		-- FindNextFocus(); -- focus on grid
		-- grid.ClearSelection();
	end
end

signalTable.SetGridAsTarget = function(caller)
	local overlay = caller:GetOverlay();
	caller.target = overlay.Frame.CueGrid.Internals.GridBase.GridSettings.GridObjectContentFilter.Filter
end


signalTable.JumpToGrid = function(caller)
	FindNextFocus();
end

signalTable.OnCueSelected = function(caller,status,creator)
	local selected = IntToHandle(caller.SelectedRow);
	Echo("Selected cue: "..selected:ToAddr())
	
	local o = caller:GetOverlay();
	o.Value = HandleToStr(selected);
	o.Close();
end