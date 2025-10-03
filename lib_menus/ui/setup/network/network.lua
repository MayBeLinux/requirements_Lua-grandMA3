local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.StatusButtonLoaded = function(caller,status,creator)
	local obj=Root().ManetSocket;
	HookObjectChange(signalTable.ManetSocketChanged   , -- 1. function to call
					 obj  ,                             -- 2. object to hook
					 my_handle:Parent(),                -- 3. plugin object ( internally needed )
					 caller);                           -- 4. user callback parameter  

	signalTable.ManetSocketChanged(obj,nil,caller);
end

signalTable.ManetSocketChanged = function(obj,change, ctx)
	local ColorTheme =Root().ColorTheme.ColorGroups;
	local functional = obj.Functional;
	local color;
	if(functional) then color=ColorTheme.PropertyControl.Background;
	else  color=ColorTheme.Network.NetworkError; end

	if ctx then
		ctx.ActiveBackColor=color;
		ctx.BackColor      =color;
	end
end

signalTable.StationGridLoaded = function(caller)
	caller:WaitInit(2);
	local so = caller.GetSortOrder();
	if (so == Enums.GridSortOrder.None) then
		caller.SortByColumnName("IP", Enums.GridSortOrder.Asc);
	end
end

signalTable.InterfaceButtonLoaded = function(caller)
	local MAnetSocket = Root().MAnetSocket;
	HookObjectChange(signalTable.ManetSocketChanged2   , -- 1. function to call
	MAnetSocket  ,                     -- 2. object to hook
	my_handle:Parent(),                -- 3. plugin object ( internally needed )
	caller);                           -- 4. user callback parameter

	signalTable.ManetSocketChanged2(MAnetSocket,nil,caller);
end

signalTable.ManetSocketChanged2 = function(MAnetSocket,change, ctx)
	local ColorTheme = Root().ColorTheme.ColorGroups;
	local color_off=ColorTheme.Network.Standalone;
	local color_on=ColorTheme.Network.Connected;
	local color;

	local Interfaces = Root().Interfaces;
	local PrimaryInterface = MAnetSocket.Interface; --e.g. "1.1"
	-- Echo("PrimaryInterface = " .. PrimaryInterface);
	local Interface=Interfaces:Ptr(tonumber(PrimaryInterface:sub(1,1)));
	if (Interface and Interface.Link) then
		color=color_on;
	else
		color=color_off;
	end

	if(ctx) then
		ctx.IconColor=color
	end
end
