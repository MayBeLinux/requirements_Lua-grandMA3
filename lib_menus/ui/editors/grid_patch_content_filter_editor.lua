local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GridPatchFilterLoaded = function(caller,status,creator)
	local up = CurrentProfile();
	local p = up.GridContentFilterSettings.FilterDialogPosition; 
	local r = caller.AbsRect;
	if ((p.x ~= -1) and (p.y ~= -1)) then 
		r.x = p.x;
		r.y = p.y;
	else
		r.x = -1;
		r.y = -1;
	end

	local d = up.GridContentFilterSettings.FilterDialogSize;
	if (d.w ~= -1 and d.h ~= -1) then
		r.w = d.w;
		r.h = d.h;
	else
		r.w = -1;
		r.h = -1;
	end

	caller.AbsRect = r;
end

signalTable.Move = function(caller,dummy,dX, dY)
	local o = caller:GetOverlay();
	local up = CurrentProfile();
	local r = o.AbsRect;
	up.GridContentFilterSettings.FilterDialogPosition = {x = r.x, y = r.y};
end

signalTable.ResizeEnd = function(caller,dummy)
	local o = caller:GetOverlay();
	local up = CurrentProfile();
	local r = o.AbsRect;
	up.GridContentFilterSettings.FilterDialogSize = {w = r.w, h = r.h};
end

