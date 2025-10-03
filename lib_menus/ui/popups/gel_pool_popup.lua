local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
	local showData = ShowData();
	if (showData) then
	    caller:SetContextSensHelpLink("operate_gel_pool.html");
		local gelPools = showData.GelPools;
		if (gelPools) then
            for _,gelPool in ipairs(gelPools:Children()) do
                local gelPoolName = gelPool.Name;
                local gelPoolManufacturer = gelPool.Manufacturer;
                if(gelPoolManufacturer ~= '') then
                    caller:AddListStringItem(gelPoolManufacturer, gelPoolName);
                else
                    caller:AddListStringItem(gelPoolName, gelPoolName);
                end
			end
		end
		caller:SelectListItemByValue(caller.Value);
		caller:Changed()
	end
end
