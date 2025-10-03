local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function add_to_table(dest, src)
	local n = #dest;
	for i,v in ipairs(src) do
		dest[n + i] = v;
	end
end

signalTable.FixtureEditorLoaded = function(caller)
	caller:WaitInit();
	local user_profile=CurrentProfile();
	local temp_settings=user_profile.TemporaryWindowSettings;
	local fixture_editor_settings=temp_settings.FixtureEditorSettings;
	caller.TitleBar.TitleButtons.ColumnsFilters.Target = fixture_editor_settings:Ptr(1);
end

signalTable.SetSplitterSettings = function(caller)
	local settings = CurrentProfile().TemporaryWindowSettings.FixtureEditorSettings;
	caller.Target = settings;
end

signalTable.OnRowSelected = function(caller,status,row_id)
  local ui_parent=caller:Parent();
  local selection = caller:GridGetSelection();
  local items = selection.SelectedItems;
  local selectedFixtures = {};
  for i,v in ipairs(items) do
	  local object = IntToHandle(v.row);
	  if object and object:IsClass("Subfixture") then
		object=object.Fixture;
	  elseif (object and object:IsClass("Fixture") ~= true) then
		 Echo("cannot add object of type: "..object:GetClass());
	  end

	  if object ~= nil then
		  selectedFixtures[object] = true;
	  end
  end

  local selectedChannels = {}

  for k, v in pairs(selectedFixtures) do
	add_to_table(selectedChannels, GetRTChannels(k, true));
  end

  local rt_channels_grid=ui_parent.RTChannelsGrid;
  rt_channels_grid.TargetObjects=selectedChannels;
  local so = rt_channels_grid.GetSortOrder();
  if (so == Enums.GridSortOrder.None) then
    rt_channels_grid.SortByColumnName("Coarse", Enums.GridSortOrder.Asc);
  end
end

