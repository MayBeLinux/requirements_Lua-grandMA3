local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoad = function(window,status,creator)
	local UserProfile=CurrentProfile();
	HookObjectChange(signalTable.OnUserProfileChanged,UserProfile,my_handle:Parent(),window);
end

signalTable.SetRecipeSettings = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;
	caller.RecipeFilter:SetChildren("Target", settings:Ptr(1):Ptr(1));
	caller.Grid.ExternalSettings = settings;
end

signalTable.OnPartSelected = function(caller,status,row_id)
	local Environment=CurrentEnvironment();
    local Object = IntToHandle(row_id);
	if IsObjectValid(Object) then
		local class = Object:GetClass();
		if class == "Recipe" then
			Object=Object:Parent();
			class = Object:GetClass();
		end
		if class == "ProgPart" then
			if(Object~=Environment.ProgPart) then
				Environment.ProgPart=Object;
			end
		end
	end
end

signalTable.OnUserProfileChanged= function(UserProfile, change, window)
	if window then
	    local Frame=window.Frame;
		if Frame then
		    local Grid=Frame.Grid;
			if Grid then
				local ProgrammerPart=ProgrammerPart();
				Grid.SelectCell('',HandleToInt(ProgrammerPart), GetPropertyColumnId("ProgPart", "Name"));
				-- Echo("OnUserProfileChanged ".. tostring(window) .. "  " .. tostring(ProgrammerPart) );
			end
		end
	end
end

signalTable.OnAdd = function(caller)
	local grid = caller:Parent():Parent().Grid
	local selRow = grid.SelectedRow;
	local selObj = IntToHandle(selRow)
	if IsObjectValid(selObj) and selObj:GetClass() == "ProgPart" then
		Cmd("Store Programmer");
	else
		CmdIndirect("Insert UIGridSelection")
	end
end

signalTable.OnDel = function(caller)
	CmdIndirect("Delete UIGridSelection")
end