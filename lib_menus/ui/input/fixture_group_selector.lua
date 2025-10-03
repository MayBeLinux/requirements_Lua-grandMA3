local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local visibleTab = "FrameFixtures";
local contextButtonText = "";

signalTable.JumpToGrid = function(caller)
    FindNextFocus();
end

signalTable.OnLoaded = function(caller,status,creator)
     contextButtonText = caller.StrContext;
end

signalTable.OnLoadedPleaseButton = function(caller,status,creator)
     caller.Text = contextButtonText;
end

signalTable.OnTabChanged = function(caller,nextVisible)
    visibleTab = nextVisible;
--    if (visibleTab == "FrameGroups") then
--        caller:Parent():Parent().TitleBar.AutoButtons.DataPoolSelector.Visible = 1;
--    else
--        caller:Parent():Parent().TitleBar.AutoButtons.DataPoolSelector.Visible = 0;
--    end
end

--signalTable.OnDataPoolLoaded = function(caller,status,creator)    
--    local target = caller:Parent():Parent():Parent().Frame.DC.FrameGroups.GroupGrid.TargetObject;	
--    if(target ~= nil) then
--       caller:SelectListItemByIndex(target:Parent().no);
--    else
--       local selectedPool = CurrentProfile().SelectedDataPool;
--       if(selectedPool ~= nil) then
--           caller:SelectListItemByIndex(selectedPool.no);
--       end
--	end	
--end

--signalTable.OnDataPoolChanged = function(caller)	
--    local index = caller:GetListSelectedItemIndex();
--    local currentTarget = caller:Parent():Parent():Parent().Frame.DC.FrameGroups.GroupGrid.TargetObject;	
--    if(currentTarget ~= nil) then
--       local newTarget = currentTarget:Parent():Parent():Ptr(index):Ptr(4 + 1);
--       caller:Parent():Parent():Parent().Frame.DC.FrameGroups.GroupGrid.TargetObject = newTarget;
--	end
	
--end

signalTable.DoAddFixtures = function(caller)
    
    local selectedObjects = "";

    if (visibleTab == "FrameFixtures") then
        local selection = caller:Parent().DC.FrameFixtures.FixtureGrid:GridGetSelection().SelectedItems
		local n = #selection
     	if n > 0 then

            for i=1,n,1 do
				local f = IntToHandle(selection[i].row)
				selectedObjects = selectedObjects .. HandleToStr(f);
                if i < n then
                    selectedObjects = selectedObjects .. " ";
                end
			end

            caller:GetOverlay().Value = selectedObjects;
            caller:GetOverlay():Close();
        end
    else
        local selection = caller:Parent().DC.FrameGroups.GroupGrid:GridGetSelection().SelectedItems
		local n = #selection
     	if n > 0 then

            for i=1,n,1 do
				local f = IntToHandle(selection[i].row)
				selectedObjects = selectedObjects .. HandleToStr(f);
                if i < n then
                    selectedObjects = selectedObjects .. " ";
                end
			end

            caller:GetOverlay().Value = selectedObjects;
            caller:GetOverlay():Close();
        end
    end
end

-- ---------------------- GROUP SOURCE GRID ----------------------------

signalTable.OnGroupGridLoaded = function(caller,status,creator)    
    if(caller.TargetObject == nil) then
        caller.TargetObject = CurrentProfile().SelectedDataPool.Groups;
    end
end

