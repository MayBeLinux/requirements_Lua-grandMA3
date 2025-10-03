local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,dummy,target)
	local target = caller.context;
	local Frame=caller.Frame;
	-- Titlebutton:
	if (target and target.name) then
		caller.TitleBar.TitleButton.Text = string.format("Edit Repeat of %s '%s'",target:ToAddr(),target.name);
	end

	-- Tab 1:
	-- TimeSetting:
	Frame.Schedule.TimeSetting.StartDate.Target = target;
	Frame.Schedule.TimeSetting.StartTime.Target = target;
	Frame.Schedule.TimeSetting.EndDate.Target = target;
	-- Day, Week, Month, Year:
	Frame.Schedule.DayRepeat.DayButtons:SetChildren("Target",target);
	Frame.Schedule.WeekRepeat.WeekButtons:SetChildren("Target",target);
	Frame.Schedule.MonthRepeat.MonthButtons:SetChildren("Target",target);

	-- Tab 2:
	Frame.Iterations.MinuteRepeat.MinuteRepeatControl.Target = target;
	Frame.Iterations.MinuteRepeat.StartTime.Target = target;
	Frame.Iterations.MinuteRepeat.EndTime.Target = target;
	Frame.Iterations.DayRepeat.DayRepeatControl.Target = target;
	Frame.Iterations.WeekRepeat.WeekRepeatControl.Target = target;
	Frame.Iterations.MonthRepeat.MonthRepeatControl.Target = target;
	Frame.Iterations.YearRepeat.YearRepeatControl.Target = target;

	-- Result:
	Frame.RepeatCount.RepeatCountDays.Target = target;
	Frame.RepeatCount.RepeatCountTotal.Target = target;
end

signalTable.OnTabChanged = function(caller,nextVisible)
	local overlay = caller:GetOverlay();
	local Frame=overlay.Frame;
	local tabCount = caller:GetListItemsCount();

	for i=1, tabCount do
		local name = caller:GetListItemValueStr(i); -- e.g. Tab Value
		local obj = Frame:FindRecursive(name,"UILayoutGrid");
		if name == nextVisible then
			obj.visible = true;
		else
			obj.visible = false;
		end
	end
end

signalTable.ResetEnddate = function(caller)
	local overlay = caller:GetOverlay();
	local target = overlay.context;
	target:ResetEnddate();
end

signalTable.ClearPattern = function(caller)
	local overlay = caller:GetOverlay();
	local target = overlay.context;
	target:ResetPattern();
end