local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local firstAttributeRule = nil;

signalTable.OnLoaded = function(caller,status,creator)
	signalTable.AtFilterSettings = CurrentProfile().TemporaryWindowSettings.AtFilterSettings;
end


signalTable.SetButtonHeigtTarget = function(caller)
	caller.Target  = signalTable.AtFilterSettings;
end

signalTable.ChangeLineHeight = function(caller)
	local Overlay = caller:GetOverlay();
	local InnerGrid = Overlay.Frame.AtFilterGrid.AtFilter.Box.InnerGrid;
	local Height;
	if(signalTable.AtFilterSettings.LineHeight == "Default") then
		Height = "50";
	else
		Height = signalTable.AtFilterSettings.LineHeight;
	end
	
	InnerGrid.TitleGrid.H = Height;

	if(Height < "40") then
		InnerGrid.TitleGrid.DefaultMargin = 4;
	else
		InnerGrid.TitleGrid.DefaultMargin = 8;
	end
end


signalTable.FindFirstAttributeRule = function(overlay)
	for key,value in ipairs(overlay.EditTarget["FilterRuleCollect"]) do
		local ruleset = overlay.EditTarget["FilterRuleCollect"][key];
		for ruleKey,ruleV in ipairs(ruleset) do
			local rule = ruleset[ruleKey]
			if rule.Name == "Attributes" then
				return rule;
			end
		end
		

	end
end

signalTable.TargetChanged = function(FilterObj, dummy, overlay)
	if overlay and FilterObj and IsObjectValid(FilterObj) then
		 local addInfo = FilterObj:Get("Name",Enums.Roles.Display);
		 if addInfo and addInfo ~= "" then
			 overlay.TitleBar.Title.Text = string.format("Edit %s",addInfo);
		 end
		 local newRule = signalTable.FindFirstAttributeRule(overlay);
		 if(firstAttributeRule ~= newRule) then
			overlay.Frame.AtFilterGrid.AtFilter.Box.InnerGrid.AtDialog:Changed();
			firstAttributeRule = newRule;
		 end
		 
		--local target = overlay.Frame.AtFilterGrid.AtFilter.Box.InnerGrid.AtDialog.TargetObject;
		--if(target) then
		--	if(target ~= FilterObj) then
		--		overlay.Frame.AtFilterGrid.FilterTitle.Text =  "Attributes Filter Rule: " .. tostring(target:Parent():Index()) .. "." .. tostring(target:Index()) -- target:ToAddr()-- overlay.Frame.AtFilterGrid.AtFilter.Box.InnerGrid.AtDialog.TargetObject.Name
		--	else
		--		overlay.Frame.AtFilterGrid.FilterTitle.Text = "Resulting Attribute Filter (" .. FilterObj.Name .. ")"
		--	end
		--end
	 end
 end

signalTable.OnSetEditTarget = function(caller,dummy,target)


	caller.Frame.FilterRuleGrid.FilterRules.FilterGrid:SetChildren("Target",target);
	caller.Frame.FilterRuleGrid.FilterRules.FilterRuleGrid.TargetObject = target:Ptr(1);

	caller.Frame.FilterRuleGrid.ObjectSettings:SetChildren("Target",target);

	HookObjectChange(signalTable.TargetChanged, -- 1. function to call
					 target,	               -- 2. object to hook
					 my_handle:Parent(),       -- 3. plugin object ( internally needed )
					 caller)                   -- 4. user callback parameter 

	signalTable.TargetChanged(target, nil, caller)
end

signalTable.OnListReference = function(caller)
	local editor = caller:FindParent("FilterEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.ReInitAtFilterGrid = function(caller)
	local overlay = caller:FindParent("FilterEditor");
	overlay.Frame.AtFilterGrid.AtFilter.Box:Changed()
end

signalTable.SetSettingsTarget = function(caller)
	caller.Target = CurrentProfile().TemporaryWindowSettings.AtFilterSettings;
end

signalTable.LoadFilterObjectSettings = function(caller)
	local settingsUI = signalTable.LoadObjectSettings(caller);
	settingsUI.UseMainPropertiesOnly = true;
end