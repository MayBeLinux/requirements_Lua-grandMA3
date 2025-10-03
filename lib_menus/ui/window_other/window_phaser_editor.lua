local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetSettings(caller)
	local window = caller:FindParent("Window");
	if(window == nil) then -- Overlay
		return CurrentProfile().TemporaryWindowSettings.WindowPhaserEditorSettings;
	else -- Window
		return window.WindowSettings;
	end
end
-- ------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	local SettingsObj = GetSettings(window);

	HookObjectChange(signalTable.FunctionModeChange,  -- 1. function to call
					 window,						  -- 2. object to hook
					 my_handle:Parent(),			  -- 3. plugin object ( internally needed )
					 window);						  -- 4. user callback parameter 	

	HookObjectChange(signalTable.SettingsChanged,     -- 1. function to call
					 SettingsObj,      		  -- 2. object to hook
					 my_handle:Parent(),			  -- 3. plugin object ( internally needed )
					 window);						  -- 4. user callback parameter 	

	signalTable.SettingsChanged(SettingsObj, nil, window);
end

signalTable.OnLoadMainToolBar = function (caller,status,creator)
	self=signalTable;
	self.MainToolBar=caller;
end

signalTable.OnLoadMainFunctionBar = function (caller,status,creator)
	self=signalTable;
	self.MainFunctionBar=caller;
end

-- ------------------------------------------
signalTable.SetTarget = function(caller)
	caller.Target=GetSettings(caller);
end

local MainToolBarTable=
{
	MoveCanvas="WM_2D";
	AddAbsolute="WM_2D";
	AddRelative="WM_2D";
	ChangeSize="WM_2D";
	ChangeRotation="WM_2D";
};

local MainFunctionBarTable=
{
	MirrorX="WM_2D";
	MirrorY="WM_2D";
	Swap="WM_2D";
	Flip="WM_2D";
	Fit="WM_2D";
};

signalTable.FunctionModeChange = function(window)
	if window ~= nil and self ~= nil and self.FunctionMode ~= window.FunctionMode then
		self.FunctionMode=window.FunctionMode;

		Echo("Function Mode is " .. self.FunctionMode);

		signalTable.EnableChildren(self.MainToolBar,MainToolBarTable);
		signalTable.EnableChildren(self.MainFunctionBar,MainFunctionBarTable);

	end
end


signalTable.EnableChildren=function(parent,table)
	if  parent then
	    local fm=self.FunctionMode;
		for name,condition in pairs(table) do
			local child=parent[name];
			if child then
				child.Enabled=(fm==condition);
			end
		end
	end
end

signalTable.ToggleStepBar = function(caller)
	local settings = GetSettings(caller);
	caller.Visible = settings.StepBar;
end

signalTable.ToggleLayerBar = function(caller)
	local settings = GetSettings(caller);
	caller.Visible = settings.LayerBar;
end

-- -------------------------------------------------
-- Layer Sheet
-- -------------------------------------------------

signalTable.SettingsChanged=function(settings, dummy, window)		
	local center = window.PhaserLayoutGrid.Frame.Center;
	
	center.Step.PhaserStepGrid.Internals.GridBase.GridSettings.Transposed = settings.Transposed;
	center.Layer.PhaserSheet.Internals.GridBase.GridSettings.Transposed = settings.Transposed;
	center.Layer.PhaserSheetExpanded.Internals.GridBase.GridSettings.Transposed = settings.Transposed;

	if(settings.ShowEmptyLines) then
		center.Step.PhaserStepGrid.AllowFilterContent = false;
		center.Layer.PhaserSheet.AllowFilterContent = false;
		center.Layer.PhaserSheetExpanded.AllowFilterContent = false;
	else
		center.Step.PhaserStepGrid.AllowFilterContent = true;
		center.Layer.PhaserSheet.AllowFilterContent = true;
		center.Layer.PhaserSheetExpanded.AllowFilterContent = true;
	end
	signalTable.ToggleStepBar(window.PhaserLayoutGrid.Frame.StepBar);
	signalTable.ToggleLayerBar(window.PhaserLayoutGrid.Frame.LayerBar);
end
