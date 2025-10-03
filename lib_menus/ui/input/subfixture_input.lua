local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local pVars = nil;
local lastSelectedStageIdx = 1;--by default first stage is ought to be selected

local function UpdateStages(s)
	local p = ShowData().LivePatch;
	s:ClearList();
	s:AddListChildren(p.Stages);
	local h = p.Stages:Ptr(lastSelectedStageIdx);
	if (IsObjectValid(h)) then
		s:SelectListItemByValue(HandleToStr(h));
		lastSelectedStageIdx = s:GetListSelectedItemIndex();
	else
		lastSelectedStageIdx = 1;
	end
	signalTable.StageSelected(s, nil, nil, lastSelectedStageIdx - 1);
end

signalTable.OnInputLoaded = function(caller,status,creator)
	local p = ShowData().LivePatch;
	local stages = p.Stages;

	pVars = PluginVars():Ptr(1);
	lastSelectedStageIdx = GetVar(pVars, "SelectedStage");
	local h = stages:Ptr(lastSelectedStageIdx);
	if (not IsObjectValid(h)) then
		lastSelectedStageIdx = 1;
		SetVar(pVars, "SelectedStage", lastSelectedStageIdx);
	end
	local stageBtn = caller.TitleBar.StageControl;
	UpdateStages(stageBtn);
end

signalTable.StageSelected = function(caller, dummy, handleInt, idx)
	local ov = caller:GetOverlay();
	local p = ShowData().LivePatch;

	lastSelectedStageIdx = idx + 1;

	local h = p.Stages:Ptr(lastSelectedStageIdx);
	if IsObjectValid(h) then
		ov.Frame.SubfixtureGrid.TargetObject = h.Fixtures;
	end

	SetVar(pVars, "SelectedStage", lastSelectedStageIdx);
end

signalTable.OnSelected = function(caller,status,col_id,row_id)
	local sf=IntToHandle(row_id);
	if(IsObjectValid(sf) and sf:IsClass("SubFixture")) then
		caller:GetOverlay().Value = HandleToStr(sf);
		caller:GetOverlay():Close();
	end
end

signalTable.ClearFixture = function(caller,status)
	caller:GetOverlay().Value = "";
	caller:GetOverlay():Close();
end