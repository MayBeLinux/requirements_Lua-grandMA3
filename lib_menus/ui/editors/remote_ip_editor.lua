local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local Station=nil;

signalTable.OnListLoad = function(caller,dummy,target)
    Station=caller.Context;
    caller.HelpTopic = "network_interface.html";
    if (Station ~= nil)
    then
        caller.Title.TitleButton.Text="Network Interfaces of " .. Station.Name
    else
        caller.Title.TitleButton.Text="My Network Interfaces"
        Root().Interfaces.UpdateInterfaces();
    end;
end

signalTable.ApplyInterfaceChanges = function(caller)

    if (Station ~= nil)
    then
        Echo("Apply for station " .. Station.Name);
    else
        Root().Interfaces.SetInterfaces();
    end;

	local o = caller:GetOverlay();
	o.Close();
end

signalTable.CancelChanges = function(caller)
	local o = caller:GetOverlay();
	o.CloseCancel();
end
