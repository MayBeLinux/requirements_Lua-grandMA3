local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnDataPoolSelected = function(caller,status,col_id,row_id)
    local dataPool=IntToHandle(row_id);
	local ov = caller:GetOverlay();

	local obj = dataPool;
	local targetPoolOffset = ov.AdditionalArgs.TargetPoolOffset;
	--'.'-separated offset list. e.g. 2.3
	for i,v in ipairs(targetPoolOffset:split(".")) do
		local n = tonumber(v);
		obj = obj:Ptr(n);
		if (obj == nil) then break; end;
	end

	caller:Parent().ObjectSelector.TargetObject = obj;
end

