local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function CreateNewDeactivationGroup(caller)
	local resDeactivationGroupName =nil;
	local Patch=Patch();
	if(Patch) then
		local DeactivationGroups = Patch.AttributeDefinitions.DeactivationGroups;
		if (DeactivationGroups) then
			--we try to open an editor to change the name of the activation group right away, in place
			local newDeactivationGroupName = TextInput("a new deactivation group name");
			if (newDeactivationGroupName) then
				local group = DeactivationGroups:Insert();
				if (group) then
					if (newDeactivationGroupName ~= "") then
						group.Name = newDeactivationGroupName;
					end
					resDeactivationGroupName = group.Name;
				end
			else
				--it was canceled
				return;
			end
		end
	end
	return caller, resDeactivationGroupName;
end

signalTable.OnLoaded = function(caller,status,creator)
	local Patch=Patch();
	if(Patch) then
		local DeactivationGroups = Patch.AttributeDefinitions.DeactivationGroups;
		if (DeactivationGroups) then
			Echo("DeactivationGroupPopupLoaded");
			caller:AddListLuaItem("New Deactivation Group", "CreateNewDeactivationGroup", CreateNewDeactivationGroup);
			caller:AddListStringItem("No Group", "");
			caller:AddListChildren(DeactivationGroups);
		end
	end
	caller:SelectListItemByValue(caller.Value);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
