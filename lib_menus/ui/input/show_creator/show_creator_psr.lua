local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

function signalTable.TabChanged(caller,_,tab_id,tab_index, initial)
    local o = caller:GetOverlay()
    local selItem = caller.SelectedItemIdx;
    if not initial then
        if selItem == Enums.PsrTab.Show then
            o.SwitchMenu("PsrShowSelector")
        end
    end
end

function signalTable.OnLoad(caller)
    local topMainDialog = caller:FindParent("ShowCreatorFTPresetsMainDialog")
    local subTab = topMainDialog.InitialSubTab -- caller:Parent():Parent().InitialSubTab

    Echo("OnLoad "..subTab)
    if subTab and subTab ~= "" and not topMainDialog.CalledFromCmdline then
        -- forced initial tab
        if subTab == "Show" then
            caller.SwitchMenu("PsrShowSelector")
            caller.PsrMenu.SubTabs:SelectListItemByIndex(1)
        elseif subTab == "Patch" then
            caller.SwitchMenu("PsrPatch")
            caller.PsrMenu.SubTabs:SelectListItemByIndex(2)
        elseif subTab == "Import" then
            caller.SwitchMenu("PsrImport")
            caller.PsrMenu.SubTabs:SelectListItemByIndex(3)
        end
        topMainDialog.InitialSubTab = "" -- consumed
    else
        -- showcreator opened directly
        local status = Root().Temp.ConvertTask.Status
        Echo("Status "..status)
        if status == Enums.PsrOperation.Closed then
            caller.SwitchMenu("PsrShowSelector")
        elseif status <= Enums.PsrOperation.Conversion then
            Root().Temp.ConvertTask:OnRunPreparation();
        else
            Root().Temp.ConvertTask:OnOpenImport();
        end
    end
end