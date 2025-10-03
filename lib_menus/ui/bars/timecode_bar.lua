local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local tcGrid = nil;

signalTable.BarLoaded = function(bar,status,window)

	local grid  = nil;
	if (window:IsClass("TimecodeWindow")) then
		grid = window.Frame.Content.Timecode;-- case for TimecodeWindow
	else
		grid = window.Content.Timecode;-- case for TimecodeEditor
	end

	tcGrid = grid;
	bar.Grid = grid;

    local InnerBox=bar.InnerBox;
	InnerBox.Pages.Target=bar;
	local Upper   =InnerBox.Upper;
	local Lower   =InnerBox.Lower;

	Lower:SetChildren("Target",grid);

	signalTable.EncoderPageChanged(bar);
end

signalTable.TCBackward = function() if (tcGrid) then tcGrid.TimecodeBackward(); end; end;
signalTable.TCForward = function() if (tcGrid) then tcGrid.TimecodeForward(); end; end;
signalTable.TCRecord = function() if (tcGrid) then tcGrid.TimecodeRecord(); end; end;
signalTable.TCStop = function() if (tcGrid) then tcGrid.TimecodeStop(); end; end;
signalTable.TCPause = function() if (tcGrid) then tcGrid.TimecodePause(); end; end;
signalTable.TCPlay = function() if (tcGrid) then tcGrid.TimecodePlay(); end; end;
signalTable.TCPrevMarker = function() if (tcGrid) then tcGrid.TimecodePrevMarker(); end; end;
signalTable.TCNextMarker = function() if (tcGrid) then tcGrid.TimecodeNextMarker(); end; end;

local EncoderNames=
{
	"Encoder1a","Encoder1b",
	"Encoder2a","Encoder2b",
	"Encoder3a","Encoder3b",
	"Encoder4a","Encoder4b",
	"Encoder5a","Encoder5b",
};

local EncoderSystems=
{
	Edit=
	{
	--   Inner          Outer
 		"Cursor", "Marker"   , --EncoderBlock 1
 		"Track" , "TimeRange", --EncoderBlock 2
 		"Event" , nil        , --EncoderBlock 3
 		"Start" , "Duration" , --EncoderBlock 4
 		nil     , nil        , --EncoderBlock 5
	};
};

signalTable.EncoderPageChanged = function(caller)
	local bar = caller:FindParent("TimecodeBar");
	local InnerBox=bar.InnerBox;
	local Lower   =InnerBox.Lower;

	local SystemName=bar.EncoderFunction;
	local System    =EncoderSystems[SystemName];
	for i=1,10 do
	   local EncoderName= EncoderNames[i];
	   local Encoder    = Lower[EncoderName];
	   local PropName   = System[i];
	   if(PropName) then
		   Encoder.System  =SystemName;
		   Encoder.Property=PropName;
		   Encoder.Visible=true;
		   if ((i-1) % 2) == 0 then
			   local col = math.floor((i - 1) / 2);
		       if System[i + 1] == nil then
				Encoder.EncoderRing = "Both";
				local ancs = col..",0,"..col..",1";
				Encoder.Anchors = ancs;
			   else
				Encoder.EncoderRing = "Inner";
				Encoder.Anchors = col..",0";
			   end
		   end
		else
			Encoder.Visible=false;
		end
	end
end
