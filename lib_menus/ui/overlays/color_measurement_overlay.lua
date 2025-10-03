local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local kIllegalIndex = 4294967295;

signalTable.OnLoaded = function(caller, signal)
	local overlay = caller:GetOverlay();
	Echo("OnLoadCalled with State: " .. tostring(overlay.CalibrationStep));
	Echo(overlay.Name);
	caller.Content.Feedback.MeasurementStatus.Target = overlay;

    
end

signalTable.SelectFixture = function(caller)
	local overlay = caller:GetOverlay();
	local fid_string = TextInput("Select Fixture ID","1");
    overlay.FixtureToMeasure = fid_string;
end



signalTable.StartMeasuring = function(caller)
	local overlay = caller:GetOverlay();
	Echo("Fixture not existent");
	if(overlay.MeasurementStatus == "No Device Found") then
		msg = "No Measuring Device found"	
		MessageBox(
				{title="Measurement Failure",
				message=msg,
				message_align_h=Enums.AlignmentH.Left,
				display = di,
				commands={{value=1, name="Ok"}}
			});
	else
		local ret = overlay:MeasureColor();
	end
end

signalTable.DarkCalibration = function(caller)
	local overlay = caller:GetOverlay();
	Echo("DarkCalibrate");
	if(overlay.MeasurementStatus == "No Device Found") then
		msg = "No Measuring Device found"	
		MessageBox(
				{title="Dark Calibration Failure",
				message=msg,
				message_align_h=Enums.AlignmentH.Left,
				display = di,
				commands={{value=1, name="Ok"}}
			});
	else
		local ret = overlay:DarkCalibrate();
	end
end
