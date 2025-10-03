local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local Frame=caller.Frame; 
	local Left=Frame.Left;
	Global_CurrentImagePoolElementNo	=target.No
	Global_CurrentImagePoolName			=target:Parent().Name
	Left:SetChildren("Target",target);
	Left.File:SetChildren("Target",target);
	Left.NDI:SetChildren("Target",target);
	Frame.Preview.Appearance = target;

	HookObjectChange(signalTable.VideoChanged,  -- 1. function to call
						target,					-- 2. object to hook
						my_handle:Parent(),		-- 3. plugin object ( internally needed )
						Frame);					-- 4. user callback parameter 	

	signalTable.VideoChanged(target,nil,Frame);
end

signalTable.ImportVideo = function(caller,dummy,target)
	local imageImport = Root().Menus.ImageImport:CommandCall(caller, false)
	if (imageImport) then
		imageImport.Title.TitleButton.Text = "Select Video for Import"
	end
end

signalTable.VideoChanged = function(video,signal,Frame)
	if video then
	    local Left=Frame.Left;
		Left.File.Visible = (video.Source=="File");
		Left.NDI.Visible  = (video.Source=="NDI");
		Frame.MaxText.Visible = (Left.NDI.Visible and video.NDISource and video.NDISource.BadVideoFormat);
	end
end