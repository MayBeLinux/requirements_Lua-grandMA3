local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local SettingsObj;
local SetupMode;

local ToolConfig = {};
ToolConfig["Auto"]				= {"",					"A", "Auto"};
ToolConfig["Select"]			= {"Select",			"",  "Select"};
ToolConfig["Move"]				= {"PhaserMovePoint",	"",  "Move"};
ToolConfig["Resize"]			= {"PhaserSizing",		"",  "Resize"};
ToolConfig["ResizeFixedRatio"]	= {"ResizeFixed",		"",  "ResizeFixedRatio"};

-- ------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	window:WaitInit();
	SettingsObj = window.WindowSettings;

	HookObjectChange(signalTable.OnSettingsChanged,		-- 1. function to call
					 SettingsObj,						-- 2. object to hook
					 my_handle:Parent(),				-- 3. plugin object ( internally needed )
					 window);							-- 4. user callback parameter 	

	window.TitleBar.Title.Settings = SettingsObj;
	window.TitleBar.TitleButtons:SetChildren("Target",SettingsObj)
	local UserProfile=CurrentProfile();
	HookObjectChange(signalTable.OnUserProfileChanged,UserProfile,my_handle:Parent(),window);

	signalTable.OnSettingsChanged(SettingsObj, "", window);
end

-- ------------------------------------------
signalTable.SetTarget = function(caller)
	caller.Target=SettingsObj
end

-- ------------------------------------------
signalTable.ChangedMode = function(window, settings)
	if(SetupMode ~= settings.Setup) then
		SetupMode = settings.Setup;
		local canvas = window.Frame.MenuGrid.Center.Canvas;
		window:UpdateEncoderBar();
	end
end

-- ------------------------------------------
signalTable.OnSettingsChanged = function(settings, signal, window)
	local AutoLayout = window.TitleBar.TitleButtons;
	local ButtonTable = {AutoLayout.Fitter, AutoLayout.FitType};
	local ToolTips = {"Zoom to fit", ""};
	if (settings.Lock == "Yes") then		
		for _,btn in ipairs(ButtonTable) do
			btn.Enabled = "No";
			btn.ToolTip = "Position is locked";
		end
	else
		for ii,btn in ipairs(ButtonTable) do
			btn.Enabled =  "Yes";
			btn.ToolTip = ToolTips[ii];
		end
	end
	
	signalTable.ChangedMode(window, settings);
	signalTable.RenewLayoutHook(window, signal);
end

-- ------------------------------------------
signalTable.OnUserProfileChanged = function(UserProfile, signal, window)
	signalTable.RenewLayoutHook(window, signal);
end

-- ------------------------------------------
signalTable.RenewLayoutHook = function(window, signal)
	if (window ~= nil) then
		UnhookMultiple(signalTable.OnLayoutChanged, nil, window);
		HookObjectChange(signalTable.OnLayoutChanged,	window.Layout,	my_handle:Parent(), window);
		signalTable.OnLayoutChanged(window.Layout, signal, window);
	end
end

-- ------------------------------------------
signalTable.OnLayoutChanged = function(Layout, signal, window)
	if IsObjectValid(window) then
		local LockBtn = window.Frame.MenuGrid.lockBtn;
		local ModeBtn = window.TitleBar.TitleButtons.Setup;
		if(Layout.Lock == "Yes") then
			LockBtn.Visible = "Yes";
			LockBtn.ToolTip = "Layout " .. tostring(Layout.index) .. " is locked";
			ModeBtn.Enabled = "No"
			ModeBtn.ToolTip = "Layout " .. tostring(Layout.index) .. " is locked";
		else
			LockBtn.Visible = "No";
			ModeBtn.Enabled = "Yes"
			ModeBtn.ToolTip = "";
		end
	end
end

-- ------------------------------------------
signalTable.SelectAsGrid = function(caller)
	local window = caller:FindParent("LayoutView");
	local canvas = window.Frame.MenuGrid.Center.Canvas;
	canvas:SelectionToGrid();
end

signalTable.AlignSelected = function(caller)
	local window = caller:FindParent("LayoutView");
	local canvas = window.Frame.MenuGrid.Center.Canvas;
	canvas:AlignSelected(); 
end