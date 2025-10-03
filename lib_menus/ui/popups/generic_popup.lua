--	Attention: this file has to be included before any mycustom_popup.lua

local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnAddNew =  function(caller, status, context)
	local new_obj=signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller)):Acquire();

	-- Check flags for editing the object after created
	local editObject = true;
	local propertyControl = caller:FindParent("PropertyControl");

	if(signalTable.HasOwnEditor ~= nil) then
		editObject = not signalTable.HasOwnEditor(caller);
	elseif (propertyControl) then
		editObject = propertyControl.EditNewObject;
	end

	if(new_obj and editObject) then
		--[[
			performing a delayed 'edit root ...' execution in order to let the Popup to finish it's modal loop and mark itself as closed/closing

			otherwise 'edit' command is executed BEFORE popup is notified about Lua's 'return' values, while popup UIObject is still valid and not closed,
			so that the editor uses it as a placeholder source and is automatically closed with the popup itself few milliseconds later (as the result of 'return'
			 value processing)
		]]
		caller:HookDelete(function()
			if (IsObjectValid(new_obj)) then
				CmdIndirect("EDIT ROOT " .. new_obj:Addr());
			end
		end);
	end
	return caller,new_obj;
end

signalTable.GetEmptyText = function()
	return "None";
end

signalTable.GetPool = function()
	error("This is a default GetPool implementation that does nothing! Override either it or OnLoad method in your *_popup.lua file");
end

signalTable.GetRole = function()
	return Enums.Roles.DisplayShort;
end

signalTable.FilterSupport = function()
	return false
end

signalTable.FilterDefaultVisible = function()
	return false
end

signalTable.GetRenderOptions = function()
	return {left_icon=false, number=false, right_icon=false};
end

--This entry can be used by C++ side (e.g. BaseStateButton) in order to get the list to toggle through (hence 'valid only', no Lua-entries or other weird stuff should be here)
--normally you don't need to override this
signalTable.RequestItemListValidOnly = function(caller, list)
	if (list == nil) then list = caller; end;

	local pool = signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller));
	if(pool) then
		signalTable.GetPopupItemListValidOnly(caller, list);
	end
	return caller, list;
end

--This method is called normally from then OnLoad handler (default implementation defined below) and is just supposed to fill the passed 'list' parameter
--with entries to normally show in the popup
--This might be the target to override to provide additional 'special' entries
signalTable.GetPopupItemList = function(caller, list)
	signalTable.GetPopupItemListValidOnly(caller, list);
	local addArgs = caller.AdditionalArgs
	if ((signalTable.OnAddNew ~= nil) and (addArgs == nil or addArgs.noNew == nil)) then
		list:AddListLuaItem("New","OnAddNew", signalTable.OnAddNew
			--, nil, {left={image=FindTexture("plus")}}   <<-- example of adding icons to entries
		);
	end
end

--This method is supposed to fill the 'list' parameter with entries that one could toggle through (hence no lua-entries or other kind of 'special' entries)
signalTable.GetPopupItemListValidOnly = function(caller, list)
	local EmptyText=nil;
	local EmptyTextAppearance=nil;
	local EmptyTextOpts=nil;

	local addArgs = caller.AdditionalArgs
	if (addArgs and addArgs.AddEmpty) then
		EmptyText = addArgs.AddEmpty
	else
		if (signalTable.GetEmptyText) then
			EmptyText, EmptyTextAppearance, EmptyTextOpts = signalTable.GetEmptyText();
		end
	end

	if(EmptyText) then
		list:AddListStringItem(EmptyText,"", EmptyTextAppearance, EmptyTextOpts);
	end
	local pool = signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller));
	list:AddListChildren(pool, signalTable.GetRole());
end

signalTable.ApplyRenderOptions = function(popup, render_opts)
	local scrollList = popup.Frame.Popup;
	if render_opts.left_icon ~= nil then scrollList.ShowLeftIcon = render_opts.left_icon end
	if render_opts.number ~= nil then scrollList.ShowNumber = render_opts.number end
	if render_opts.right_icon ~= nil then scrollList.ShowRightIcon = render_opts.right_icon end
	if render_opts.left_scribble ~= nil then scrollList.ShowLeftScribble = render_opts.left_scribble end
	if render_opts.right_scribble ~= nil then scrollList.ShowRightScribble = render_opts.right_scribble end
end

signalTable.FilterFieldChanged = function(field, change, ctx)
	if field.Visible == true then
		ctx.Frame.Popup.Focus = "TabOnly"
		FindBestFocus(field);
	else
		ctx.Frame.Popup.ItemFilter = ""
		ctx.Frame.Popup.Focus = "WantsFocus"
	end
end

local selectedDataPool = nil
-- Used to first build the itemList and rebuild on e.g. DataPool changed
signalTable.BuildItemList = function(caller)
	local pool = signalTable.GetPool(caller, signalTable.GetSelectedDataPool(caller));
	local addArgs = caller.AdditionalArgs;

	if(pool) then
		caller:ClearList();
		if (addArgs.ValidOnly == "Yes") then
			signalTable.GetPopupItemListValidOnly(caller, caller);
		else
			signalTable.GetPopupItemList(caller, caller);
		end

		local render_opts = signalTable.GetRenderOptions();
		signalTable.ApplyRenderOptions(caller, render_opts);

		signalTable.SelectListItemBySomething(caller);
		coroutine.yield({ui=1})
		caller:Changed();
	end
end

signalTable.OnDataPoolChanged = function(caller)
	selectedDataPool = caller.SelectedItemIdx;
	signalTable.BuildItemList(caller:GetOverlay())
end

signalTable.GetSelectedDataPool = function(caller)
	local overlay = caller:GetOverlay();
	if(overlay == nil or overlay.TitleBar == nil or overlay.TitleBar.DataPoolSelect == nil or overlay.TitleBar.DataPoolSelect.Visible==false) then
	    local profile = CurrentProfile();
		if (profile) then
			return profile.SelectedDataPool;
		end
	else
	    --local dataPools = ShowData().DataPools;
		--return dataPools:Ptr(overlay.TitleBar.DataPoolSelect.SelectedItemIdx+1);	does not work, when datapool collect has gaps in between
		return IntToHandle(overlay.TitleBar.DataPoolSelect.SelectedItemValueI64);
	end

	return nil;
end

-- Shall the dataPoolSelector be visbile?
signalTable.EnableDataPoolSelector = function(selector)
	if(signalTable.UsePoolSelector()) then
		selector:Parent():Ptr(2):Ptr(3).Size="100" --actually visible
		selector.Visible = "Yes";
	end
end

signalTable.UsePoolSelector = function()
	return false;
end

--default implementation of the 'OnLoad' handler. Checks if pool object exists, fills the caller with the entries via GetPopupItemList call
signalTable.OnLoaded = function(caller,status,creator)
	signalTable.CustomOnLoaded(caller,status,creator);
	local addArgs = caller.AdditionalArgs;

	signalTable.BuildItemList(caller);

	if signalTable.FilterSupport() == true or addArgs.FilterSupport == "Yes" then
		caller.TitleBar:Ptr(2):Ptr(2).Size="50" --actually visible
		caller.TitleBar.FilterCtrl.Target = caller.Frame.ItemFilterField;
		caller.TitleBar.FilterCtrl.Visible = true;

		if(signalTable.FilterDefaultVisible() or addArgs.FilterDefaultVisible == "Yes") then
			caller.Frame.ItemFilterField.Visible = true;
		end
		HookObjectChange(signalTable.FilterFieldChanged,caller.Frame.ItemFilterField,my_handle:Parent(),caller);
		signalTable.FilterFieldChanged(caller.Frame.ItemFilterField,my_handle:Parent(),caller)

	end
end

-- Can be overwritten to simply add stuff to onLoaded
signalTable.CustomOnLoaded = function(caller,status,creator)
end

-- Can be overwritten to simply add stuff to onLoaded
signalTable.SelectListItemBySomething = function(caller)
    caller:SelectListItemByValue(caller.Value);
end
