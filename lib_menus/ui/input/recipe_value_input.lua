local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	local target = caller.context;

	signalTable.OnDataPoolLoaded(caller.Titlebar.DataPoolSelect)
	signalTable.OnLoadedLeft(caller.Frame.Left, target)
end

signalTable.OnLoadedLeft = function(layoutGrid, target)
	local listLeft = layoutGrid.List
	local listRight = layoutGrid:Parent().Right.ScrollContainer.List

	listLeft:ClearList()
	listRight:ClearList()

	listLeft:AddListStringItem("None","Empty");

	signalTable.AddPresets(listLeft, target)
	signalTable.AddGenerators(listLeft, target)

	coroutine.yield({ui=1})
	listLeft:Changed();
end

local function GetDatapool(overlay)
	local i = overlay.Titlebar.DataPoolSelect:GetListSelectedItemIndex()
	local dp = ShowData().DataPools[i]
	if dp then
		return dp
	else
		return DataPool()
	end
end

local function split_string(str, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
 end
 
local function AddExtraValues(list, overlay)
	 local addArgs = overlay.AdditionalArgs;
	 local extraN = tonumber(addArgs.ExtraValuesCount) or nil;
	 if extraN ~= nil then
		 for i=1,extraN,1 do
			 local v = addArgs["ExtraValue"..i];
			 local r = split_string(v, "|");
			 if #r == 2 then
				list:AddListStringItem(r[1], r[2]);
			 end
		 end
	 end
end

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

local function SelectPresetPool(caller, PresetPool)
	local baseInput = caller:GetOverlay()
	local listLeft = baseInput.Frame.Left.List
	local listRight = baseInput.Frame.Right.ScrollContainer.List

	local withOwnData = nil;
	local addArgs = baseInput.AdditionalArgs;
	if addArgs.WithOwnDataOnly == "Yes" then
		withOwnData = true;
	end

	local IsPresetOk = "IsPresetOk";
	if baseInput:InputHasFunction(IsPresetOk) ~= true then IsPresetOk = nil; end

	local CurrentValue = baseInput.Context.Values
	local selectIndex = 0; -- 0 as fallback to trigger select change call
	listRight:ClearList();
	for Index,Preset in ipairs(PresetPool:Children()) do
		if Preset and not Preset:IsEmpty() and ((IsPresetOk == nil) or (baseInput:InputCallFunction(IsPresetOk, Preset) == true)) then
			if withOwnData ~= true or Preset.OwnDataPresent then
				-- itemList[#itemList+1] = { 'handle' , Preset.Name , Preset };
				listRight:AddListObjectItem(Preset, string.format("  %d %s", Preset:Index(),  Preset.Name), {appearance=true, scribble=true})

				if Preset == CurrentValue then
					selectIndex = listRight:GetListItemsCount()
				end
			end
		end
	end

	if selectIndex then
		listRight:SelectListItemByIndex(selectIndex)
	end

	listRight:Changed()

	-- local selIndex,resultValue = PopupInput({title="Preset", caller=caller, items=itemList, selectedValue=CurrentPreset, x=hintX, y=hintY, render_options={left_icon=true, number=true}, useLeftTop=true, add_args={FilterSupport="Yes", FilterDefaultVisible="Yes"}});
	-- if (selIndex == nil) then return; end;
	-- return caller,resultValue;
end

local function SelectRecipe(caller, Recipe, x, y)
	local baseInput = caller:GetOverlay()
	local listRight = baseInput.Frame.Right.ScrollContainer.List

	local IsPresetOk = "IsPresetOk";
	if caller:InputHasFunction(IsPresetOk) ~= true then IsPresetOk = nil; end

	local CurrentValue = baseInput.Context.Values
	local selectIndex = 0; -- 0 as fallback to trigger select change call
	listRight:ClearList();

	for Index,Preset in ipairs(Recipe:Parent():Children()) do
		if Preset and not Preset:IsEmpty() and ((IsPresetOk == nil) or (caller:InputCallFunction(IsPresetOk, Preset) == true)) then
			if Preset.OwnDataPresent and Preset ~= Recipe then				
				listRight:AddListObjectItem(Preset, string.format("%d %s", Preset:Index(),  Preset.Name), {appearance=false, scribble=false})

				if Preset == CurrentValue then
					selectIndex = listRight:GetListItemsCount()
				end
			end
		end
	end

	if selectIndex then
		listRight:SelectListItemByIndex(selectIndex)
	end

	listRight:Changed()
end



signalTable.AddPresets = function(list, target)
	local baseInput = list:GetOverlay()

	local dp = GetDatapool(list:GetOverlay())
	local presetpools = dp.PresetPools;
	if presetpools then
		local CurrentPreset = target.Values;
		local CurrentPresetPool = IsObjectValid(CurrentPreset) and CurrentPreset:Parent();
		local IsPresetPoolOk = "IsPresetPoolOk";
		if baseInput:InputHasFunction(IsPresetPoolOk) ~= true then IsPresetPoolOk = nil; end

		AddExtraValues(list, baseInput);

		local selectIndex = 0; -- 0 as fallback to trigger select change call
		local rightIcon = FindTexture("triangle_right");
		local rightApp = {image=rightIcon, mode=Enums.ImageBackGroundMode.Center};

		if HasValidRecipeSources(baseInput, baseInput.Context) == true then
			list:AddListLuaItem("Recipes", "SelectRecipe", SelectRecipe, baseInput.Context, {right=rightApp});
		end
		for Index,PresetPool in ipairs(presetpools:Children()) do
			if not PresetPool:IsEmpty() and ((IsPresetPoolOk == nil) or (baseInput:InputCallFunction(IsPresetPoolOk, PresetPool) == true)) then
				local name = PresetPool.Name;
				list:AddListLuaItem(name, "SelectPresetPool", SelectPresetPool, PresetPool, {number=tonumber(PresetPool.No),right=rightApp});

				if PresetPool == CurrentPresetPool then
					selectIndex = list:GetListItemsCount();
				end
			end
		end

		list:SelectListItemByIndex(selectIndex)
		if CurrentPresetPool and CurrentPresetPool:HasParent(dp) then
			SelectPresetPool(list, CurrentPresetPool)
		end
	end
end

local function SelectGenerators(caller, Generators, x, y)
	local baseInput = caller:GetOverlay()
	local listLeft = baseInput.Frame.Left.List
	local listRight = baseInput.Frame.Right.ScrollContainer.List

	listRight:ClearList();
	local CurrentValue = baseInput.Context.Values
	local selectIndex = 0
	local itemList = {};
	for Index,Generator in ipairs(Generators:Children()) do
		if Generator and not Generator:IsEmpty() then
			listRight:AddListObjectItem(Generator, string.format("  %d %s", Generator:Index(),  Generator.Name), {appearance=true, scribble=true})
			
			if Generator == CurrentValue then
				selectIndex = listRight:GetListItemsCount()
			end
		end
	end

	listRight:SelectListItemByIndex(selectIndex)

	-- local selIndex,resultValue = PopupInput({title="Generator", caller=caller, items=itemList, selectedValue=currentGenerator, x=hintX, y=hintY, render_options={left_icon=true, number=true}, useLeftTop=true, add_args={FilterSupport="Yes", FilterDefaultVisible="Yes"}});
	-- if (selIndex == nil) then return; end;
	-- return caller,resultValue;
end

signalTable.AddGenerators = function(list, target)
	local baseInput = list:GetOverlay()
	local currentValue = target.Values;

	local dp = GetDatapool(list:GetOverlay())
	local generatorTypes = dp.GeneratorTypes;
	if generatorTypes then
		local selectIndex = nil;
		local rightIcon = FindTexture("triangle_right");
		local rightApp = {image=rightIcon, mode=Enums.ImageBackGroundMode.Center};
		for Index,GeneratorPool in ipairs(generatorTypes:Children()) do
			if not GeneratorPool:IsEmpty() then
				list:AddListLuaItem(GeneratorPool.Name, "SelectGenerators", SelectGenerators, GeneratorPool, {right=rightApp});
				if currentValue and (currentValue:HasParent(GeneratorPool)) then
					selectIndex = list:GetListItemsCount();
				end
			end
		end
		
		if selectIndex then
			list:SelectListItemByIndex(selectIndex)
			if currentValue and currentValue:HasParent(dp) then
				SelectGenerators(list, currentValue:Parent())
			end
		end
	end
end

local function ApplyListValue(caller)
	local i = caller:GetListSelectedItemIndex()
	local item = caller:GetListItemValueStr(i)
	local o = caller:GetOverlay()
	if item then
		o.Value = item;
	end
end

signalTable.OnItemSelectedLeft = function (caller,status,col_id,row_id)
	ApplyListValue(caller)
	coroutine.yield({ui=3})
	local o = caller:GetOverlay()
	local scrollBoxRight = o.Frame.Right.ScrollContainer.List
	scrollBoxRight:ScrollDo(Enums.ScrollType.Horizontal, Enums.ScrollParamEntity.Area, Enums.ScrollParamValueType.Absolute, 0, false);
	FindBestFocus(o.Frame.Right.ItemFilterField)
end

signalTable.OnItemSelectedRight = function (caller,status,col_id,row_id)
	ApplyListValue(caller)
end

signalTable.FilterExecute = function(caller)
	local list = caller:Parent().ScrollContainer.List
	list:SelectFirst()
end

signalTable.FilterChanged = function(caller)
	local list = caller:Parent().ScrollContainer.List
	list:SelectListItemByIndex(1);
	signalTable.OnItemSelectedRight(list)
end

signalTable.OnDataPoolLoaded = function(caller,status,creator)
	local target = caller:GetOverlay().Context
	local value = target.Values
	local valueDP = value and value:FindParent("Pool") or DataPool()
	caller:SelectListItemByIndex(valueDP.no);
 end

 signalTable.OnDataPoolChanged = function(caller)
	local overlay = caller:GetOverlay()
	signalTable.OnLoadedLeft(overlay.Frame.Left, overlay.context)
end
