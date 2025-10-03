local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


local PortIndex
signalTable.WindowLoaded = function(caller,status,window)
	local cmdline=CmdObj();
	caller.Content.PropertyButtons.Universe.Target = caller
	caller.Content.PropertyButtons.Mode.Target = caller
	caller.Content.PropertyButtons.Merge.Target = caller
	caller.Content.PropertyButtons.Prio.Target = caller
	caller.Content.PropertyButtons.FailureMode.Target = caller
	local addArgs = caller.AdditionalArgs;
	if (addArgs and addArgs.Port) then 
	    PortIndex = string.sub(addArgs.Port, -1)
		caller.Content.PropertyButtons.Universe.Property = "XLR"..PortIndex
		caller.Content.PropertyButtons.Mode.Property = "Mode"..PortIndex
		caller.Content.PropertyButtons.Merge.Property = "Merge"..PortIndex
		caller.Content.PropertyButtons.Prio.Property = "Prio"..PortIndex
		caller.Content.PropertyButtons.FailureMode.Property = "FailureMode"..PortIndex
	end;

	HookObjectChange(signalTable.UpdateButtonVisibility,	caller,	my_handle:Parent(), caller);
	signalTable.UpdateButtonVisibility(caller, nil, caller)
end

signalTable.ApplyInterfaceChanges = function(caller)
    caller:GetOverlay().close();
end

signalTable.UpdateButtonVisibility = function(caller, signal, overlay)
	if (overlay.Content) then
		local showButton = true
		if (caller[overlay.Content.PropertyButtons.Universe.Property] == "") then
			showButton = false
		end
		overlay.Content.PropertyButtons.Mode.Visible = showButton
		overlay.Content.PropertyButtons.FailureMode.Visible = (caller[overlay.Content.PropertyButtons.Mode.Property] & 1 )

		if (caller[overlay.Content.PropertyButtons.Mode.Property] ~= 2) then
			showButton = false
		end
		overlay.Content.PropertyButtons.Merge.Visible = showButton
		if(caller[overlay.Content.PropertyButtons.Merge.Property] ~= 1)  then
			showButton = false
		end
		overlay.Content.PropertyButtons.Prio.Visible = showButton
		if (caller[overlay.Content.PropertyButtons.Prio.Property] ~= 255) then
			overlay.Content.PropertyButtons.Prio.ShowValue = true
			overlay.Content.PropertyButtons.Prio.ShowLabel = true
		else
			overlay.Content.PropertyButtons.Prio.ShowValue = false
			overlay.Content.PropertyButtons.Prio.ShowLabel = false
		end
	end
end