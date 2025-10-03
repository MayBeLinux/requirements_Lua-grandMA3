local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OpenAttributePreferences = function(caller,status,creator)
	local overlay = caller:GetOverlay();
    local grid = overlay.Content.UserProfilesGrid;
	local sel = grid:GridGetSelection();
    local list = sel.SelectedItems;

	local object = IntToHandle(list[1].row);
	if object then
		local attributes = object.UserAttributePreferences
		if attributes then
			local addr=ToAddr(attributes);
			CmdIndirect("Edit ".. addr, caller:GetDisplay());
		end
	end
end

signalTable.ImportUP = function(caller,status,creator)
	local overlay = caller:GetOverlay();
    local grid = overlay.Content.UserProfilesGrid;
	local sel = grid:GridGetSelection();
    local list = sel.SelectedItems;

	if #list > 0 then
		local object = IntToHandle(list[1].row);
		if object then
			local users = object.Users;
			if #users > 0 then
				local title = "Import into a used user profile"
				local usersStr = ""
				for i=1,#users,1 do
					if i > 1 then usersStr = usersStr .. ", " end
					usersStr = usersStr .. users[i].Name
				end
				local msg = "This user profile is used by users ("..usersStr..").\nAre you sure want to overwrite this user profile?\nThis will close all open menus for these users."
				if Confirm(title, msg) ~= true then
					return;
				end
			end
		end
	end
	caller.DefaultClickAction()
end