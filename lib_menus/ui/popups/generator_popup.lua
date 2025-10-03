local signalTable   = select(3,...); 

-- ************************************************************************************************************
--
-- ************************************************************************************************************

local function SelectGenerators(caller, Generators, x, y)
	local withOwnData = nil;
	local addArgs = caller.AdditionalArgs;
	if addArgs.WithOwnDataOnly == "Yes" then
		withOwnData = true;
	end

	local itemList = {};
	for Index,Generator in ipairs(Generators:Children()) do
		if Generator and not Generator:IsEmpty() then
			itemList[#itemList+1] = { 'handle' , Generator.Name , Generator };
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

	local selIndex,resultValue = PopupInput({title="Generator", caller=caller, items=itemList, selectedValue=currentGenerator, x=hintX, y=hintY, render_options={left_icon=true, number=true}, useLeftTop=true, add_args={FilterSupport="Yes", FilterDefaultVisible="Yes"}});
	if (selIndex == nil) then return; end;
	return caller,resultValue;
end

-- ************************************************************************************************************
--
-- ************************************************************************************************************


signalTable.OnLoaded = function(caller,status,creator)	
	caller:AddListStringItem("None","Empty")

	local selectIndex = signalTable.OnGeneratorPopupLoaded(caller, status, creator, 1);
	
	caller.TitleBar.Title.Text="Generator Pool";
	caller.Frame.Popup.ShowNumber=true;
	caller.Frame.Popup.ShowRightIcon=true;
	caller:SelectListItemByIndex(selectIndex);
	coroutine.yield({ui=1})
	caller:Changed();
end

signalTable.OnGeneratorPopupLoaded = function(caller,status,creator,offset)
	local generatorTypes = DataPool().GeneratorTypes;


	if generatorTypes then
		currentGenerator = StrToHandle(caller.Value);
		local currentPool = nil;

		if IsObjectValid(currentGenerator) then currentPool=currentGenerator:Parent();	end	

		local selectIndex = 0;
		local rightIcon = FindTexture("triangle_right");
		local rightApp = {image=rightIcon, mode=Enums.ImageBackGroundMode.Center};
		local count = offset;
		for Index,GeneratorPool in ipairs(generatorTypes:Children()) do
			if not GeneratorPool:IsEmpty() then
				caller:AddListLuaItem(GeneratorPool.Name, "SelectGenerators", SelectGenerators, GeneratorPool, {right=rightApp});
				count = count + 1;
				local selectedGen = GeneratorPool[caller.Value];
				if(selectedGen ~= nil) then
					selectIndex = Index+offset;
				end
			end
		end
		return {selectIndex, count};
	end
	return {0, offset};
end


