local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnMaskLoaded = function(caller,status,visible)
    signalTable.CustomNames = {}
    local Patch = Patch();
    if (Patch) then
        local idTypes = Patch.IDTypes;
        if(idTypes) then
            for i=1,idTypes:Count(),1 do
                if caller["IDType"..i] then
                    caller["IDType"..i].Text = idTypes:Ptr(i).Name;
                    signalTable.CustomNames["IDType"..i] = idTypes:Ptr(i).Name;
                end
            end
        end;
    end;
end

signalTable.SetFixtureSettingsTarget = function(caller,status,visible)
	local contextEditor = caller:GetOverlay();
	local target = contextEditor.EditTarget;
    if(target.ContentSheetSettings.FixtureSheetSettings ~= nil) then
        caller.Target = target.ContentSheetSettings.FixtureSheetSettings;
    end
end

signalTable.SetContentSheetSettingsTarget = function(caller,status,visible)
	local contextEditor = caller:GetOverlay();
	local target = contextEditor.EditTarget;
    caller.Target = target.ContentSheetSettings;      
end

