local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
 	--Echo("TimezoneInput:OnLoaded");
    signalTable.BaseInput=caller;
end

signalTable.JumpToGrid = function(caller)
	FindNextFocus();
 	--Echo("TimezoneInput:JumpToGrid");

end

-- ---------------------- TIMEZONEGRID GRID ----------------------------
signalTable.OnTimezoneGridLoaded = function(caller,status,creator)
	 caller.TargetObject=Root().Temp.Timezones;
end

signalTable.OnItemSelected = function(caller,status,row_id)  
  local ui_parent=caller:Parent();
  local selection = caller:GridGetSelection();
  local items = selection.SelectedItems;
  for i,v in ipairs(items) do
	  local object = IntToHandle(v.row);
	  if object and object:IsClass("Timezone") then
		 Echo("Select time zone: "..object.Name);
		 signalTable.BaseInput.Value = object.Name;
		 signalTable.BaseInput.Close();
	  end
  end
end
