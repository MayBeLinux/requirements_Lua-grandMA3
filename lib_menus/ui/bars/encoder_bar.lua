local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(BarObj)
	--during the initial startup it's possible that this component will get re-loaded and at this point BarObj might be already invalid
	if IsObjectValid(BarObj) then
		local CurrentDisplay = BarObj:GetDisplay()
		local isConsole = HostType() == "Console";
		local TargetDisplayIndex;
		local subType = HostSubType();
		local isCompact = subType == "Compact" or subType == "CompactXT";


		local DisplayIndex = CurrentDisplay:Index()
		local DefaultDisplayPosition=DefaultDisplayPositions():Ptr(DisplayIndex);
		local showEncoderBar = true;
		if (DefaultDisplayPosition) then showEncoderBar = DefaultDisplayPosition.ShowEncoderBar; end;

		if (CurrentDisplay.EncoderBarContainer.Visible ~= showEncoderBar) then
			CurrentDisplay.EncoderBarContainer.Visible = showEncoderBar;
		end

		if (isConsole and (DisplayIndex == 1)) then--these changes make sense only for the 1st display to adjust the position of UI elements to the hardware encoders
			if (isCompact) then
				local columns = BarObj:Ptr(2);
				columns:Ptr(1).Size = "245";
				columns:Ptr(columns:Count()).Size = "70";
			end
		end
		if (isConsole and (DisplayIndex == 8)) then--these changes make sense only for the left letterbox screen on consoles
		    local btn = BarObj:FindRecursive("SelectionButton","SelectionIndicatorButton");
			if (btn) then
		        btn.Padding = "0,0,0,0";
			end
			btn = BarObj:FindRecursive("MatricksText","PropertyControl");
			if (btn) then
			    btn.Margin = "0,0,0,0";
				btn.Padding = "0,6,0,0";
			end
		end
	end
end

signalTable.SpecialGrandMasterLoaded = function(caller)
	HookObjectChange(signalTable.ShowDataChanged,  Root().ShowData, my_handle:Parent(), caller);
	signalTable.ShowDataChanged(nil, nil, caller);
end

signalTable.ShowDataChanged = function(dummy1, dummy2, caller)
	UnhookMultiple(signalTable.ShowSpecialGrandMaster, nil, caller);

	UnhookMultiple(signalTable.OnMAtrickschange, nil, caller:Parent().MatricksMenu.MatricksText);
	signalTable.MatricksLoaded(caller:Parent().MatricksMenu.MatricksText);
	
	local grandKnob = CurrentProfile().SpecialExecutorPages[1][Enums.SpecialExecutor.GrandKnob+1];
	HookObjectChange(signalTable.ShowSpecialGrandMaster,  	-- 1. function to call
					grandKnob,								-- 2. object to hook
					my_handle:Parent(),						-- 3. plugin object ( internally needed )
					caller);								-- 4. user callback parameter 	

	signalTable.ShowSpecialGrandMaster(grandKnob, nil, caller);
end

signalTable.ShowSpecialGrandMaster = function(grandKnob, dummy, caller)
	if(caller:WaitInit()) then
		local grandFader = caller:Parent().MasterFader;
		if(grandKnob ~= nil) then
			if(grandKnob.Object ~= Root().ShowData.Masters.Grand.Master) then
				caller.Visible="Yes";
				grandFader.Anchors="7,0,7,2";
			else
				caller.Visible="No";
				grandFader.Anchors="7,0,7,3";
			end
		end
	end
end

signalTable.MatricksLoaded= function(caller)
	signalTable.OnMAtrickschange(nil, nil, caller)
	HookObjectChange(signalTable.OnMAtrickschange,  Selection(), my_handle:Parent(), caller);
end

signalTable.OnMAtrickschange = function(MAtricks, dummy2, caller)

    caller.Target = Selection();
	if(caller.Target ~= nil and caller.Target.InitialMatricks ~= nil) then
		caller.ShowLabel = "Yes";
		caller.Margin="0,5,5,0";
	else
		caller.ShowLabel = "No";
		caller.Margin="0,0,5,2";
	end

	if(caller.Target.Active) then
		caller.ValueTextColor="Global.Selected";
		caller.TextColor="Global.Selected";
	else
		caller.ValueTextColor="Global.Text";
		caller.TextColor="Global.Text";
	end

end
