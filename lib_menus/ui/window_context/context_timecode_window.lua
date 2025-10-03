local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnTargetObjectChanged = function(caller,status,newTarget)
	local temporary = newTarget:Parent():IsClass("TemporaryWindowSettings")
	local tcTargetVisible = not ((IsObjectValid(newTarget) == true) and temporary);
	caller.Frame.Dialogs.Display.TimecodeTarget.Visible = tcTargetVisible;

	if temporary then
		caller.TitleBar.EditTitlebarButton.Visible = false
		caller.TitleBar.TitleButton.Anchors="0,0,1,0"
	end
end

signalTable.OnTabLoad = function(caller,status,creator)
	if (ReleaseType() == "Alpha") then
		caller:AddListStringItem("Raw Settings", "RawSettings");
		caller:Changed();
	end 
end

