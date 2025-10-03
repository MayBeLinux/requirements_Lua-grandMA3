local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)
    local settings = CurrentProfile().TemporaryWindowSettings.SelectionViewSettings;
    local buttons=caller.Title.TitleButtons;
    buttons.GridLines.Target = settings;
    buttons.CenterlineX.Target = settings;
    buttons.CenterlineY.Target = settings;
    buttons.AutoScroll.Target = settings;
    buttons.ShowMAtricksTransformation.Target = settings;
end

