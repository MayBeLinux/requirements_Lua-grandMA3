local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnUpdateTitle = function(caller,status,creator)
	local object = caller.EditTarget;
	caller.TitleBar.Title.Text = "Edit Generator " ..object.name;
end


signalTable.OnSetEditTarget = function(caller,dummy,target)

	local Frame=caller.Frame;
	local Top =Frame.Top;
	local Bottom=Frame.Bottom;
	local Buttons=caller.Buttons;

	Top:SetChildren("TargetObject",target.RandomChannels);
	Bottom.SpeedGroup:SetChildrenRecursive("Target", target);
	Bottom.PhaseGroup:SetChildren("Target",target);
	Bottom.LowGroup:SetChildren("Target",target);
	Bottom.HighGroup:SetChildren("Target",target);
	Bottom.AtkGroup:SetChildren("Target",target);
	Bottom.RatioGroup:SetChildren("Target",target);
	target.GridSelection=Top.EditorGrid:GridGetSelection();

	signalTable.Bottom =Bottom;
	signalTable.Buttons=Buttons;
end

signalTable.OnRowSelected = function(caller,status,row_id)
	
	local Bottom  =signalTable.Bottom;
	local Buttons=signalTable.Buttons
	local target = IntToHandle(row_id);
	if IsObjectValid(target) then
		Bottom.SpeedGroup:SetChildren("Enabled","true");
		Bottom.PhaseGroup:SetChildren("Enabled","true");
		Bottom.LowGroup:SetChildren("Enabled","true");
		Bottom.HighGroup:SetChildren("Enabled","true");
		Bottom.AtkGroup:SetChildren("Enabled","true");
		Bottom.RatioGroup:SetChildren("Enabled","true");
	else
		Bottom.SpeedGroup:SetChildren("Enabled","false");
		Bottom.PhaseGroup:SetChildren("Enabled","false");
		Bottom.LowGroup:SetChildren("Enabled","false");
		Bottom.HighGroup:SetChildren("Enabled","false");
		Bottom.AtkGroup:SetChildren("Enabled","false");
		Bottom.RatioGroup:SetChildren("Enabled","false");
	end

	Bottom.Settings:SetChildren("Target",target);
	Buttons.Left:SetChildren("Target",target);
	Buttons.Right:SetChildren("Target",target);
end

signalTable.OnClickedAt = function(caller)
	local overlay = caller:GetOverlay()
	local generator = overlay.EditTarget
	Cmd("At %s",generator:ToAddr())
end