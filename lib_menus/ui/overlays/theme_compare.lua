local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local TitleButton = nil;
local PrimaryTitleBtn = nil;
local SecondaryTitleBtn = nil;
local primaryTheme = nil;
local secondaryTheme = nil;


local function UpdateTitle()

	TitleButton.Text = "Compare Color Theme '" .. primaryTheme.FileName .. "' with '" ..secondaryTheme.FileName .. "'";
	PrimaryTitleBtn.Text = primaryTheme.FileName;
	if(secondaryTheme.ColorDefCollect:Count() > 0) then
		SecondaryTitleBtn.Text = secondaryTheme.FileName;
	else
		SecondaryTitleBtn.Text = "---";
	end
	FindBestFocus(TitleButton:GetOverlay().Content.PrimaryGrid);
end

local function UpdateTitlePrimary()
	-- We can not use the same function for different hooks
	UpdateTitle();
end

signalTable.OnMenuLoaded = function(caller,dummy,target)
	primaryTheme = Root().Temp.ThemeBase;
	secondaryTheme = Root().Temp.ThemeCompare;
	HookObjectChange(UpdateTitle,	secondaryTheme,	my_handle:Parent());
	HookObjectChange(UpdateTitlePrimary,	primaryTheme,	my_handle:Parent());
	signalTable.OnSetEditTarget(caller, dummy, target)

	if(primaryTheme.ColorDefCollect:Count() == 0) then
		CmdIndirect("Import ColorTheme Lib '" ..Root().ColorTheme.FileName .. ".xml' At _ColorThemeBase /nc");
	end

	if(secondaryTheme.ColorDefCollect:Count() == 0) then
		FindBestFocus(caller.Content.SecondaryGrid);
		CmdIndirect("Edit " .. ToAddr(secondaryTheme) .. " Property 'FileName'");
	end
end


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local content=caller.Content;

	signalTable.SetTarget(content, primaryTheme, secondaryTheme);

	TitleButton = caller.TitleBar.Title;
	PrimaryTitleBtn = content.PrimaryGrid.SubTitle.SubTitleText;
	SecondaryTitleBtn = content.SecondaryGrid.SubTitle.SubTitleText;
	UpdateTitle();
end

signalTable.SetTarget = function(content, primaryTarget, secondaryTarget)
	content.PrimaryGrid.DefinitionsGrid.PrimaryThemeGrid.TargetObject=primaryTarget;
	content.SecondaryGrid.DefinitionsGrid.SecondaryThemeGrid.TargetObject=secondaryTarget;
end

signalTable.ExportAsClicked = function(caller,dummy)
	caller:GetOverlay().IsInExport = true;
	local libExport = Root().Menus.LibraryExport;
	if (libExport) then
		local libExportUI = libExport:CommandCall(caller,false);
		if (libExportUI) then
			local theme = secondaryTheme;
			if(caller:GetOverlay().PrimaryHasFocus) then
				theme = primaryTheme;
			end
			libExportUI.Context = theme;
			if(caller:GetOverlay().PrimaryHasFocus) then
				libExportUI:InputSetTitle("Export Base Theme as:");
			else
				libExportUI:InputSetTitle("Export Compare Theme as:");
			end
			result = libExportUI:InputRun();
			if (result) then
				local fn = libExportUI.Content.FileContainer.FileName.Content;
				if (fn ~= "") then
					theme.FileName = fn; 
				end
			end
			libExportUI:Parent():Remove(libExportUI:Index());
			WaitObjectDelete(libExportUI, 1);
			FindNextFocus();
			UpdateTitle();
		end
	end
	caller:GetOverlay().IsInExport = false;
end

signalTable.SecondaryTarget = function(caller)
	caller.Target = secondaryTheme;
end

signalTable.PrimaryTarget = function(caller)
	caller.Target = primaryTheme;
end


signalTable.AddColors= function(caller)
	local target = caller:GetOverlay();
	target:AddMissingLines();
end

signalTable.AddSelectedColors= function(caller)
	local target = caller:GetOverlay();
	target:AddSelectedLines();
end

signalTable.TestFcn= function(caller)
	local target = caller:GetOverlay();
	target:JumpToNextLine();
end
signalTable.TestFcn2= function(caller)
	local target = caller:GetOverlay();
	target:JumpToPreviousLine();
end

signalTable.ToggleRowFilter= function(caller)
	local colorGroup = Root().ColorTheme.ColorGroups.Button;
	local overlay = caller:GetOverlay();
	if(overlay.content.PrimaryGrid.DefinitionsGrid.PrimaryThemeGrid.Internals.GridBase.GridSettings.GridContentFilter.MissingOrMerged.Filter == "Yes") then
		overlay.content.PrimaryGrid.DefinitionsGrid.PrimaryThemeGrid.Internals.GridBase.GridSettings.GridContentFilter.MissingOrMerged.Filter="";
		overlay.content.SecondaryGrid.DefinitionsGrid.SecondaryThemeGrid.Internals.GridBase.GridSettings.GridContentFilter.MissingOrMerged.Filter="";
		caller.IconColor=colorGroup.Icon;
	else
		overlay.content.PrimaryGrid.DefinitionsGrid.PrimaryThemeGrid.Internals.GridBase.GridSettings.GridContentFilter.MissingOrMerged.Filter="Yes";
		overlay.content.SecondaryGrid.DefinitionsGrid.SecondaryThemeGrid.Internals.GridBase.GridSettings.GridContentFilter.MissingOrMerged.Filter="Yes";
		caller.IconColor=colorGroup.ActiveIcon;
	end
end