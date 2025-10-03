local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function OnSettingsChanged(settings, dummy, overlay)
    overlay.Frame.ToolBar.visible = settings.Toolbar
    overlay.Frame.AlignBar.visible = settings.Alignbar
end

signalTable.OnLoad = function(caller,status,creator)
    local settings = caller.WindowSettings
    local buttons  = caller.Title.TitleButtons;

    buttons.GridLines.Target = settings;
    buttons.CenterlineX.Target = settings;
    buttons.CenterlineY.Target = settings;
    buttons.AutoScroll.Target = settings;
    buttons.ShowToolbar.Target = settings;
    buttons.ShowAlignbar.Target = settings;
    buttons.ShowMAtricksTransformation.Target = settings;

    HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
    OnSettingsChanged(settings, nil, caller);
end
