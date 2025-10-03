local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function string_starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function string_ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local function PopupFeatures(caller, title, featureGroup, x, y)
	local resultValue = nil;
	local featureGroups = featureGroup:Parent();
	local fObj = StrToHandle(caller.Value);
	local currentValue = ""
	if fObj ~= nil then currentValue = fObj:AddrNative(featureGroups); end
	local itemList = {};
	local type = "str";
	for _,feature in ipairs(featureGroup:Children()) do
		local featureName = feature.Name;
		local featureAddr = feature:AddrNative(featureGroups);
		local stringItem = {type, featureName, featureAddr};
		itemList[#itemList + 1] = stringItem;
		--if (string_ends(currentValue, featureName)) then
		--	currentValue = featureName;
		--end
	end
	local selIndex;
	selIndex, resultValue = PopupInput({title=title, caller=caller, items=itemList, selectedValue=currentValue, x=x, y=y});
	return resultValue;
end

local function SelectFeature(caller, arg, x, y)
	local resFeatureName = nil;
	local Patch = Patch();
	if (Patch) then
		local featureGroups = Patch.AttributeDefinitions.FeatureGroups;
		if (featureGroups) then
			local featureGroup = featureGroups:Ptr(arg);
			if (featureGroup) then
				--here we create a new popup
				resFeatureName = PopupFeatures(caller, "feature("..featureGroup.Name..")", featureGroup, x, y);
				if (resFeatureName == nil) then
					return;
				end
			end
		else
			Echo("No feature groups found");
		end
		return caller, resFeatureName;
	end
end

signalTable.OnLoaded = function(caller,status,creator)
	local Patch = Patch();
	if (Patch) then
		local featureGroups = Patch.AttributeDefinitions.FeatureGroups;
		local fObj = StrToHandle(caller.Value);
		local fgrObj = nil;
		if (fObj) then fgrObj = fObj:Parent(); end;
		local currentValue = caller.Value;
		local searchCurrent = false;
		if (fObj) then searchCurrent = true; end

		local index = 1;
		local selectIndex = nil;
		if (featureGroups) then
			for _,featureGroup in ipairs(featureGroups:Children()) do
				if (featureGroup:Count() > 1) then
					local name = featureGroup.Name.." >>>";
					caller:AddListLuaItem(name, "SelectFeature", SelectFeature, featureGroup:Index());
					if (searchCurrent and (fgrObj == featureGroup)) then
						searchCurrent = false;
						selectIndex = index;
					end
				else 
					if(featureGroup:Count() > 0) then
						local feature = featureGroup:Ptr(1);
						local featureName = feature.Name;
						local featureAddr = feature:AddrNative(featureGroups);
						caller:AddListStringItem(featureName, featureAddr);
						if (searchCurrent and (fObj == feature)) then
							searchCurrent = false;
							selectIndex = index;
						end
					end
				end
				index = index + 1;
			end
		end
		if (selectIndex ~= nil) then
			caller:SelectListItemByIndex(selectIndex);
		end
	end
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
end
