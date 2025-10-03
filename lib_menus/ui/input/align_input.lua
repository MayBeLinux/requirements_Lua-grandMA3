local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local activateOnSelected = false;

local function splitCombined(value)
    local splittedValues = string.split(value,";");
    local mode       = splittedValues[1];
    local transition = splittedValues[2];
    local math       = splittedValues[3];
    return mode, transition, math;
end

local function mergeCombined(mode, transition, math)
    return mode .. ';' .. transition .. ';' .. math;
end

local function setValueFromSelected(overlay)
    local modeIdx       = overlay.Frame.ModeList:GetListSelectedItemIndex()
    local transitionIdx = overlay.Title.TransitionBtn:GetListSelectedItemIndex()
    local mathIdx       = overlay.Title.MathBtn:GetListSelectedItemIndex()

    local modeName       = overlay.Frame.ModeList:GetListItemName(modeIdx)
    local transitionName = overlay.Title.TransitionBtn:GetListItemName(transitionIdx)
    local mathName       = overlay.Title.MathBtn:GetListItemName(mathIdx)

    overlay.value = mergeCombined(modeName,transitionName,mathName);
end

local function clearAndAddEnumsToList(list,enums)
    list:ClearList();

    local numericalSorted = {};
    for name, idx in pairs(enums) do
        numericalSorted[idx] = name;
    end
    for i = 0, #numericalSorted do -- start from 0 (enum numbers)
	    list:AddListStringItem(numericalSorted[i],"");
    end
end

signalTable.OnLoaded = function(caller,status,creator)
    activateOnSelected = false;

    clearAndAddEnumsToList(caller.Frame.ModeList,       Enums.AlignMode);
    clearAndAddEnumsToList(caller.Title.TransitionBtn,  Enums.TransitionMode);
    clearAndAddEnumsToList(caller.Title.MathBtn,        Enums.AlignMath);

    -- select current values
    local alignCombinedVal = caller.Value;
    local mode, transition, math = splitCombined(alignCombinedVal);
    caller.Frame.ModeList:SelectListItemByName(mode);
    caller.Title.TransitionBtn:SelectListItemByName(transition);
    caller.Title.MathBtn:SelectListItemByName(math);

    coroutine.yield(0.1); -- init objects, then activate onSelected
    activateOnSelected = true;
end

signalTable.OnSetTarget = function(caller,status,creator)
    if (activateOnSelected) then
        local o = caller:GetOverlay();
        setValueFromSelected(o); -- all 3 values
        -- Echo("AlignCombined: "..tostring(o.Value))
        o.Close();
    end
end

signalTable.OnChangedOption = function(caller,status,creator)
    if (activateOnSelected) then
        local o = caller:GetOverlay();
        setValueFromSelected(o);
    end
end

