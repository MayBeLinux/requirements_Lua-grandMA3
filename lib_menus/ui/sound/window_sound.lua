local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnWindowLoaded = function(Window,status,creator)
	local Settings=Window.WindowSettings;
	Window.Title.TitleButtons.ActiveDisplay.Target = Settings;

	HookObjectChange(signalTable.SoundSettingsChanged,  -- 1. function to call
					 Settings,			            	-- 2. object to hook
					 my_handle:Parent(),				-- 3. plugin object ( internally needed )
					 Window);							-- 4. user callback parameter 	

	signalTable.SoundSettingsChanged(Settings,nil,Window);

	local hostType = HostType();
	if ((hostType ~= "onPC")) then
	    Window.Title.TitleButtons.OnPCAudioInDeviceNameBtn.Visible = "No";				
	end
	Timer(signalTable.CheckBPMSoundMaster, 1, nil, nil, Window)
end

signalTable.SoundSettingsChanged = function(Settings,signal,Window)
	local ActiveDisplay=Settings.ActiveDisplay;
	local Frame=Window.Frame;
	Frame.Wave.Visible  =(ActiveDisplay=="Wave");
	Frame.Sound.Visible =(ActiveDisplay=="Sound");
	Frame.Beat.Visible  =(ActiveDisplay=="Beat");
	-- Frame.Chroma.Visible=(ActiveDisplay=="Chroma");
end

signalTable.CheckBPMSoundMaster = function(t, counter,Window)
	if IsObjectValid(Window) then
		local Frame=Window.Frame;
		local bpmMaster = ShowData().Masters.Speed.BPM;
		local faderVal, fv = bpmMaster:GetFader({})
		Frame.Sound.BPMWarning.Visible=(faderVal <= 4) or fv.disabled;
	end
end
