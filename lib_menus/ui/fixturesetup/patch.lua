local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

--[[
	common functions for patch (live and edit) can be found in
	patch_common.lua
]]

local indexTemporaryWindowSettings  = 10;
local indexView3DSettings			= 10;

signalTable.FixturePatchLoaded = function(caller, str)
	FixturePatchLoadedCommon(caller, str)
	CallInsertFixturesWizzardIfPatchEmpty(caller);

	local o = caller:GetOverlay()
	local fixtureGrid = o.Content.MainFixturesGridContainer.FixturesSetupGrid;
	local selObj = fixtureGrid:GridGetSelection();
	HookObjectChange(signalTable.CheckMultiPatchAllowed, selObj, my_handle:Parent(), caller);
	-- Echo("OnPatch3DLoaded");
	o.Content.MainFixturesGridContainer.View3DArea.Visible="Yes";
	local userProfile							= CurrentProfile();
	local ToolbarLeftTop						= o.Content.MainFixturesGridContainer.View3DArea.LayoutGrid.ToolbarLeftTop;
	local temporaryWindowSettings				= userProfile:Ptr(indexTemporaryWindowSettings);
	local View3DSettings						= temporaryWindowSettings:Ptr(indexView3DSettings);
	ToolbarLeftTop.Select.Target				= View3DSettings;
	ToolbarLeftTop.Move.Target					= View3DSettings;
	ToolbarLeftTop.Orbit.Target					= View3DSettings;
	ToolbarLeftTop.Zoom.Target					= View3DSettings;
	ToolbarLeftTop.FocusControl.Target			= View3DSettings;
	ToolbarLeftTop.Pivot.Target					= View3DSettings;
	ToolbarLeftTop.SetPivot.Target				= View3DSettings;

	local patch_settings=GetPatchSettings()
	HookObjectChange(PatchSettingsChangedCallback, patch_settings, my_handle:Parent(), caller);
	PatchSettingsChangedCallback(patch_settings, nil, caller)
	Show3D(caller);
end

signalTable.SelectedFixturesAfterCmd = function(caller, dummy, selInt, cmdToken)
	if IsInPatchSplitView() then
		local sel = IntToHandle(selInt)
		local cmdText = GetTokenNameByIndex(cmdToken)

		if IsObjectValid(sel) and cmdText == "Paste" then
			local o = caller:GetOverlay()
			local subTabs = o.PatchModesCont.PatchModes;
			local splitBy = subTabs.SelectedItemValueStr;
			local selObjects = caller.SelectedObjects;
			local processed = true
			if splitBy == "SplitViewLayers" then
				local sel = PatchGetSplitGridFirstSelected(o);
				if sel ~= nil then 
					local layer = IntToHandle(sel) 
					if IsObjectValid(layer) and layer:IsClass("PatchFilterItem") then
						if layer:Index() == 2 then --empty
							layer = nil --reset
						else
							return;
						end
					end
					for i=1,#selObjects,1 do
						local tgtObj = selObjects[i]
						if tgtObj:IsClass("Fixture") then
							tgtObj.Layer = layer
						end
					end
				end
			elseif splitBy == "SplitViewClasses" then
				local sel = PatchGetSplitGridFirstSelected(o);
				if sel ~= nil then 
					local class = IntToHandle(sel) 
					if IsObjectValid(class) and class:IsClass("PatchFilterItem") then
						if class:Index() == 2 then --empty
							class = nil --reset
						else
							return;
						end
					end
					for i=1,#selObjects,1 do
						local tgtObj = selObjects[i]
						if tgtObj:IsClass("Fixture") then
							tgtObj.Class = class
						end
					end
				end
			elseif splitBy == "SplitViewIDTypes" then
				local sel = PatchGetSplitGridFirstSelected(o);
				if sel ~= nil then 
					local idtype = IntToHandle(sel) 
					local idName = idtype.Name;
					if IsObjectValid(idtype) and idtype:IsClass("PatchFilterItem") then
						if idtype:Index() == 2 then --empty
							idName = nil
						else
							return;
						end
					end
					local idx = idtype:Index() - 1
					local opts={ids={}}
					local n =  #selObjects
					for i=1,n,1 do
						local tgtObj = selObjects[i]
						if tgtObj:IsClass("Fixture") then
							PatchTrySetID(tgtObj, idName, idx, opts)
						end
					end
				end
			elseif splitBy == "SplitViewDMXUniverses" then
				local sel = PatchGetSplitGridFirstSelected(o);
				if sel ~= nil then 
					local dmxUniv = IntToHandle(sel) 
					local dmxNum = dmxUniv:Index();
					--local next = dmxNum*512
					local opts={patched={}}

					if IsObjectValid(dmxUniv) and dmxUniv:IsClass("PatchFilterItem") then
						if dmxUniv:Index() == 2 then --empty
							dmxNum = nil
						else
							return;
						end
					end

					for i=1,#selObjects,1 do
						local tgtObj = selObjects[i]
						if tgtObj:IsClass("Fixture") then
							if dmxNum == nil then
								tgtObj.Patch=""
							else
								TryPatchIntoUniverse(tgtObj, dmxNum, opts)
							end
						end
					end
				end
			elseif splitBy == "SplitViewFixtureTypes" then
			    -- this code is dangerous : it fails with grouping fixtures 
				-- and other fixtures that can have children !
				-- local sel = PatchGetSplitGridFirstSelected(o);
				-- if sel ~= nil then 
				-- 	local dm = nil;
				-- 	local ftFake = IntToHandle(sel)
				-- 	if ftFake:GetClass() == "FixtureTypeFake" then
				-- 		local ft = ftFake.FTRef;
				-- 		dm = ft.DMXModes:Ptr(1)
				-- 	elseif ftFake:GetClass() == "DMXModeFake" then
				-- 		dm = ftFake.DMRef;
				-- 	end
				-- 
				-- 	if dm ~= nil then
				-- 		for i=1,#selObjects,1 do
				-- 			local tgtObj = selObjects[i]
				-- 			if tgtObj:IsClass("Fixture") then
				-- 				if tgtObj.ModeDirect ~= dm then
				-- 					tgtObj.ModeDirect = dm
				-- 				end
				-- 			end
				-- 		end
				-- 	end
				-- end
			else
				processed = false
			end
			--refresh filter
			if processed == true then
				caller:GridGetSettings():Ptr(3):Changed();
			end
		end
	end
end

signalTable.OnEditMode = function(caller, str)
	local o = caller:GetOverlay()
	local fixtureGrid = o.Content.MainFixturesGridContainer.FixturesSetupGrid;
	local selection = fixtureGrid:GridGetSelection().SelectedItems
	local firstSelectecFixture = IntToHandle(selection[1].row)
	if firstSelectecFixture:IsClass("Fixture") and firstSelectecFixture.ModeDirect ~= nil then
		local overlay = caller:GetOverlay()
		local uiEditorName = firstSelectecFixture.ModeDirect:GetUIEditor();
		overlay.SwitchMenuWithTarget(uiEditorName, firstSelectecFixture.ModeDirect);
	end
end

signalTable.CreateMultiPatch = function(caller, str)
	local v = nil
    local numInput = Root().Menus.TextInputNumOnly;
    if (numInput) then
        local numInputUI = numInput:CommandCall(caller,false);
        if (numInputUI) then
			numInputUI:InputSetTitle("Amount of MP fixtures:\n[1..1024]");
			numInputUI:InputSetMaxLength(4);
			numInputUI:InputSetValue("1");
            local result = numInputUI:InputRun();
            if (result) then
				v = tonumber(result.Value)
			end
            numInputUI:Parent():Remove(numInputUI:Index());
            coroutine.yield();
		end
	end

	if v ~= nil and v > 0 then
		local o = caller:GetOverlay()
		local fixtureGrid = o.Content.MainFixturesGridContainer.FixturesSetupGrid;
		local selection = fixtureGrid:GridGetSelection().SelectedItems
		local n = #selection
		local fixtures = {}
		if n > 0 then
			local undoText = "Create "..v.." multi-patch fixtures for up to "..n.." fixtures"
			for i=1,n,1 do
				local f = IntToHandle(selection[i].row)
				fixtures[#fixtures + 1] = f;
			end
			CreateMultiPatch(fixtures, v, undoText)
		end
	end
end

signalTable.CheckMultiPatchAllowed = function(obj, cl, ctx)
	local selection = obj.SelectedItems
	local n = #selection
	local enabled = false
	if n > 0 then
		for i=1,n,1 do
			local f = IntToHandle(selection[i].row)
			if f and f:IsClass("Fixture") and (f.IsMultipatch or f.ChannelRTCount > 0) and f.IDType ~= "Universal" then
				local mp = f
				if f.IsMultipatch then mp = f.MultipatchMain end
				if mp.MultipatchCount < Enums.Config.MaxMultiPatchPerFixture then
					enabled = true;
					break;
				end
			end
		end
	end

	local btn = ctx:FindRecursive("MPCreate", "IndicatorButton");
	btn.Enabled = enabled
end

function Show3D(caller)
	local o = caller:GetOverlay()
	local oParent = caller:Parent();
	local visibleState="No";
	if GetPatchSettings().Show3DPositions then
		visibleState="Yes";
	end
	Echo(string.format(">>> Visible State %s. Caller was:%s",visibleState,o.name));
	o.Content.MainFixturesGridContainer.View3DArea.Visible=visibleState;
	o.Content.MainFixturesGridContainer.Resizer3D.Visible = visibleState;
	o.TitleBar.TitleButtons3D.Visible = visibleState;
	o:OnShow3dSettings();
end

signalTable.OnShow3D = function(caller, dummy, selInt, cmdToken)
	Show3D(caller);
end

signalTable.Patch3DViewResizeEnd = function(caller, dummy)
	Echo("Make the 3D in Patch visible");
	local o = caller:GetOverlay()
	o.Content.MainFixturesGridContainer.View3DArea.LayoutGrid.PatchView3DPlaceHolder.Visible="Yes";
	o.Content.MainFixturesGridContainer.View3DArea:Changed()
end

signalTable.Patch3DViewResizeStart= function(caller, dummy)
	Echo("Make the 3D in Patch invisible");
	local o = caller:GetOverlay()
	o.Content.MainFixturesGridContainer.View3DArea.LayoutGrid.PatchView3DPlaceHolder.Visible="No";
end

signalTable.Patch3DViewResizeMove= function(caller, dummy)
	-- caller:GetOverlay().Content.MainFixturesGridContainer.View3DArea:Changed()
end

local function Open3dSettingsWindow(dispIndex, testFrameWork)
	Echo("LUA Enter Open3dSettingsWindow");
	local display = GetDisplayByIndex(dispIndex);
	if display == nil then 
		error("Display "..dispIndex.." not found");
	end
	local modalOverlay = display.ModalOverlay;
	local addWindow = Root().Menus["WindowSettings3dPatch"]:CommandCall(modalOverlay);
	--coroutine.yield(0.3);--not nice, but no other way
	--return addWindow, screen, modalOverlay;
end

signalTable.Show3dSettings = function(caller, dummy, selInt, cmdToken)
	Echo("LUA Show3dSettings  called");
	local dispIndex = caller:GetDisplayIndex();
	Open3dSettingsWindow(dispIndex, caller)
end
