local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetTimecodeObject(overlay)
	local p = overlay:Parent();
	local ov = p:GetOverlay();
	local grid = nil;

	if (ov and ov:IsClass("TimecodeEditor")) then
		grid = ov.Content.Timecode;
	else
		local w = overlay:FindParent("TimecodeWindow");
		if (w) then
			grid = w.Frame.Content.Timecode;
		end
	end

	if (grid) then
		local s = grid:GridGetSettings();
		return s.CurrentTimecode;
	else
		return overlay.EditTarget;
	end

	return nil;
end

signalTable.TimecodeSettingsOverlayLoaded = function(caller,dummy)
	local dlgs = caller.Frame.SettingsScrollContainer.SettingsScrolBox;
	local curTC = GetTimecodeObject(caller);

	caller.TitleBar.Title.Text = curTC:Get("Name", Enums.Roles.Display) .. " settings";
	dlgs.PropertyButtons.target=curTC;
end

signalTable.SaveToDefault = function(caller,dummy)
	local ov = caller:GetOverlay();
	local curTC = GetTimecodeObject(ov);
	if IsObjectValid(curTC) then
		curTC.SaveToDefault(CmdObj());
	end
end

signalTable.LoadFromDefault = function(caller,dummy)
	local ov = caller:GetOverlay();
	local curTC = GetTimecodeObject(ov);
	if IsObjectValid(curTC) then
		curTC.LoadFromDefault(CmdObj());
	end
end
