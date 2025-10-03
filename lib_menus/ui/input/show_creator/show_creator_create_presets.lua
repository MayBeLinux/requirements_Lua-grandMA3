local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local overlay = nil;
-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.OnCustomMenuLoaded = function(caller)
    overlay = caller;
    overlay.Content.GenerateColorArea.Frame.ColorBookArea.WindowColorPickerBook.Gels:SelectAllRows();
end

signalTable.AdjustVisibilityAndSize = function()
    local settings = overlay.Settings;
     if(overlay.Content) then
        signalTable.OnLocalGridLoaded(overlay.Content.LocalArea.Frame.LocalGrid);
        if(overlay.Content.SubPoolSelector.Target and overlay.Content.SubPoolSelector.Target[settings.SubPoolSelectorValue+1]) then
            local name = overlay.Content.SubPoolSelector.Target[settings.SubPoolSelectorValue+1].Name;
            overlay.TitleBar.Title.Text = "Create " .. "Presets" .. "." .. name;
            if (name == "Dimmer") then
                overlay.Content.GenerateDimmerArea.Visible = true;
                overlay.Content.GenerateColorArea.Visible = false;
                overlay.FunctionButtons.ButtonsRight.CreateDim.Enabled = true;
                overlay.FunctionButtons.ButtonsRight.CreateColor.Enabled = false;
            elseif (name == "Color") then
                overlay.Content.GenerateDimmerArea.Visible = false;
                overlay.Content.GenerateColorArea.Visible = true;
                overlay.FunctionButtons.ButtonsRight.CreateDim.Enabled = false;
                overlay.FunctionButtons.ButtonsRight.CreateColor.Enabled = true;
                if(settings.UseColorBook) then
                    overlay.Content.GenerateColorArea.Frame.ColorBookArea.Visible = true;
                    overlay.Content.GenerateColorArea.Frame.Hue.Visible           = false;
                    overlay.Content.GenerateColorArea.Frame.Saturation.Visible    = false;
                    overlay.Content.GenerateColorArea.Frame.Sort.Visible          = false;
                else
                    overlay.Content.GenerateColorArea.Frame.ColorBookArea.Visible = false;
                    overlay.Content.GenerateColorArea.Frame.Hue.Visible           = true;
                    overlay.Content.GenerateColorArea.Frame.Saturation.Visible    = true;
                    overlay.Content.GenerateColorArea.Frame.Sort.Visible          = true;
                end
            else
                overlay.Content.GenerateDimmerArea.Visible = false;
                overlay.Content.GenerateColorArea.Visible = false;   
                overlay.FunctionButtons.ButtonsRight.CreateDim.Enabled = false;
                overlay.FunctionButtons.ButtonsRight.CreateColor.Enabled = false;
            end
        end
    end
end

signalTable.OnFixtureSelected = function()
end

signalTable.CreateDim = function()
    local settings = overlay.Settings;
    local UserProfile=CurrentProfile();
    local collection = UserProfile.Collection.IndexesSorted;
    local cmd = '';
    if(collection[1] ~= nil) then
        cmd = 'AutoCreate Universal 1 at Collection "DimmerIncrement" ' .. tostring(settings.DimmerIncrement); 
    else
        local idx = settings.SubPoolSelectorValue+1;
        cmd = 'AutoCreate Universal 1 at Preset '.. idx ..'.* "DimmerIncrement" ' .. tostring(settings.DimmerIncrement);
    end
    
    CmdIndirect(cmd);
end

signalTable.CreateCol = function()  
    local settings = overlay.Settings;
    local sortColor = "Hue";
    if(settings.SortColorBySaturation) then
        sortColor= "Saturation";
    end
    local cmd = 'AutoCreate Universal 1 ';
    local UserProfile=CurrentProfile();
    local collection = UserProfile.Collection.IndexesSorted;
    if(collection[1] ~= nil) then
        cmd = cmd .. 'at Collection ';
    else
        local idx = settings.SubPoolSelectorValue+1;
        cmd = cmd .. 'at Preset '.. idx ..'.* ';
    end
    
    if(settings.UseColorBook) then
        local cmdO = CmdObj();
        local gr = overlay.Content.GenerateColorArea.Frame.ColorBookArea.WindowColorPickerBook.Gels;

        local grSel = gr:GridGetSelection();
        local selectedItems = grSel.SelectedItems;

        cmd = cmd .. '"GelList" '
        for idx,item in ipairs(selectedItems) do
            if(idx > 1) then
                cmd = cmd .. " + ";
            end
            local gel = IntToHandle(item.row);
            cmd = cmd .. ToAddr(gel)
        end
    else
        cmd = cmd .. '"AmountHue" ' .. tostring(settings.AmountHue) .. ' "AmountSaturation" ' .. tostring(settings.AmountSaturation)  .. ' "SortColor" ' .. tostring(sortColor); 
    end

    CmdIndirect(cmd);
end

signalTable.CreateCommand = function(collection, dimmerPool, startIdx, poolIdx)
    local storeCmd = "store "
    if(collection[startIdx] ~= nil) then
        poolIdx = collection[startIdx];
        storeCmd = storeCmd .. ToAddr(dimmerPool) .. "." .. collection[startIdx];
    else
        poolIdx = signalTable.FindFreePoolEntry(dimmerPool, poolIdx);
        storeCmd = storeCmd .. ToAddr(dimmerPool) .. "." .. poolIdx;
    end
    poolIdx = poolIdx + 1;

    return storeCmd, poolIdx;
end

signalTable.FindFreePoolEntry = function(Pool, startIdx)
    if(startIdx == nil) then
        startIdx = 1;
    end
    for i=startIdx,#Pool do
        if (Pool[i] == nil) then
            return i;
        end
    end
    return startIdx;
end

-- --------------------------------------------------------
--  Color Book Content
-- --------------------------------------------------------

signalTable.BookOnLoad = function(caller,status,creator)
    if(caller.name ~= nil) then
        local gel = Root().ShowData.GelPools:Ptr(1);
        caller.Gels.TargetObject = gel;
        local settings = caller.Gels.GelGridSettings;
        caller.Buttons.GridTypeSelector.Target = settings;
        caller.Buttons.SortTypeSelector.Target = settings;

        caller.Gels.SelectionType = "MultiRowGridSelection"
    end
end

signalTable.OnPoolSelected = function(caller,status,col_id,row_id)
    local gelPool=IntToHandle(row_id);
    local gelGrid = caller:Parent().Gels
    gelGrid.TargetObject = gelPool;
    gelGrid:SelectAllRows();
end

signalTable.OnGelSelected = function(caller,status,col_id,row_id)
-- Nothing for now
end