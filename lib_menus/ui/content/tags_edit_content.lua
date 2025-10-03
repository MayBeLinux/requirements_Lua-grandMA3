local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    if (caller.Target) then
        caller.AssignedArea.Frame.AssignedTagsGrid.TargetObject = caller.Target;
    end
end

signalTable.DoUnassign = function(caller,status,creator)
    local tagsEditContent = caller:FindParent("TagsEditContent");
    if (tagsEditContent) then
        tagsEditContent:DoUnassign();
        local cmdO = CmdObj();
        local fakeCollect = cmdO.TagFakeCollect;
        fakeCollect:Changed();
    end
end

signalTable.DoAssign = function(caller,status,creator)
    local tagsEditContent = caller:FindParent("TagsEditContent");
    if (tagsEditContent) then
        tagsEditContent:DoAssign();
        local cmdO = CmdObj();
        local fakeCollect = cmdO.TagFakeCollect;
        fakeCollect:Changed();
    end
end

signalTable.SetFilterTarget = function(caller)
    local tagsEditContent = caller:FindParent("TagsEditContent");
    tagsEditContent:WaitInit(1)
    local fakeCollect = CmdObj().TagFakeCollect;
    if fakeCollect then
        local editTarget = fakeCollect.Target
        if editTarget then
            HookObjectChange(signalTable.UpdateFilter,editTarget,my_handle:Parent(),caller);
            signalTable.UpdateFilter(editTarget,my_handle:Parent(),caller)
        end
    end
end

signalTable.UpdateFilter = function(editTarget, dummy, grid)
    if (grid and grid.Internals) then
        grid.Internals.GridBase.GridSettings.UnassignedTagGridFilter.Target = editTarget
        grid.Internals.GridBase.GridSettings:Changed()
    end
end

signalTable.SortByIndex = function( caller,status,creator )
    caller.SortByColumn("Asc", 1)
end