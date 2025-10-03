local signalTable   = select(3,...); 

-- ************************************************************************************************************
--
-- ************************************************************************************************************



-- ************************************************************************************************************
--
-- ************************************************************************************************************


signalTable.OnLoaded = function(caller,status,creator)
	local selectIndex=0;
	local selectIndex2=0;
	local count = 1;
	caller:AddListStringItem("None","Empty");
	local retTable = signalTable.OnPresetPopupLoaded(caller, status, creator, count);
	selectIndex = retTable[1];
	count = retTable[2];
	retTable = signalTable.OnGeneratorPopupLoaded(caller, status, creator, count);
	selectIndex2 = retTable[1];
	count = retTable[2];
	caller.TitleBar.Title.Text="Values";
	caller.Frame.Popup.ShowNumber=true;
	caller.Frame.Popup.ShowRightIcon=true;
	if(selectIndex2 > 0) then
		selectIndex = selectIndex2;
	end
	caller:SelectListItemByIndex(selectIndex);
	coroutine.yield({ui=1})
	caller:Changed();
end


