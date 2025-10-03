local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function OnSettingsChanged(settings, dummy, ctx)
    local Frame=ctx.Frame;
	Frame.Toolbars.LayerToolbar.Visible = settings.ShowLayerToolbar;
	local dynTitleButtons = ctx.TitleBar.DynamicTitleButtons;
	
	dynTitleButtons.ClearFilter.Visible = IsObjectValid(settings.Filter)
	
	Frame.Toolbars.MaskToolbar.Visible=settings.ShowMaskToolbar;
end

local function SetMasksTarget(caller,MaskContainer,settings)
	local filteredSheetSettingsFilterCollect = settings.FilteredSheetSettingsFilterCollect
	MaskContainer.Mask1.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(1)
	MaskContainer.Mask2.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(2)
	MaskContainer.Mask3.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(3)
	MaskContainer.Mask4.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(4)
	MaskContainer.Mask5.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(5)
	MaskContainer.Mask6.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(6)
	MaskContainer.Mask7.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(7)
	MaskContainer.Mask8.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(8)
	MaskContainer.Mask9.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(9)
	MaskContainer.Mask10.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(10)
	MaskContainer.Mask11.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(11)
	MaskContainer.Mask12.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(12)
	MaskContainer.Mask13.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(13)
	MaskContainer.Mask14.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(14)
	MaskContainer.Mask15.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(15)
	MaskContainer.Mask16.Target = filteredSheetSettingsFilterCollect:CmdlinePtr(16)
end

local function SetTitlebuttonsTarget(caller,status,settings)
	local titleButtons = caller.TitleBar.TitleButtons
	if (titleButtons) then
		titleButtons.StepControl.Target = settings
		titleButtons.ValueReadoutControl.Target = settings
		titleButtons.PartControl.Target = settings
		titleButtons.Speed.Target = settings
		titleButtons.PresetReadout.Target = settings
		titleButtons.ChannelSetReadout.Target = settings
		titleButtons.ShowLayerToolbar.Target = settings
		titleButtons.OutputSymbol.Target = settings
		titleButtons.OutputSymbolLayer.Target = settings
		titleButtons.FixtureSort.Target = settings
		titleButtons.FeatureSort.Target = settings
		titleButtons.FeatureSymbols.Target = settings
		titleButtons.ShowMaskToolbar.Target = settings
		titleButtons.MergeCells.Target = settings
		titleButtons.ShowNameField.Target = settings
		titleButtons.SheetMode.Target = settings
		titleButtons.Transposed.Target = settings
		titleButtons.ShowIDType.Target = settings
		titleButtons.ColorMode.Target = settings
		titleButtons.HideSubfixtures.Target = settings
		titleButtons.SortMode.Target = settings
		titleButtons.GroupByIDType.Target = settings
		titleButtons.Layer.Target = settings
		titleButtons.PartControl.Target="#";
		SetMasksTarget(caller, titleButtons, settings)
	else
		ErrEcho("[window fixture sheet]TitleButtons container was not found");
	end

end

signalTable.SetMaskTarget = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;

	SetMasksTarget(caller, caller, settings)
end


signalTable.FixtureSheetWindowLoaded = function(caller,status,creator)
	local settings = caller.WindowSettings;
	if (settings) then
		caller.TitleBar.Title.Settings = settings;
		local titleButtons = caller.TitleBar.TitleButtons;
		SetTitlebuttonsTarget(caller, status, settings)
				
		local dynTitleButtons = caller.TitleBar.DynamicTitleButtons;
		if (dynTitleButtons) then
			dynTitleButtons:SetChildren("Target",settings);
		else
			ErrEcho("[window fixture sheet]DynamicTitleButtons container was not found");
		end
		HookObjectChange(OnSettingsChanged, caller.WindowSettings, my_handle:Parent(), caller);
		OnSettingsChanged(caller.WindowSettings, nil, caller);
	else
		ErrEcho("[window fixture sheet]Settings object is null");
	end

	local UserProfile=CurrentProfile();
	HookObjectChange(signalTable.OnSetLayerTextUPChanged, UserProfile, my_handle:Parent(), caller.TitleBar.Title);
	local UserEnv=CurrentEnvironment();
	HookObjectChange(signalTable.OnSetLayerTextEnv, UserEnv, my_handle:Parent(), caller.TitleBar.Title);
	HookObjectChange(signalTable.OnSetLayerTextFSSettingsChanged, caller.WindowSettings, my_handle:Parent(), caller.TitleBar.Title);
	signalTable.OnSetLayerTextUPChanged(UserProfile, nil, caller.TitleBar.Title);
end

local valLayers = {
	["Absolute"] = true,
	["Relative"] = true,
	["Accel"] = true,
	["Decel"] = true,
	["Transition"] = true,
	["Width"] = true,
}

local function UpdateTitleLayerText(Title)
    
	if IsObjectValid(Title) then
		local w = Title:Parent():Parent()
		local s = w.WindowSettings;
		--local up = CurrentProfile()
		local env = CurrentEnvironment()

		local l = s:Get("Layer", Enums.Roles.Display)
		local s = env.FirstStep
		local lastpos = string.len(l)

		if string.sub(l,1,1) == "<" and lastpos > 2 and string.sub(l,lastpos,lastpos) == ">" then
		    local subl = string.sub(l,2,lastpos - 1)
			--l = up.Layer
			l = subl
		end

		if valLayers[l] == true and type(s) == "number" and s > 1 then
			Title.Text = "Fixture: " .. l .. " Step "..s			
		else
			Title.Text = "Fixture: " .. l;			
		end
	end
end

signalTable.OnSetLayerTextUPChanged = function(UserProfile, signal, Title)
	UpdateTitleLayerText(Title)
end

signalTable.OnSetLayerTextFSSettingsChanged = function(obj, signal, Title)
	UpdateTitleLayerText(Title)
end

signalTable.OnSetLayerTextEnv = function(env, signal, Title)
	UpdateTitleLayerText(Title)
end


signalTable.SetSettingsAsTarget = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.Target = settings;
end

signalTable.SetTargetSettings = function(caller,status,creator)
	signalTable.SetSettingsAsTarget(caller,status,creator)
end

signalTable.OnTitlebuttonsLoaded = function(caller,status)
	local Patch = Patch();
	if (Patch) then
		local idTypes = Patch.IDTypes;
		if(idTypes) then
			for i=1,idTypes:Count() do
				if caller["Idtype"..i] then
					caller["Idtype"..i].Text = idTypes:Ptr(i).Name;
				end
			end
		end;
	end;
end