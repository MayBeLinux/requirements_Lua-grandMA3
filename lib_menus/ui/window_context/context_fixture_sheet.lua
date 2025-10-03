local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnMaskLoaded = function(caller,status)
    signalTable.CustomNames = {}

    local Patch = Patch();
    if (Patch) then
        local idTypes = Patch.IDTypes;
        if(idTypes) then
            for i=1,idTypes:Count(),1 do
                if caller["Idtype"..i] then
                    caller["Idtype"..i].Text = idTypes:Ptr(i).Name;
                    signalTable.CustomNames["Idtype"..i] = idTypes:Ptr(i).Name;
                end
            end
        end;
    end;
end