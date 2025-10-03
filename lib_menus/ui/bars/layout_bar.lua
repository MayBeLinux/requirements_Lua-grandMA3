local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local canvas;
local LayoutView;
signalTable.BarLoaded = function(Bar,status,window)
	if (window.name ~= "LayoutView") then return; end
	canvas  =window.Frame.MenuGrid.Center.Canvas;
	LayoutView = window;
	local SettingsObj = window.WindowSettings;

	if Bar["IsValid"] and Bar:IsValid() then
		HookObjectChange(signalTable.LayoutChanged,  -- 1. function to call
						SettingsObj,							-- 2. object to hook
						my_handle:Parent(),				-- 3. plugin object ( internally needed )
						Bar);							-- 4. user callback parameter 	

		local UserProfile=CurrentProfile();
		HookObjectChange(signalTable.LayoutChanged,UserProfile,my_handle:Parent(),Bar);

		local Lower = Bar.InnerBox.Lower;
		Lower:SetChildren("Target",canvas);
		signalTable.LayoutChanged("", "", Bar);
	end
end

signalTable.LayoutChanged = function(dummy,status,Bar)
	if Bar["IsValid"] and Bar:IsValid() then
		local Layout  = LayoutView.Layout;
		local Upper   = Bar.InnerBox.Upper;
		Upper:SetChildren("Target",Layout);
		Bar.InnerBox.EncoderFunction.Target = Layout;
	end
end

signalTable.LayoutTypeChanged = function(caller)
	canvas:OnSetRecalcCenterOfGravity();
end

signalTable.EditSelected = function(caller)	
	local Layout  = LayoutView.Layout;
	if(Layout.FirstSelectedIndex ~= "") then
		Layout.EditFromEncoderBar = true;
		CmdIndirect("edit " .. ToAddr(Layout) .. "." .. Layout.FirstSelectedIndex);
	end
end