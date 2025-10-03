local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- **************************************************************************************************
-- load & save defaults functions 
-- **************************************************************************************************

signalTable.GetSelectedElement = function(Overlay)
end

signalTable.LoadDefaultsClicked = function(caller)

	--require"gma3_debug"();
	local Overlay	= caller:GetOverlay();
	local UP = CurrentProfile();
	local Defaults  = UP.LayoutElementDefaultsCollect;

	local manager_plugin=Root().Menus.ContextWindowManager;
	if(manager_plugin) then
		local manager_overlay=manager_plugin:CommandCall(caller);
		if(manager_overlay) then
			manager_overlay:InputSetTitle("Load Defaults");
			manager_overlay:InputSetAdditionalParameter("Mode", "Load");
			manager_overlay:InputSetAdditionalParameter("InsertType", "LayoutElementDefaults");
			local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
			ObjectGrid.AllowAddNewLine = true;
			ObjectGrid.TargetObject=Defaults;
			
			local layoutElement = signalTable.GetSelectedElement(Overlay);
			if(layoutElement) then
				for i,def in ipairs(Defaults) do
					if(def.ElementType == layoutElement.AssignType) then				
						local columnId = GetPropertyColumnId(def, "Name");
						ObjectGrid.SelectCell('',HandleToInt(def),columnId);
						local cells = ObjectGrid:GridGetSelectedCells();
						ObjectGrid:GridScrollCellIntoView(cells[1]);
						break;
					end
				end
			end

		    local result=manager_overlay:InputRun();
		    if(result) then
				local resultHandle=StrToHandle(result.Value);
				if(resultHandle) then
					Overlay:LoadFromDefault(resultHandle);
				end
		    end
		end
	end
end

signalTable.SaveDefaultsClicked = function(caller)
	local Overlay	= caller:GetOverlay();
	local UP = CurrentProfile();
	local Defaults  = UP.LayoutElementDefaultsCollect;

	local manager_plugin=Root().Menus.ContextWindowManager;
	if(manager_plugin) then
		local manager_overlay=manager_plugin:CommandCall(caller);
		if(manager_overlay) then
			manager_overlay:InputSetTitle("Save Defaults");
			manager_overlay:InputSetAdditionalParameter("Mode", "Save");
			manager_overlay:InputSetAdditionalParameter("InsertType", "LayoutElementDefaults");
			local ObjectGrid=manager_overlay.DialogFrame.ObjectGrid;
			ObjectGrid.AllowAddNewLine = true;
			ObjectGrid.TargetObject=Defaults;

			local layoutElement = signalTable.GetSelectedElement(Overlay);
			if(layoutElement) then
				for i,def in ipairs(Defaults) do
					if(def.ElementType == layoutElement.AssignType) then				
						local columnId = GetPropertyColumnId(def, "Name");
						ObjectGrid.SelectCell('',HandleToInt(def),columnId);
						local cells = ObjectGrid:GridGetSelectedCells();
						ObjectGrid:GridScrollCellIntoView(cells[1]);
						break;
					end
				end
			end

		    local result=manager_overlay:InputRun();
		    if(result) then
				local resultHandle=StrToHandle(result.Value);
				if(resultHandle) then
					Overlay:SaveAsDefault(resultHandle);
				end
		    end
		end
	end
end