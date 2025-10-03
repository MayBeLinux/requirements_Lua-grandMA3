local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- ***************************************************************************************************
--
-- ***************************************************************************************************

signalTable.ResetToDefault = function(caller)
	local display_index=caller:GetDisplayIndex();
	local screen = CurrentScreenConfig().ScreenContents:Ptr(display_index);
	local scrUI = nil;
	local d = caller:GetDisplay();
	if (d.ScreenContainer.ScrollIndicatorBox and d.ScreenContainer.ScrollIndicatorBox.ScreenScroll and d.ScreenContainer.ScrollIndicatorBox.ScreenScroll.ScrollBox) then
		scrUI = d.ScreenContainer.ScrollIndicatorBox.ScreenScroll.ScrollBox.UiScreen;
	end

	if (scrUI ~= nil) then
		scrUI.ViewH = 0;
		scrUI.ViewW = 0;
	else
		ErrEcho("No UiScreen was found!");
	end
end


signalTable.AddViewBar = function(caller)
	local display_index=caller:GetDisplayIndex();
	local dispDefaultPositions=DefaultDisplayPositions();
	local default_display_position=dispDefaultPositions:Ptr(display_index);
	if(default_display_position) then
		default_display_position.Dimension = default_display_position.Dimension + 1;
		local frame = caller:Parent();
		if(frame) then
			frame.ViewBarLines.Text =  default_display_position.Dimension;
			if(default_display_position.Dimension >= 3) then
				default_display_position.ViewBarAddition = false;
				frame.ViewBarAddition.Target = default_display_position.ViewBarAddition;
			end
			default_display_position.ViewBarSubtraction = true;
			frame.ViewBarSubtraction.Target = default_display_position.ViewBarSubtraction;

		end
	end
end


signalTable.SubstractViewBar = function(caller)
	local display_index=caller:GetDisplayIndex();
	local dispDefaultPositions=DefaultDisplayPositions();
	local default_display_position=dispDefaultPositions:Ptr(display_index);
	if(default_display_position) then
		default_display_position.Dimension = default_display_position.Dimension - 1;
		local frame = caller:Parent();
		if(frame) then
			frame.ViewBarLines.Text =  default_display_position.Dimension;
			if(default_display_position.Dimension == 1) then
				default_display_position.ViewBarSubtraction = false;
				frame.ViewBarSubtraction.Target = default_display_position.ViewBarSubtraction;
			end
			default_display_position.ViewBarAddition = true;
			frame.ViewBarAddition.Target = default_display_position.ViewBarAddition;
		end
	end
end



signalTable.OnLoaded = function(caller,status,creator)

	local display_index=caller:GetDisplayIndex();
	local body=caller.Body;
	local screen = CurrentScreenConfig().ScreenContents:Ptr(display_index);
	local scrUI = nil;
	local d = caller:GetDisplay();
	if (d.ScreenContainer.ScrollIndicatorBox and d.ScreenContainer.ScrollIndicatorBox.ScreenScroll and d.ScreenContainer.ScrollIndicatorBox.ScreenScroll.ScrollBox) then
		scrUI = d.ScreenContainer.ScrollIndicatorBox.ScreenScroll.ScrollBox.UiScreen;
	end
	--body.StaticContainer.ScreenFrame.AllowExtScreen.Target=scrUI;
	body.StaticContainer.ScreenFrame.AppearanceSelector.Target=screen;
	body.StaticContainer.ScreenFrame.ScreenRequestedW.Target=scrUI;
	body.StaticContainer.ScreenFrame.ScreenRequestedH.Target=scrUI;
	body.StaticContainer.ScreenFrame.ScaleRatio.Target=d;

	caller.TitleBar.Title.Text = "Configure Display "..display_index

	local dispDefaultPositions=DefaultDisplayPositions();
	local default_display_position=dispDefaultPositions:Ptr(display_index);
	if(default_display_position) then
	    body.ShowHeadline.Target=default_display_position;
	    body.StaticContainer.ShowMainMenu.Target=default_display_position;
		body.StaticContainer.ViewBarFrame.TurnViewBar.Target=default_display_position;
		body.StaticContainer.ViewBarFrame.ShowScrollButton.Target = default_display_position;
		body.StaticContainer.ViewBarFrame.ShowViewBar.Target=default_display_position;
		body.StaticContainer.ViewBarFrame.ViewBarAddition.Target=default_display_position;
		body.StaticContainer.ViewBarFrame.ViewBarLines.Text = default_display_position.Dimension;
		body.StaticContainer.ViewBarFrame.ViewBarSubtraction.Target=default_display_position;
		--body.StaticContainer.ViewBarFrame.SwapViewBar.Target=default_display_position;
		body.StaticContainer.ScreenFrame.ShowFeedback.Target=default_display_position;
		body.ShowCmdline.Target=default_display_position;
		body.ShowEncoderBar.Target=default_display_position;
		if body.ShowCommandWingBar then
			body.ShowCommandWingBar.Target=default_display_position;
		end
	end

	if (display_index ~= 1) then
		body.ShowEncoderBar.Text = "Show Playback Bar";
		body.ShowEncoderBar.ToolTip = "Toggles the Playback Bar";
	end
end


signalTable.BodyLoaded = function(Body)
	local HeadLineBtn = Body.ShowHeadline
	if (HostType() == "onPC" and Pult().PultType ~= "Web") then
		HeadLineBtn.Visible= "Yes"
		HeadLineBtn.Margin = "0,0,0,-5"
	end
	
	local disp = Body:GetDisplay();
	if (disp ~= nil) then
		local dispIdx = disp:Index();
		if(dispIdx == 6) then
			Body.ShowEncoderBar.Visible = "No"
		end
	end
end
