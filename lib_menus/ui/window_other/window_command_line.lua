local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function OnSettingsChanged(obj, change, ctx)
	local Frame=ctx.Frame;
	Frame.Toolbar.DisplayCommandLine.Visible = obj.ShowCommandlineField;		
end


signalTable.CommandlineHistoryWindowLoaded = function(caller,status,creator)
	
    local settings = caller.WindowSettings;
		    
	if (settings) then
	    HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
		OnSettingsChanged(settings, nil, caller);
	end

end

