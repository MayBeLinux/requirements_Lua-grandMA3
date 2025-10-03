local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function CreateNewActivationGroup(caller)
	local resActivationGroupName =nil;
	local Patch=Patch();
	if(Patch) then
		local activationGroups = Patch.AttributeDefinitions.ActivationGroups;
		if (activationGroups) then
			--we try to open an editor to change the name of the activation group right away, in place
			local newActivationGroupName = TextInput("a new activation group name");
			if (newActivationGroupName) then
				local group = activationGroups:Insert();
				if (group) then
					if (newActivationGroupName ~= "") then
						group.Name = newActivationGroupName;
					end
					resActivationGroupName = group.Name;
				end
			else
				--it was canceled
				return;
			end
		end
	end
	return caller, resActivationGroupName;
end

signalTable.OnLoaded = function(caller,status,creator)
	local Patch=Patch();
	if(Patch) then
		local activationGroups = Patch.AttributeDefinitions.ActivationGroups;
		if (activationGroups) then
			Echo("ActivationGroupPopupLoaded");
			caller:AddListLuaItem("New Activation Group", "CreateNewActivationGroup", CreateNewActivationGroup);
			caller:AddListStringItem("No Group", "");
			caller:AddListChildren(activationGroups);
		end
	end
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
