local signalTable   = select(3,...); 

local CurrentPreset     = nil;
local CurrentPresetPool = nil;

-- ************************************************************************************************************
--
-- ************************************************************************************************************
local function HasValidRecipeSources(caller, Recipe)
	local IsPresetOk = "IsPresetOk";
	if caller:InputHasFunction(IsPresetOk) ~= true then IsPresetOk = nil; end

	for Index,Preset in ipairs(Recipe:Parent():Children()) do
		if Preset and not Preset:IsEmpty() and ((IsPresetOk == nil) or (caller:InputCallFunction(IsPresetOk, Preset) == true)) then
			if Preset.OwnDataPresent and Preset ~= Recipe then
				return true
			end
		end
	end
	return false
end

local function SelectRecipe(caller, Recipe, x, y)
	local IsPresetOk = "IsPresetOk";
	if caller:InputHasFunction(IsPresetOk) ~= true then IsPresetOk = nil; end

	local itemList = {};
	for Index,Preset in ipairs(Recipe:Parent():Children()) do
		if Preset and not Preset:IsEmpty() and ((IsPresetOk == nil) or (caller:InputCallFunction(IsPresetOk, Preset) == true)) then
			if Preset.OwnDataPresent and Preset ~= Recipe then
				itemList[#itemList+1] = { 'handle' , Preset.Name , Preset };
			end
		end
	end
	local hintX = x;
	local hintY = y;
	local btn = caller:GetListItemButton(caller:GetListSelectedItemIndex());
	if btn ~= nil then
		local rct = btn.AbsRect;
		local callerRct = caller.AbsRect;
		local tbRct = caller.TitleBar.AbsRect;

		local offY = callerRct.y - tbRct.y;--accounting for shadow
		local offX = callerRct.x - tbRct.x;--accounting for shadow
		hintX = rct.x + rct.w + offX;
		hintY = rct.y + offY;
	end

	local selIndex,resultValue = PopupInput({title="Recipe", caller=caller, items=itemList, selectedValue=CurrentPreset, x=hintX, y=hintY, render_options={left_icon=true, number=true}, useLeftTop=true});
	if (selIndex == nil) then return; end;
	return caller,resultValue;
end

local function SelectPresetPool(caller, PresetPool, x, y)
	local withOwnData = nil;
	local addArgs = caller.AdditionalArgs;
	if addArgs.WithOwnDataOnly == "Yes" then
		withOwnData = true;
	end

	local IsPresetOk = "IsPresetOk";
	if caller:InputHasFunction(IsPresetOk) ~= true then IsPresetOk = nil; end

	local itemList = {};
	for Index,Preset in ipairs(PresetPool:Children()) do
		if Preset and not Preset:IsEmpty() and ((IsPresetOk == nil) or (caller:InputCallFunction(IsPresetOk, Preset) == true)) then
			if withOwnData ~= true or Preset.OwnDataPresent then
				itemList[#itemList+1] = { 'handle' , Preset.Name , Preset };
			end
		end
	end
	local hintX = x;
	local hintY = y;
	local btn = caller:GetListItemButton(caller:GetListSelectedItemIndex());
	if btn ~= nil then
		local rct = btn.AbsRect;
		local callerRct = caller.AbsRect;
		local tbRct = caller.TitleBar.AbsRect;

		local offY = callerRct.y - tbRct.y;--accounting for shadow
		local offX = callerRct.x - tbRct.x;--accounting for shadow
		hintX = rct.x + rct.w + offX;
		hintY = rct.y + offY;
	end

	local selIndex,resultValue = PopupInput({title="Preset", caller=caller, items=itemList, selectedValue=CurrentPreset, x=hintX, y=hintY, render_options={left_icon=true, number=true}, useLeftTop=true, add_args={FilterSupport="Yes", FilterDefaultVisible="Yes"}});
	if (selIndex == nil) then return; end;
	return caller,resultValue;
end

local function split_string(str, sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

local function AddExtraValues(caller)
	local addArgs = caller.AdditionalArgs;
	local extraN = tonumber(addArgs.ExtraValuesCount) or nil;
	if extraN ~= nil then
		for i=1,extraN,1 do
			local v = addArgs["ExtraValue"..i];
			local r = split_string(v, "|");
			if #r == 2 then
				caller:AddListStringItem(r[1], r[2]);
			end
		end
	end
end

-- ************************************************************************************************************
--
-- ************************************************************************************************************

signalTable.OnLoaded = function(caller,status,creator)
	caller:AddListStringItem("None","Empty")

	local selectIndex = signalTable.OnPresetPopupLoaded(caller, status, creator, 1);

	caller.TitleBar.Title.Text="Preset Pool";
	caller.Frame.Popup.ShowNumber=true;
	caller.Frame.Popup.ShowRightIcon=true;
	caller:SelectListItemByIndex(selectIndex);
	coroutine.yield({ui=1})
	caller:Changed();
end

signalTable.OnPresetPopupLoaded = function(caller,status,creator,offset)
	local presetpools = DataPool().PresetPools;
	if presetpools then
		-- local role        = Enums.Roles.DisplayShort;
		CurrentPreset     = StrToHandle(caller.Value);
		CurrentPresetPool = nil;
		if IsObjectValid(CurrentPreset) then CurrentPresetPool=CurrentPreset:Parent();	end
		local IsPresetPoolOk = "IsPresetPoolOk";
		if caller:InputHasFunction(IsPresetPoolOk) ~= true then IsPresetPoolOk = nil; end

		
		AddExtraValues(caller);

		local selectIndex = 0;
		local rightIcon = FindTexture("triangle_right");
		local rightApp = {image=rightIcon, mode=Enums.ImageBackGroundMode.Center};
		local count = offset;
		if HasValidRecipeSources(caller, caller.Context) == true then
			caller:AddListLuaItem("Recipes", "SelectRecipe", SelectRecipe, caller.Context, {right=rightApp});
		end
		for Index,PresetPool in ipairs(presetpools:Children()) do
			if not PresetPool:IsEmpty() and ((IsPresetPoolOk == nil) or (caller:InputCallFunction(IsPresetPoolOk, PresetPool) == true)) then
				local name = PresetPool.Name;
				caller:AddListLuaItem(name, "SelectPresetPool", SelectPresetPool, PresetPool, {number=tonumber(PresetPool.No),right=rightApp});
				count = count + 1;
				if PresetPool == CurrentPresetPool then
					selectIndex = count;
				end
			end
		end
		return {selectIndex, count};
	end
	return {0, offset};
end





