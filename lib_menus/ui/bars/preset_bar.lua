local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local left_SideOfEncoderBarOptions = true;
local middle_OfEncoderBarOptions = true;
local right_SideOfEncoderBarOptions = true;

local VisibleTable=
{ 
    Absolute        ={ Link="EncoderLinkValues"; LayerPage="Values"; };
    Relative        ={ Link="EncoderLinkValues"; LayerPage="Values"; };
    Fade			={ Link="EncoderLinkTiming"; LayerPage="Values"; };
    Delay			={ Link="EncoderLinkTiming"; LayerPage="Values"; };

    Speed			={ Link="EncoderLinkPhaser"; LayerPage="Phaser"; };
    SpeedMaster  	={ Link="EncoderLinkPhaser"; LayerPage="Phaser"; };
    Phase			={ Link="EncoderLinkPhaser"; LayerPage="Phaser"; };
    Measure		    ={ Link="EncoderLinkPhaser"; LayerPage="Phaser"; };

    Accel			={ Link="EncoderLinkPhaser"; LayerPage="Steps"; };
    Decel			={ Link="EncoderLinkPhaser"; LayerPage="Steps"; };
    Transition      ={ Link="EncoderLinkPhaser"; LayerPage="Steps"; };
    Width			={ Link="EncoderLinkPhaser"; LayerPage="Steps"; };
};

signalTable.PresetBarLoaded = function(caller,status,creator)
    local optionsArea  = caller.Options;
    HookObjectChange(signalTable.UserProfileChanged, CurrentProfile(), my_handle:Parent(), optionsArea);
    local settings = signalTable.GetSettings(caller);
    if(settings) then
        HookObjectChange(signalTable.SelectContext, settings, my_handle:Parent(), caller);
    end
    signalTable.SelectContext(settings, status, caller);

    local window = caller:FindParent("Window");

	if (window) then
        settings = window.WindowSettings;
		if (settings) then

			HookObjectChange(signalTable.ShowLayerToolbar,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowLayerToolbar(settings, nil, caller);


            HookObjectChange(signalTable.ShowEncoderPageButton,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowEncoderPageButton(settings, nil, caller);

            
            HookObjectChange(signalTable.ShowStepButtons,  -- 1. function to call
			settings,							-- 2. object to hook
			my_handle:Parent(),				-- 3. plugin object ( internally needed )
			caller);							-- 4. user callback parameter 	
			signalTable.ShowStepButtons(settings, nil, caller);

		end
	end 
end

signalTable.ShowLayerToolbar = function(settings, dummy, caller)
	local showencoderbaroptions = settings.ShowLayerToolbar;
	local options = caller.Options;
    local linkblock = caller.Options.LinkBlock;
	
	if(showencoderbaroptions)	 then
		linkblock.LayerArea.Visible = true;
		linkblock.LinkArea.Visible = true;
        middle_OfEncoderBarOptions = true;
        
	else
		linkblock.LayerArea.Visible = false;
		linkblock.LinkArea.Visible = false;
        middle_OfEncoderBarOptions = false;
	end
    signalTable.VisibilityEncoderOptions(caller)
end

signalTable.ShowEncoderPageButton = function(settings, dummy, caller)
	local encoderpagebutton = settings.ShowEncoderPageSelector;
	local options = caller.Options
	
	if(encoderpagebutton)	 then
        options.PageSelector.Visible = true;
        left_SideOfEncoderBarOptions = true;
	else
        options.PageSelector.Visible = false;
		options.Visible = false;
        left_SideOfEncoderBarOptions = false;
        
	end
    signalTable.VisibilityEncoderOptions(caller)
end

signalTable.ShowStepButtons = function(settings, dummy, caller)
	local showstepbuttons = settings.ShowStepButtons;
	local stepcontrol = caller.Options.LinkBlock.StepControl;
	
	if(showstepbuttons)	 then
		stepcontrol.Visible = true;
        right_SideOfEncoderBarOptions = true;
	else
		stepcontrol.Visible = false;
        right_SideOfEncoderBarOptions = false;
        
	end
    signalTable.VisibilityEncoderOptions(caller)
end

signalTable.VisibilityEncoderOptions = function(caller)
	local options = caller.Options;

	if not (left_SideOfEncoderBarOptions or middle_OfEncoderBarOptions or right_SideOfEncoderBarOptions) then
		options.Visible = false;
	else
		options.Visible = true;
	end
end




signalTable.OptionsLoaded = function(caller,status,creator)
    local up =CurrentProfile();
    HookObjectChange(signalTable.UserProfileChanged,up,my_handle:Parent(),caller);
    signalTable.UserProfileChanged(up,"",caller);
    HookObjectChange(signalTable.ShowDataChanged, Root().ShowData, my_handle:Parent(), caller);

    local cmd = CmdObj();
    HookObjectChange(signalTable.ShowDataChanged,cmd,my_handle:Parent(),caller);
end

signalTable.ShowDataChanged = function(upCollect, signal, caller)
    local up =CurrentProfile();
    if(caller) then
        if(caller:WaitInit()) then
            UnhookMultiple(signalTable.UserProfileChanged, nil, caller);
            HookObjectChange(signalTable.UserProfileChanged,up,my_handle:Parent(),caller);
            signalTable.UserProfileChanged(up,"",caller);
        end
    end
end

signalTable.SelectContext = function(settings, status, presetBar)
    if(settings) then    
        presetBar.Context = "Window";
        presetBar.FadeEncoder = settings.FadeEncoder;
     elseif(presetBar:GetOverlay()) then 
        presetBar.Context = "Overlay";
     end
     presetBar:Changed();
end

signalTable.GetSettings = function(caller)
    local settings = nil;    
    local window = caller:FindParent("Window");
    if(window) then
        settings = window.WindowSettings;
    end
    return settings;
end

signalTable.UserProfileChanged = function(up,signal,optionsArea)
    if(up and optionsArea) then
        local layer  =up.ProgrammingLayer;
        local visible=VisibleTable[layer];
        local lb=optionsArea.LinkBlock;
        if(lb) then
            lb.LinkArea.EncoderLinkValues.Visible=false;
            lb.LinkArea.EncoderLinkTiming.Visible=false;
            lb.LinkArea.EncoderLinkPhaser.Visible=false;
            lb.LinkArea.EncoderAtFilter.Visible  =false;
            if(visible and visible.Link) then
                lb.LinkArea[visible.Link].Visible=true;
            else
                lb.LinkArea.EncoderAtFilter.Visible =true;
            end

            if visible then
                lb.LayerArea.LayerPages.ActiveChild=visible.LayerPage;
            end

            local valueLayer = up.LastValueLayer;
            lb.LayerArea.ValueArea.ValueButton.ColorIndicator = "ProgLayer." .. valueLayer

            local phaserLayer = up.LastPhaserLayer;
            lb.LayerArea.ValueArea.PhaserButton.ColorIndicator = "ProgLayer." .. phaserLayer

            local stepLayer = up.LastStepLayer;
            lb.LayerArea.ValueArea.StepButton.ColorIndicator = "ProgLayer." .. stepLayer
        end
    end
end

signalTable.SetChildValues = function(caller,signal,creator)
    for i,child in ipairs(caller) do
        if (Enums.ProgLayer[child.Name]) then
            child.ColorIndicator = "ProgLayer." .. child.Name;
            child.Text			 = child.Name;
            child.Value			 = child.Name;
        end
    end
end

local function trimStr(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

signalTable.OnClickedLayer = function(caller,signal,creator)
    local cmdlineText = trimStr(CmdObj().CmdText):lower();
    if (cmdlineText and 
        (
            cmdlineText == "off" 
            or cmdlineText == "on"
            or cmdlineText == "extract"
            or (cmdlineText == "at" and caller.name == "GridPos")
        )) then
        Cmd(''..cmdlineText..' '..caller.name..'');
        CmdObj().ClearCmd();
    else
        Cmd('Set ' ..CurrentProfile():ToAddr().. ' "'..caller.Property..'" "'..caller.value..'"');
    end
end

signalTable.OnLinkEncoderResolutionChanged = function(caller,signal,creator)
    caller:Parent():Parent():Parent():Changed() -- Reinit PreseBar
end
