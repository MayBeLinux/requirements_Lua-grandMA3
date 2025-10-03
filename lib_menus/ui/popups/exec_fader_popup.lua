local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    caller:AddListStringItem("None","");
	local data_pool = DataPool();
	if(data_pool) then
	    local handles=data_pool.Handles;
		if (handles) then
			for i=0,handles:Count(),1 do
                local exec_handle=handles[i];
			    if(exec_handle and exec_handle.HasFader) then
					caller:AddListObjectItem(exec_handle);
				end
			end
		end
		caller:SelectListItemByValue(caller.Value);
		caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
	end
end
