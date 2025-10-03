local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local layer_values= { "EncoderLinkValues" , "Link Values" , false, false };
local layer_timing= { "EncoderLinkTiming" , "Link Timing" , true, true };
local layer_effect= { "EncoderLinkPhaser" , "Link Phaser" , true, true };


local layer_table=
{
    ["Absolute"]=layer_values;
    ["Relative"]=layer_values;
    ["Fade"    ]=layer_timing;
    ["Delay"   ]=layer_timing;
};

signalTable.SetLinkProperty = function(caller,status,creator)
    local overlay = caller:GetOverlay();
    local profile = CurrentProfile();
    local l = layer_table[profile.ProgrammingLayer] or layer_effect;
    caller.Property             = l[1];
    overlay.TitleBar.Title.Text = l[2];
    local f=overlay.Frame.Filters;
    f.ActiveOnly.visible    = l[3];
    f.MultistepOnly.visible = l[4];
end

signalTable.AdjustSizes = function(caller)

    local filters = caller.Frame.Filters
    local profile = CurrentProfile();
    local l = layer_table[profile.ProgrammingLayer] or layer_effect;
        if(l[3] == false and l[4] == false) then
        caller.H=190;
        caller.W=230;
        filters.W = 0;
        filters.Margin="0,0,0,0"
    else
        caller.H=240;
        caller.W=410;
        filters.W = 140;
        filters.Margin="20,20,20,20"
    end
end