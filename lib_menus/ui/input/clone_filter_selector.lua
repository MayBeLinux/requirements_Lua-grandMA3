local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.JumpToGrid = function(caller)
    FindNextFocus();
end


signalTable.DoAddFilter = function(caller)
    
    local selectedObjects = "";

    local selection = caller:Parent():Parent().FrameFilter.FilterGrid:GridGetSelection().SelectedItems
	local n = #selection
    for i=1,n,1 do
	    local f = IntToHandle(selection[i].row)
		selectedObjects = selectedObjects .. HandleToStr(f);
        if i < n then
            selectedObjects = selectedObjects .. " ";
        end
	end

    if selectedObjects == "" then
        caller:GetOverlay().Value = "clear_selection";
    else
        caller:GetOverlay().Value = selectedObjects;
    end
    caller:GetOverlay():Close();
    
end

signalTable.DoSelectNone = function(caller)
    local grid = caller:Parent():Parent().FrameFilter.FilterGrid;
    local selection = grid:GridGetSelection().SelectedItems
	local n = #selection
    if n > 0 then
        grid:ClearSelection();
    end

    signalTable.DoAddFilter(caller);
end

signalTable.DoSelectAll = function(caller)
    local grid = caller:Parent():Parent().FrameFilter.FilterGrid;
    grid:ExpandAll()
    grid:SelectAllRows()	

    signalTable.DoAddFilter(caller);
end

signalTable.OnGridDataPoolLoaded = function(caller,status,creator)
    
    local target = caller.TargetObject;	
    if(target ~= nil) then
       if (target:GetClass() == "PresetPools") then
          caller.LevelLimit = 1;
       else
          caller.LevelLimit = 0;
       end
	end	
end

signalTable.OnDataPoolLoaded = function(caller,status,creator)
    
   local target = caller:Parent():Parent():Parent().Frame.FrameFilter.FilterGrid.TargetObject;	
    if(target ~= nil) then
       caller:SelectListItemByIndex(target:Parent().no);
    else
       local selectedPool = CurrentProfile().SelectedDataPool;
       if(selectedPool ~= nil) then
           caller:SelectListItemByIndex(selectedPool.no);
       end
	end	
end

signalTable.OnDataPoolChanged = function(caller)
	
    local index = caller:GetListSelectedItemIndex();
    local grid = caller:Parent():Parent():Parent().Frame.FrameFilter.FilterGrid;
    local currentTarget = grid.TargetObject;	
    if(currentTarget ~= nil) then
       local newTarget = currentTarget:Parent():Parent():Ptr(index):Ptr(currentTarget.no);
       grid.TargetObject = newTarget;       
    end
	
end



