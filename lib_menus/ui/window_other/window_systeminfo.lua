local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

local function OnPatchChanged(obj, change, ctx)
	local uiChCnt = ctx.DialogFrame.SysDetailsView.UICount.UICountCtrl;
	uiChCnt.Target = "ShowData.LivePatch";
end

-- ------------------------------------------
signalTable.WindowLoaded = function(window,status,creator)
	local settings = window.WindowSettings;
	window.TitleBar.DispView.Target = settings;
	signalTable.SelectView(settings,nil,window);
	HookObjectChange(signalTable.SelectView,    -- 1. function to call
					 settings,					-- 2. object to hook
					 my_handle:Parent(),		-- 3. plugin object ( internally needed )
					 window);                   -- 4. user callback parameter

	HookObjectChange(OnPatchChanged,        -- 1. function to call
					 ShowData().LivePatch,	-- 2. object to hook
					 my_handle:Parent(),    -- 3. plugin object ( internally needed )
					 window);               -- 4. user callback parameter

	HookObjectChange(OnPatchChanged,        -- 1. function to call
					 ShowData().Patch,	-- 2. object to hook
					 my_handle:Parent(),    -- 3. plugin object ( internally needed )
					 window);               -- 4. user callback parameter
end

signalTable.GetSysDetails = function(caller)
	local lPatch = Patch()
	local lManetSocket = Root().ManetSocket
	local build_details = BuildDetails()
	
	local OverallCertificate = OverallDeviceCertificate();
	caller.HostOsValue.Text = HostOS();
	caller.VersionValue.Text = Version();
	caller.ReleaseTypeValue.Text = "Software: " .. ReleaseType();

	caller.CodeTypeValue.Text = "Code: " .. build_details["CodeType"]
	caller.BuildDateValue.Text = build_details["CompileDate"]
	caller.BuildTimeValue.Text = build_details["CompileTime"]
	caller.GitHashValue.Text = build_details["GitHash"]
	caller.GitDateValue.Text = build_details["GitDate"]
end
-- ------------------------------------------
signalTable.SelectView = function(settings,signal,window)
	local View = settings.DispView;
	local frame= window.DialogFrame;
	frame.PerformanceView.Visible	= (View == "Realtime" or View == "Timing");
	frame.CPUTestView.Visible		= (View == "CPU");
	frame.MemTestView.Visible		= (View == "Memory");
	frame.CpuTempView.Visible		= (View == "CPU Temp");
	frame.GpuTempView.Visible		= (View == "GPU Temp");
	frame.SysTempView.Visible		= (View == "Sys Temp");
	frame.FanRpmView.Visible		= (View == "Fan");
	frame.HddView.Visible	        = (View == "HDD");
	frame.SysDetailsView.Visible	= (View == "Details");
	frame.Network.Visible	= (View == "Network");
end

