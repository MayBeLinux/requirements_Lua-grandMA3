local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    -- Tags Edit Placeholder
    signalTable.RebuildPlaceholder(caller.Frame.TagsEditPlaceholder, "TagsEditContent");
    caller:Changed();

    local fakeCollect = CmdObj().TagFakeCollect;
    caller.Frame.TagsEditPlaceholder.TagsEditContent.Target = fakeCollect;
end