local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
-- Do nothing here -> We need the SwipeButton first		
end

signalTable.GetPopupItemListValidOnly = function(caller, list)
	list:ClearList();
	list:AddListStringItem("None","");
	local pool = signalTable.GetPool(caller);
	list:AddListChildren(pool);
end

signalTable.GetPool = function(caller)
	return ShowData().MediaPools[caller.ImageSource];	
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=true, right_icon=false};
end

signalTable.SetSourceTarget = function(caller)
	local Popup = caller:Parent():Parent();
	caller.Target = Popup;
	if(IsObjectValid(Popup) and IsObjectValid(Popup.Context) and (Popup.Context:GetClass() == "FixtureType")) then		
		Popup.ImageSource = Enums.ImageSource.Fixtures
	else
		Popup.ImageSource = Enums.ImageSource.Images
	end

	signalTable.ReloadList(Popup);
end

signalTable.ImagePoolChanged = function(caller)
	local Popup = caller:Parent():Parent();
	signalTable.ReloadList(Popup);
end

signalTable.ReloadList = function(Popup)
	local pool = signalTable.GetPool(Popup);
	if(pool) then
		local render_opts = signalTable.GetRenderOptions();
		signalTable.ApplyRenderOptions(Popup, render_opts);

		signalTable.GetPopupItemList(Popup, Popup);
		Popup:SelectListItemByValue(Popup.Value);
		Popup:Changed();
	end
end
