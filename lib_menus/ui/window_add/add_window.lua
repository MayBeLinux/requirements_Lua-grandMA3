local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

AddWindowInitTracker = {}

function AddWindowHasPendingLuaInits(caller)
	local o = caller:GetOverlay();
	local a = AddWindowInitTracker[o]
	return a ~= nil and a > 0
end

local function EnterInitSection(caller)
	local o = caller:GetOverlay();
	if AddWindowInitTracker[o] == nil then
		AddWindowInitTracker[o] = 1
	else
		AddWindowInitTracker[o] = AddWindowInitTracker[o] + 1
	end
	-- Echo('Entered for '..tostring(o)..':'..AddWindowInitTracker[o])
end

local function LeaveInitSection(caller)
	local o = caller:GetOverlay();
	AddWindowInitTracker[o] = AddWindowInitTracker[o] - 1
	-- Echo('Left for '..tostring(o)..':'..AddWindowInitTracker[o])
end

local function IsSmallScreen(caller)
    
    local d = caller:GetDisplay();
	local DisplayIndex = d:Index();

	if (DisplayIndex == 6 or DisplayIndex == 7) then
        return true;
	else
	   if (DisplayIndex == 1) then
	       local subType = HostSubType();
		   local isRPU = subType == "RPU";
		   if (isRPU) then
               return true;
		   end
	   end
	end

	return false;
end


signalTable.PoolMaterialsLoaded= function(caller,status,creator)
	EnterInitSection(caller)
	if (DevMode3d()=="No") then
		caller.visible=false;
		Echo("PoolMaterialsLoaded");
	end
	LeaveInitSection(caller)
end

signalTable.AddWindowLoaded = function(caller,status,creator)
	EnterInitSection(caller)
	--local tabs = caller.Frame.AddWindowTabs;
	local d = caller:GetDisplay();
	if (d:Index() <= 5) then
		caller.H = 605;
	end

	caller:HookDelete(function()
		if (IsObjectValid(d)) then
			d.UpdateScreen();
		end
	end);

	local AllWindowsFilterSwitches = caller.Frame.TabContainer.All.AllScrollBox.AllLayoutGrid.FilterBlock.FilterSwitches;
	local AllWindowsGrid = caller.Frame.TabContainer.All.AllScrollBox.AllLayoutGrid.AllWindowsGrid;

	if AllWindowsFilterSwitches then
		AllWindowsFilterSwitches.FilterSheets.Target = AllWindowsGrid.Internals.GridBase.MyGridSettings.GridObjectContentFilter.FilterTypeSheets;
		AllWindowsFilterSwitches.FilterPools.Target = AllWindowsGrid.Internals.GridBase.MyGridSettings.GridObjectContentFilter.FilterTypePools;
		AllWindowsFilterSwitches.FilterPresets.Target = AllWindowsGrid.Internals.GridBase.MyGridSettings.GridObjectContentFilter.FilterTypePresets;
		AllWindowsFilterSwitches.FilterOthers.Target = AllWindowsGrid.Internals.GridBase.MyGridSettings.GridObjectContentFilter.FilterTypeOthers;
	end

	AllWindowsGrid.SortByColumn("Asc", 0);

	signalTable.SetWindowTypesIconReference(caller.Frame.TabContainer);
--	signalTable.ParseWindowTypes(caller);
	LeaveInitSection(caller)
end

signalTable.ExecuteOnKeyDown = function(caller,dummy,keyCode,shift,ctrl,alt)

    if ((keyCode > Enums.KeyboardCodes.Slash) and (keyCode <= Enums.KeyboardCodes.Z)) then
	    local tabs = caller.Frame.AddWindowTabs;
	    local idx = tabs:FindListItemByName("All");
		
	    if idx and tabs:IsListItemEnabled(idx) then
	        if tabs:GetListSelectedItemIndex() ~= idx then
		        tabs:SelectListItemByIndex(idx);
			    local AllTabEdit = caller.Frame.TabContainer.All.AllScrollBox.AllLayoutGrid.FilterBlock.FilterEdit;
			    if AllTabEdit then
				     local keyStr = "0123456789_______abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
					 local index = keyCode - Enums.KeyboardCodes.Slash;
					 if (keyCode >= Enums.KeyboardCodes.A) and shift then 
					     index = index + 26;
					 end
					
					 local character = string.sub(keyStr, index, index);
					 --Echo(character);
			         AllTabEdit.Clear();
					 if HostType() == "onPC" then
					     local focusedObject = GetFocus();
					     if focusedObject ~= AllTabEdit then
					         FindNextFocus();				     
						 end
					 end
					 Keyboard(caller:GetDisplay():Index(), 'char', character);					 
			         return true;
			    end
		    end
	    end     
	end
    if keyCode == Enums.KeyboardCodes.Tab then
	    FindNextFocus(shift);
	end	
end

signalTable.CommonElementsLoaded = function(caller,status,creator)

    EnterInitSection(caller)
    if (IsSmallScreen(caller)) then
	    caller.Visible = false;
	    caller.SetRow(0, Enums.LayoutSizePolicy.Fixed, 58, 0);		
		caller.SetRow(1, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(2, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(3, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(4, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(5, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.Visible = true;
	end 
	LeaveInitSection(caller)
end

signalTable.ElementsLoaded = function(caller,status,creator)

	EnterInitSection(caller)
    if (IsSmallScreen(caller)) then
	    caller.Visible = false;
	    caller.SetRow(0, Enums.LayoutSizePolicy.Fixed, 0, 0);		
		caller.SetRow(1, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(2, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(3, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(4, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(5, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.SetRow(6, Enums.LayoutSizePolicy.Fixed, 58, 0);
		caller.Visible = true;
	end 
	LeaveInitSection(caller)
end

local PresetTypeToPoolColor = 
{
	[0] = "PoolWindow.PresetDimmer",
	[1] = "PoolWindow.PresetPosition",
	[2] = "PoolWindow.PresetGobo",
	[3] = "PoolWindow.PresetColor",
	[4] = "PoolWindow.PresetBeam",
	[5] = "PoolWindow.PresetFocus",
	[6] = "PoolWindow.PresetControl",
	[7] = "PoolWindow.PresetShapers",
	[8] = "PoolWindow.PresetVideo",
	[20] = "PoolWindow.PresetAll",
	[21] = "PoolWindow.PresetAll",
	[22] = "PoolWindow.PresetAll",
	[23] = "PoolWindow.PresetAll",
	[24] = "PoolWindow.PresetAll",
	[4294967295] = "PoolWindow.PresetDynamic"
}

signalTable.PresetElementsLoaded = function(caller,status,creator)
	EnterInitSection(caller)
	local profile = CurrentProfile();
	if (profile) then
		local WindowTypes = profile.WindowTypes;
		local nTypes = WindowTypes:Count();
		local ii = 1;
		local left = 1;
		local top = 1;
		local topStart = 1;
		local topAllIndex = 1;
		local topAll = 2;
		local topMax = 7;
		local smallScreen = IsSmallScreen(caller);

		if (smallScreen) then
		    caller.Visible = false;
		    caller.SetRow(0, Enums.LayoutSizePolicy.Fixed, 0, 0);		    
		end 

		local dataPool = profile.SelectedDataPool;
		if (dataPool) then
		    
		    local NormalPoolCount = 1;
		    while ii <= nTypes do
				local WT = WindowTypes[ii];
				if (WT.Type == "Presets") then
				   if not (WT.PresetPoolType == 4294967295) then
				        local pool_id = WT.PresetPoolType;
						local pool = dataPool.PresetPools:Ptr(pool_id + 1);
						if (pool) then
							if (pool_id < 20) then  -- PresetPoolCollect::NormalPoolCount == 20
							   NormalPoolCount = NormalPoolCount + 1;
							end
						end
				   end
				end
				ii = ii + 1;
			end

			if ((NormalPoolCount // 3) > topMax) then
			    topMax = (NormalPoolCount // 3) + 1;
			end

			ii = 1;
			
			while ii <= nTypes do
				local WT = WindowTypes[ii];
				if (WT.Type == "Presets") then
					local button = caller:Append("IndicatorButton");
					button.Texture		= "corner15";
					local colorString = PresetTypeToPoolColor[WT.PresetPoolType]

					if type(colorString) == "string" then
						button.ColorIndicator = colorString;
					else
						button.ColorIndicator = "PoolWindow.Presets"
					end

					button.Clicked		= "CommandLine";
					button.CloseAction	= "Ok";
					button.SignalValue="STORE SCREENCONTENT DEFAULT '" .. WT.Name ..
						"' MinW=" .. WT.MinW ..
						" MinH=" .. WT.MinH ..
						" MaxW=" .. WT.MaxW ..
						" MaxH=" .. WT.MaxH ..
						" PresetPoolType=" .. WT.PresetPoolType ..
						" SnapToBlockSize='" .. tostring(WT.SnapToBlockSize) .. "' /NC";

					if(WT.PresetPoolType == 4294967295) then
						button.Text    = "Dynamic";
						button.Visible = true;
						button.Anchors = "0,1";
						button.Name	= "PresetsDynamic";
						button.Icon = "object_preset";
						button.IconAlignmentH = "Left";
						button.Padding = "10,0,10,0";
						button.ToolTip = "Open a Dynamic preset pool window."
					else
						local pool_id = WT.PresetPoolType;
						local pool = dataPool.PresetPools:Ptr(pool_id + 1);
						if (pool) then
							if (pool_id >= 20) then         -- PresetPoolCollect::NormalPoolCount == 20
								button.Anchors = tostring(0 .. "," .. topAll);
								button.ToolTip = "Open an All "..topAllIndex.." preset pool window."
								topAllIndex = topAllIndex + 1;
								topAll = topAll + 1;
							else
								button.Anchors = tostring(left .. "," .. top);
								button.ToolTip = "Open a "..pool.Name.." preset pool window.";							
								top = top + 1;					
							end
							button.TextLeftCorner = tostring(pool_id + 1);
							button.Text = pool.Name;
							button.Visible = true;
							button.Name	= "Presets"..pool.Name;
							button.Icon = "object_preset";
							button.IconAlignmentH = "Left";
							button.TextAutoAdjust = "Yes";
							button.Padding = "10,0,10,0";							
						end
					end

					if (smallScreen) then
					    caller.SetRow(top, Enums.LayoutSizePolicy.Fixed, 58, 0);
					end

					if(top == topMax) and (left < 3) then
					    left = left + 1;
						top = topStart;				
					end

					local rowCount = caller.Rows;
					if(button.Anchors.top >= rowCount) then
						caller.Rows = rowCount+1;
						if (smallScreen) then
						    caller.SetRow(rowCount, Enums.LayoutSizePolicy.Fixed, 58, 0);
						else
						    caller.SetRow(rowCount, Enums.LayoutSizePolicy.Fixed, 60, 0);
						end
					end
				end
				ii = ii + 1;
			end
		end

		if (smallScreen) then
		    caller.Visible = true;		    
		end 
    end
		
	--WindowTypes.IconReferencesSet = false;
	local o = caller:GetOverlay();
	signalTable.SetWindowTypesIconReference(o.Frame.TabContainer);
	
	LeaveInitSection(caller)
end

signalTable.OnAllWindowsItemSelected = function(caller,status,col_id,row_id)
	local itemWindow=IntToHandle(row_id);
	local o = caller:GetOverlay();
	if itemWindow then
		Cmd("STORE SCREENCONTENT DEFAULT '" .. itemWindow.Name ..
		"' MinW=" .. itemWindow.MinW ..
		" MinH=" .. itemWindow.MinH ..
		" MaxW=" .. itemWindow.MaxW ..
		" MaxH=" .. itemWindow.MaxH ..
		" PresetPoolType=" .. itemWindow.PresetPoolType ..
		" SnapToBlockSize='" .. tostring(itemWindow.SnapToBlockSize) .. "' /NC");	    
		o.Close();
	end
end

signalTable.JumpToGrid = function(caller)
	local o = caller:GetOverlay();
	FindNextFocus();
end

signalTable.ParseWindowTypes = function(overlay)
	local WindowTypeCollect = CurrentProfile().WindowTypes;
	local nTypes = WindowTypeCollect:Count();
	local typesTable = {};

	for ii = 1,nTypes,1 do
		local WindowType = WindowTypeCollect:Ptr(ii);
		typesTable[string.lower(WindowType.Name)] = true;
	end

	signalTable.FindWindowInTable(overlay.Frame.TabContainer.Common, typesTable);
	signalTable.FindWindowInTable(overlay.Frame.TabContainer.Pools, typesTable);
	signalTable.FindWindowInTable(overlay.Frame.TabContainer.More, typesTable);

end

signalTable.FindWindowInTable = function(container, typesTable)
	local grid = container:Ptr(3):Ptr(1);
	local nWindows = grid:Count();
	for ii = 1,nWindows,1 do
		local window = grid:Ptr(ii);
		if(window:IsClass("IndicatorButton") == true) then
			local WindowName = window.SignalValue:gsub(".*DEFAULT '", "");
			WindowName = WindowName:gsub("'.*", "");
			if(typesTable[string.lower(WindowName)] == nil) then
				Echo("WindowType for " .. WindowName .. " does not exist");
			end
		end
	end
end

signalTable.SetWindowTypesIconReference = function(containers)
	local WindowTypeCollect = CurrentProfile().WindowTypes;

	if WindowTypeCollect.IconReferencesSet == false then
	    local nTypes = WindowTypeCollect:Count();
 	    local typesTable = {};

	    for ii = 1,nTypes,1 do
		    local WindowType = WindowTypeCollect:Ptr(ii);
		    typesTable[string.lower(WindowType.Name)] = ii;
	    end

		local nContainer = containers:Count();
		for jj = 1,nContainer,1 do
		    local container = containers:Ptr(jj);
		    local scrollbox = container.ScrollBox;
		    if(scrollbox) then		
		        local grid = scrollbox:Ptr(1);
	            local nWindows = grid:Count();
		        for ii = 1,nWindows,1 do
		            local window = grid:Ptr(ii);
		            if(window:IsClass("IndicatorButton") == true) then
			            local WindowName = window.SignalValue:gsub(".*DEFAULT '", "");
			            WindowName = WindowName:gsub("'.*", "");
				    local wTypeIndex = typesTable[string.lower(WindowName)];
				    if wTypeIndex == nil then
					    ErrEcho("For window '"..tostring(WindowName).."' not type index was found!");
				    end
			            if wTypeIndex and (wTypeIndex >= 0) and (wTypeIndex < nTypes) then
				            local WType = WindowTypeCollect:Ptr(wTypeIndex);
				            WType.Icon = window.Icon;				    
			            end
		            end
	            end
		    end -- scrollbox
		end
		WindowTypeCollect.IconReferencesSet = true;
	end
end
