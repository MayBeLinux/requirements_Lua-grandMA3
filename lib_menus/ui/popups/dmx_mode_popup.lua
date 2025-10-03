local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function AddUsedModesFirst(listHandle, modesHandle)
	-- first, we add modes that are used
	for k,v in ipairs(modesHandle:Children()) do
		if v.Used > 0 then
			local name = v:Get("Name",Enums.Roles.DisplayShort)
			name = name .. " (Used: "..v.Used..")"
			listHandle:AddListObjectItem(v,name)
		end
	end
	-- second, we add modes that are not used yet
	for k,v in ipairs(modesHandle:Children()) do
		if v.Used == 0 then
			local name = v:Get("Name",Enums.Roles.DisplayShort)
			listHandle:AddListObjectItem(v,name)
		end
	end
end

signalTable.OnLoaded = function(caller,status,creator)
	local FixtureTypes=Patch().FixtureTypes;

	local ctx = caller.Context;
	local myfixturetype = nil;
	local val = caller.Value

	if IsObjectValid(ctx) then
		myfixturetype = ctx:FindParent("FixtureType");
		if ctx:IsClass("Fixture") then
			local dm = ctx.ModeDirect;
			if dm ~= nil then
				val = HandleToStr(dm)
				myfixturetype = dm:FindParent("FixtureType");
			end
		end
	end
	local empty = nil;
	if caller.AdditionalArgs ~= nil then empty = caller.AdditionalArgs.AddEmpty; end
	if (empty ~= nil) then
		caller:AddListStringItem(empty,"");
	end
	if myfixturetype ~= nil then
		AddUsedModesFirst(caller, myfixturetype.DmxModes)
	else
		-- first, we add modes that are used
		for i,fixture_type in ipairs(FixtureTypes:Children()) do
			for j,dmx_mode in ipairs(fixture_type.DmxModes :Children()) do
				if dmx_mode.Used > 0 then
					local usedText = " (Used: "..dmx_mode.Used..")"
					caller:AddListObjectItem(dmx_mode, Enums.Roles.DisplayShort, true, nil, nil, usedText);
				end
			end
		end
		-- second, we add modes that are not used yet
		for i,fixture_type in ipairs(FixtureTypes:Children()) do
			for j,dmx_mode in ipairs(fixture_type.DmxModes :Children()) do
				if dmx_mode.Used == 0 then
					caller:AddListObjectItem(dmx_mode, Enums.Roles.DisplayShort, true);
				end
			end
		end
	end

	caller:SelectListItemByValue(val);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...

	caller.TitleBar:Ptr(2):Ptr(2).Size="50" --actually visible
	caller.TitleBar.FilterCtrl.Target = caller.Frame.ItemFilterField;
	caller.TitleBar.FilterCtrl.Visible = true;

	caller.Frame.ItemFilterField.Visible = true;
	HookObjectChange(signalTable.FilterFieldChanged,caller.Frame.ItemFilterField,my_handle:Parent(),caller);
	signalTable.FilterFieldChanged(caller.Frame.ItemFilterField,my_handle:Parent(),caller)

end

