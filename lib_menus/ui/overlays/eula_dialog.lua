local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.EulaDialogLoaded = function(caller,status,creator)
	local path = GetPath(Enums.PathType.Resource);
	local lFile = io.open(path.."/license.txt", "r");
	local license = "File with license not found at:"..path.."/license.txt";
	if (lFile ~= nil) then
		license = lFile:read("*a");
	end
	caller.EulaEdit.Content = license;
	caller.EulaEdit.ReadOnly = true;
	caller.EulaEdit.BackColor="Global.BackGround";
	caller.EulaEdit.TextColor="Global.Text";	
end

signalTable.ActivateAgreeBtn = function(caller,dummy)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local agreeBtn = overlay:FindRecursive("AgreeBtn", "Button");
		if (agreeBtn) then agreeBtn.Enabled = true; end
	end
end