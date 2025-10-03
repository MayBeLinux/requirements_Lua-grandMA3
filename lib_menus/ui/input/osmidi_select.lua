local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local IsMidiOut = "No"


signalTable.OnLoaded = function(caller,status,creator)
    local osmidi_select=caller;
	if osmidi_select.IsMidiOut then
	    IsMidiOut ="Yes";
	else
	    IsMidiOut ="No";
	end
    signalTable.BaseInput=caller;
end

signalTable.OnOSMidiGridLoaded = function(caller,status,creator)
     if IsMidiOut == "Yes" then
	    caller.TargetObject=Root().Temp.MidiOutDescriptions;
	 else
	    caller.TargetObject=Root().Temp.MidiInDescriptions;	 
	 end
end

signalTable.OnItemSelected = function(caller,status,row_id)  
  local ui_parent=caller:Parent();
  local selection = caller:GridGetSelection();
  local items = selection.SelectedItems;
  for i,v in ipairs(items) do
	  local object = IntToHandle(v.row);
	  if object and object:IsClass("MIDIDeviceDescription") then
		 signalTable.BaseInput.Value = object.Name;
		 signalTable.BaseInput.Close();
	  end
  end
end
