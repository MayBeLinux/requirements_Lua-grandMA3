local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	local ed = caller.EditTarget;
	if IsObjectValid(ed) then
		local idx = caller.EditTarget.INDEX;
		local grid = caller.Content.Grid;
		grid.ItemPlacementOffsetFactorH=0.5 -- so that selected row is in middle
		grid:SelectRow(HandleToInt(ed))
		local selCells = grid:GridGetSelectedCells();
		if selCells ~= nil then
			local sel = selCells[3];
			grid:GridScrollCellIntoView(sel);
			FindBestFocus(grid); -- focus on grid
		end
	end
end


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local val = caller.Value;
	local mystage = nil;
	local ed = caller.EditTarget;
	if IsObjectValid(ed) then
		mystage = ed:FindParent("Stage");
		if(mystage ~= nil) then
			caller.Content:SetChildren("Target",mystage);
			caller.Content.Grid.TargetObject = mystage.Spaces;
		end
	end
end

