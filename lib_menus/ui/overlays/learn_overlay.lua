local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)    
    local show_settings=ShowSettings();
    if(show_settings) then
        HookObjectChange(signalTable.OnPlaybackSettingsChanged, show_settings.DefaultPlaybackSettings, my_handle:Parent(), caller);
        signalTable.OnPlaybackSettingsChanged(show_settings.DefaultPlaybackSettings, nil, caller);
    end
end

signalTable.OnPlaybackSettingsChanged = function(playbackSettings,dummy,overlay)    
    local circleWidth = 60;
    local frameThickness=5;
    local buttonOffset = 8;
        
    local nBeats = playbackSettings.BeatsPerMeasure;
    local frame = overlay.Frame;
        
    local width = (circleWidth+frame.DefaultMargin) * nBeats + buttonOffset + 2 * frameThickness;
    frame.W= width;
    overlay.W = width;
    overlay.BackFiller.W = width-3;

    local n = frame:GetUIChildrenCount();
    for ii = 1,n do
        if(ii <= nBeats) then
            frame:GetUIChild(ii).W=circleWidth;
            frame:GetUIChild(ii).Visible=true;
        else
            frame:GetUIChild(ii).W=0;
            frame:GetUIChild(ii).Visible=false;
        end
    end
end