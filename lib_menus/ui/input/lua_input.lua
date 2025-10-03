local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local MODES = { DEFAULT=1, TOOBIG=2, TEMPLATES=3, READONLY=4 }

local function ChangeModeTo(CurrentMode, caller)
	local o = caller:GetOverlay()

	local dim = caller:GetDisplay().AbsRect;
	local smallDisplay = dim.w <= 1000 or dim.h <= 500; --rpu

	-- Title Button enabling
	o.Title.ToggleTemplates.Enabled = CurrentMode ~= MODES.TOOBIG and CurrentMode ~= MODES.READONLY and not smallDisplay
	o.Title.ToggleAPI.Enabled = CurrentMode == MODES.DEFAULT and not smallDisplay
	o.Title.SaveBtn.Enabled = CurrentMode ~= MODES.TOOBIG and CurrentMode ~= MODES.READONLY

	-- Content visibility
	o.Frame.MaxSizeError.Visible = CurrentMode == MODES.TOOBIG and not smallDisplay
	o.Frame.LuaTemplates.Visible = CurrentMode == MODES.TEMPLATES and not smallDisplay
	o.Title.VK.Enabled = CurrentMode ~= MODES.TEMPLATES
	o.Title.Undo.Enabled  = CurrentMode == MODES.DEFAULT
	o.Title.Redo.Enabled  = CurrentMode == MODES.DEFAULT
	
	if CurrentMode == MODES.TOOBIG or CurrentMode == MODES.READONLY then
		o.Frame.ApiList.Visible = false
	end

	o.Frame.InputField.ReadOnly = CurrentMode == MODES.TOOBIG or CurrentMode == MODES.READONLY

	if CurrentMode == MODES.DEFAULT then
		FindBestFocus(o.Frame.InputField)
	elseif CurrentMode == MODES.TOOBIG then
		FindBestFocus(o.Frame.MaxSizeError)
	elseif CurrentMode == MODES.TEMPLATES then
		FindBestFocus(o.Frame.LuaTemplates)
	end
end

signalTable.LuaInputLoaded = function(caller,status,creator)
	-- Virtual Keyboard placeholder
	signalTable.RebuildPlaceholder(caller.Frame.VirtualKeyboardPlaceholder, "VirtualKeyboardContent");
	caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.TargetObject = caller.Frame.InputField;
	caller.Frame.VirtualKeyboardPlaceholder:Changed();

	local languageButton = caller.Frame.VirtualKeyboardPlaceholder.VirtualKeyboard.Language;
	if (languageButton) then
		local currentUser = CmdObj().User;	
		if (currentUser) then
			caller.Frame.VirtualKeyboardPlaceholder.Visible=currentUser.VKExpanded;
			local currentKeyboard = currentUser.Keyboard;
			if (currentKeyboard) then
				languageButton.Text = currentKeyboard.Name;
			end
		end
	end

	local undoBtn = caller.Title.Undo;
	local redoBtn = caller.Title.Redo;

	if (undoBtn) then
		undoBtn.ToolTip = "Undo last change (0 available)";
	end

	if (redoBtn) then
		redoBtn.ToolTip = "Redo last undo (0 available)";
	end

	local currentProfile = CurrentProfile();
	if (currentProfile) then
		caller.Frame.VirtualKeyboardPlaceholder.Visible=currentProfile.VKExpanded;
		signalTable.ToggleVirtualKeyboard(caller, currentProfile.VKExpanded);
	end

	local addArgs = caller.AdditionalArgs;
	local ExceedsMaxEditSize = false;
	if ((addArgs ~= nil) and (addArgs.ExceedsMaxEditSize ~= nil)) then ExceedsMaxEditSize = addArgs.ExceedsMaxEditSize == "Yes"; end;

	if caller.Target and caller.Target:IsLocked() then
		ChangeModeTo(MODES.READONLY,caller)
	elseif ExceedsMaxEditSize then
		ChangeModeTo(MODES.TOOBIG,caller)
	else
		ChangeModeTo(MODES.DEFAULT,caller)
	end

	-- Size and position
	local disp = caller:GetDisplay();
	local smallDisplay = disp.AbsRect.w <= 1000 or disp.AbsRect.h <= 500; --rpu
	if (smallDisplay == true) then
		caller.W = disp.AbsRect.w;
		caller.H = disp.AbsRect.h;
	else
		if (disp.AbsRect.w >= 1920) then
			caller.W = 1920;
		else
			caller.W = math.ceil(disp.AbsRect.w * 0.9);
		end
	end

	-- After all adjustments, make it visible:
	caller.Visible = true;
end

signalTable.UndoRedoChanged = function(caller,dummy,undosCount,redosCount)
	local overlay = caller:GetOverlay();

	local undoBtn = overlay.Title.Undo;
	local redoBtn = overlay.Title.Redo;

	if (undoBtn) then
		if (undosCount > 0) then
			undoBtn.State = true;
		else
			undoBtn.State = false;
		end
		undoBtn.ToolTip = "Undo last change ("..undosCount.." available)";
	end

	if (redoBtn) then
		if (redosCount > 0) then
			redoBtn.State = true;
		else
			redoBtn.State = false;
		end
		redoBtn.ToolTip = "Redo last undo ("..redosCount.." available)";
	end
end

signalTable.ToggleVirtualKeyboard = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local currentProfile = CurrentProfile();

		if (status == "" or status == nil) then
			newStatus = not overlay.Frame.VirtualKeyboardPlaceholder.Visible;
		else
			newStatus = status;
		end

		overlay.Frame.VirtualKeyboardPlaceholder.Visible = newStatus;
		overlay.Frame.VirtualKeyboardPlaceholder:Ptr(1):Changed()

		local currentProfile = CurrentProfile();
		if (currentProfile) then
			currentProfile.VKExpanded=newStatus;
		end
		
		-- Icon color
		if (overlay.Frame.VirtualKeyboardPlaceholder.Visible == true) then
			overlay.Title.VK.IconColor = Root().ColorTheme.ColorGroups.Button.ActiveIcon;
		else
			overlay.Title.VK.IconColor = Root().ColorTheme.ColorGroups.Button.Icon;
		end
	end
end

signalTable.CloseFileSizeError = function(caller)
	-- ChangeModeTo(MODES.DEFAULT,caller)
	caller:Parent().Visible = false
end

------------------------------------------------------------------------
-- Lua Templates

local LuaTemplates = {};
local SelectedTemplate = "";
local lastSelectedUI;

signalTable.OnTemplatesLoaded = function(caller)
	signalTable.ChangeTemplateSelection(caller.Commandline)
end

signalTable.TemplatesVisiblityBtnLoaded = function(caller)
	local overlay = caller:GetOverlay()
	caller.Target = overlay.Frame.LuaTemplates
end

signalTable.CloseTemplates = function(caller)
	ChangeModeTo(MODES.DEFAULT,caller)
end

signalTable.SetTemplateText = function(caller)
	caller.ReadOnly=false
	caller.Content = LuaTemplates[caller:Parent().name];
	caller.ReadOnly=true
end

signalTable.ChangeTemplateSelection = function(caller)
	if caller:GetClass() == "TextEdit" then caller = caller:Parent(); end
	SelectedTemplate = LuaTemplates[caller.name]

	if lastSelectedUI then
		lastSelectedUI.Visible = false;
	end

	lastSelectedUI = caller.SelectFrame
	lastSelectedUI.visible=true
end

signalTable.UseSelectedExample = function(caller)
	local overlay = caller:GetOverlay()
	if (Confirm("Overwrite?","The Lua Component will be overwritten.")) then
		overlay.Frame.InputField.Content = SelectedTemplate;
		ChangeModeTo(MODES.DEFAULT,caller)
	end
end

signalTable.TemplateBtnClicked = function(caller)
	local overlay = caller:GetOverlay()
	if overlay.Frame.LuaTemplates.Visible then
		ChangeModeTo(MODES.TEMPLATES,caller)
	else
		ChangeModeTo(MODES.DEFAULT,caller)
	end
end

------------------------------------------------------------------------
-- API List

local function BuildApiCombinedTable()
	local ret = {}
	local api = GetApiDescriptor()
	for _,v in ipairs(api) do
		-- v.Source = "Free-API"
		v.Source = ""
		ret[#ret+1] = v
	end
	api = GetObjApiDescriptor()
	for _,v in ipairs(api) do
		v.Source = "Object-API"
		ret[#ret+1] = v
	end
	return ret
end
local API_Combined = BuildApiCombinedTable()

signalTable.ApiVisiblityBtnLoaded = function(caller)
	local overlay = caller:GetOverlay()
	caller.Target = overlay.Frame.ApiList
end
signalTable.OnApiListLoaded = function(caller)
	caller:ClearList();

	for idx,v in ipairs(API_Combined) do
		local name, args, ret = v[1], v[2], v[3]
		if name and args and ret then
			local insertText = name.."("..args..")"
			caller:AddListNumericItem(name,idx);
		end
	end

	HookObjectChange(signalTable.AdjustSelectedAPIInfo,	-- 1. function to call
					caller,								-- 2. object to hook
					my_handle:Parent(),					-- 3. plugin object ( internally needed )
					caller)								-- 4. user callback parameter
	signalTable.AdjustSelectedAPIInfo(caller)
end
signalTable.AdjustSelectedAPIInfo = function(caller)
	local o = caller:GetOverlay()
	local infoCtr = o.Frame.ApiList.SelectedInfo
	local selectedAPI = API_Combined[caller.SelectedItemValueI64]
	if selectedAPI then
		infoCtr.FuncName.Text = selectedAPI[1]
		if selectedAPI.Source ~= "" then
			infoCtr.FuncName.Text = infoCtr.FuncName.Text .. " (".. selectedAPI.Source..")"
		end
		infoCtr.Arguments.ReadOnly = false
		infoCtr.Arguments.Content = selectedAPI[2]
		infoCtr.Arguments.ReadOnly = true
		infoCtr.ReturnValues.ReadOnly = false
		infoCtr.ReturnValues.Content = selectedAPI[3]
		infoCtr.ReturnValues.ReadOnly = true
	end
end
signalTable.InsertSelectedAPI = function(caller)
	local o = caller:GetOverlay()
	local itemList = o.Frame.ApiList.ItemList
	local selectedAPI = API_Combined[itemList.SelectedItemValueI64]
	local pasteString = selectedAPI[1];
	if selectedAPI[2] and selectedAPI[2] ~= "nothing" then
		pasteString = pasteString .. "("..selectedAPI[2]..")"
	else
		pasteString = pasteString .. "()"
	end
	o.Frame.InputField.InsertText(pasteString);
	FindBestFocus(o.Frame.InputField)
end

signalTable.TryToAddFileInfo = function(caller)
	local overlay = caller:GetOverlay()
	local plugin = overlay.Context
	local path = plugin.FullPath
	local valid = string.len(path) > 0 and FileExists(path)

	caller.Text = caller.Text ..   "\n\nSource: " .. plugin:Get("Source",Enums.Roles.Display)

	if valid then
		caller.Text = caller.Text .. "\nPath:   " .. path
	end
end

------------------------------------------------------------------------
-- Lua Template Content

LuaTemplates.Commandline =
[[
local function main()
	Printf("Print to Commandline History")
	Echo("Print to System Monitor")
	Cmd("Fixture Thru At 100")
end

return main
]]

LuaTemplates.Arguments =
[[
local function main(display, args)
	Printf("Called from "..display:ToAddr())
	if args then
		Printf("Plugin called with argument "..args)
	end
end
return main
]]

LuaTemplates.ProgressBar =
[[
local function main()
	-- create the progress bar:
	local progHandle = StartProgress("myProgress")
	-- set start index and end index of the progress bar:
	local startIdx, endIdx = 1, 3

	-- define the range of the progress bar:
	SetProgressRange(progHandle, startIdx, endIdx)
	for i = startIdx, endIdx do
		-- set the progress state of the progress bar:
		SetProgress(progHandle, i)
		coroutine.yield(1)
	end

	-- remove the progress bar:
	StopProgress(progHandle)
end

return main
]]

LuaTemplates.UserFeedback = 
[[
local function main()
	local title = "This is the title"
	local message = "The message to be displayed."
	local input = TextInput(title,message)
	Printf("You entered this message: %s",tostring(input))

	if Confirm("Confirm me", "Tap OK") then
		Printf("OK")
	else
		Printf("Cancel.")
	end

	local descTable = {
		title = "Demo",
		caller = GetFocusDisplay(),
		items = {"Select","Some","Value","Please"},
		selectedValue = "Some",
		add_args = {FilterSupport="Yes"},
	}
	local a,b = PopupInput(descTable)
	Printf("a = %s",tostring(a))
	Printf("b = %s",tostring(b))

end

return main
]]

LuaTemplates.MessageBox = 
[[
local function main()
	-- create inputs:
	local states = {
		{name = "State A", state = true, group = 1},
		{name = "State B", state = false, group = 1},
		{name = "State C", state = true, group = 2},
		{name = "State D", state = false, group = 2}
	}
	local inputs = {
		{name = "Numbers Only", value = "1234", whiteFilter = "0123456789"},
		{name = "Text Only", value = "TextOnly", blackFilter = "0123456789"},
		{name = "Maximum 10 characters", value = "abcdef", maxTextLength = 10}
	}
	local selectors = {
		{ name="Swipe Selector", selectedValue=2, values={["Test"]=1,["Test2"]=2}, type=0},
		{ name="Radio Selector", selectedValue=2, values={["Test"]=1,["Test2"]=2}, type=1}
	}

	-- open messagebox:
	local resultTable =
		MessageBox(
		{
			title = "Messagebox example",
			message = "This is a message",
			message_align_h = Enums.AlignmentH.Left,
			message_align_v = Enums.AlignmentV.Top,
			commands = {{value = 1, name = "Ok"}, {value = 0, name = "Cancel"}},
			states = states,
			inputs = inputs,
			selectors = selectors,
			backColor = "Global.Default",
			-- timeout = 10000, --milliseconds
			-- timeoutResultCancel = false,
			icon = "logo_small",
			titleTextColor = "Global.AlertText",
			messageTextColor = "Global.Text",
			autoCloseOnInput = true
		}
	)

	-- print results:
	Printf("Success = "..tostring(resultTable.success))
	Printf("Result = "..resultTable.result)
	for k,v in pairs(resultTable.inputs) do
		Printf("Input '%s' = '%s'",k,v)
	end
	for k,v in pairs(resultTable.states) do
		Printf("State '%s' = '%s'",k,tostring(v))
	end
	for k,v in pairs(resultTable.selectors) do
		Printf("Selector '%s' = '%d'",k,v)
	end
end

return main
]]