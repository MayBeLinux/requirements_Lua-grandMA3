local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

-- Function to compare two version strings
local function compareVersions(version1, version2)
    local function split(str)
        local t = {}
        for num in str:gmatch("%d+") do
            table.insert(t, tonumber(num))
        end
        return t
    end

    local version1_parts = split(version1)
    local version2_parts = split(version2)

    for i = 1, 4 do
        if (version1_parts[i] or 0) < (version2_parts[i] or 0) then
            return -1 -- version1 is less than version2
        elseif (version1_parts[i] or 0) > (version2_parts[i] or 0) then
            return 1 -- version1 is greater than version2
        end
    end

    return 0 -- version1 is equal to version2
end

signalTable.DoUpdate = function(caller)
    local overlay = caller:GetOverlay();
    local grid = overlay.Content.Dialogs.UpdatePage.ManetStationGrid;
    local sel = grid:GridGetSelection();
    local list = sel.SelectedItems;

    local socket=Root().ManetSocket;
    local selectedUpdateFile=socket.selectedUpdateFile;
    if (selectedUpdateFile=="") then
        signalTable.DoSelectUpdateFile(caller);
    end

    local selectedVersion = string.match(selectedUpdateFile, "[%a_]+(%d+%.%d+%.%d+%.%d+)")
    local nameslist=""
    for i, cell in ipairs(list) do
        local rowId = cell.row;
        local columnId = cell.column;

        local obj = IntToHandle(rowId);
        if (obj:GetClass() == "NetworkStation") then
            if (obj.MinimumVersion ~= nil) and (compareVersions(selectedVersion, obj.MinimumVersion) == -1) then
                MessageBox({title = "Incompatible Hardware", message = "The selected grandMA3 software package is not compatible\nwith the hardware of the device \"" .. obj.Name .. "\" (IP " .. obj.IP .. ").\n\nPlease use software version " .. obj.MinimumVersion .. " or later.\n\nDownload the latest grandMA3 software package on www.malighting.com.", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
            else
                nameslist = nameslist .. " " .. obj.Name;
            end
        end
    end

    if (nameslist ~= "") then
        Echo("Sending version " .. selectedUpdateFile .. " to " .. nameslist);
        local cmdstring = "SoftwareUpdate UIGridSelection \"" .. selectedUpdateFile .. "\"";
        CmdIndirect(cmdstring);
    else
        Echo("No targets to update. Please select target(s)");
        MessageBox({title = "No selected targets", message = "Please select target(s) to update", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
    end
end

signalTable.DoCancelSoftwareUpdate = function(caller)
    local cmdstring = "CancelSoftwareUpdate";
    local ret = Cmd(cmdstring);
    if ret == "OK" then
        MessageBox({title = "Warning: the update process is canceled", message = "If more than one device was part of the update process in the network,\nthis cancellation may result that some devices are updated\nand other are not updated.\n\nPlease verify the software version of the devices.", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
    end
end

signalTable.DoSelectUpdateFile = function(caller)
    local o = caller:GetOverlay();

    local socket=Root().ManetSocket;
    local selectedUpdateFile=socket.selectedUpdateFile;

    local updateSelector = Root().Menus.SelectUpdate;
    if (updateSelector) then
        local updateSelectorUI = updateSelector:CommandCall(caller,false);
        if (updateSelectorUI) then
            result = updateSelectorUI:InputRun();
            if (result) then
                selectedUpdateFile = result.Value;
                socket.selectedUpdateFile=selectedUpdateFile;

                local eulaAccepted = true;
                local builddetails = BuildDetails();
                if (builddetails["CodeType"] ~= "Debug") then
                    eulaAccepted = signalTable.DoAcceptEula(caller)
                end

                if eulaAccepted then
                    if (selectedUpdateFile:split(";")[2] == GetPath("installation_packages")) then
                        o.TitleBar.TitleBarText.Text = "Selected update " .. selectedUpdateFile:split(";")[1] .. " from internal drive";
                    else
                        o.TitleBar.TitleBarText.Text = "Importing update " .. selectedUpdateFile:split(";")[1] .. " from external drive";

                        coroutine.yield({ui=2}); -- without this we have EULA in one of two framebuffers

                        CmdIndirect("SoftwareImport \"" .. selectedUpdateFile .. "\"");

                        local p = GetPath("installation_packages");
                        local f = selectedUpdateFile:split(";")[1];
                        Echo("Selected update version " .. f .. " from drive " .. p);
                        selectedUpdateFile = f..";"..p;
                        socket.selectedUpdateFile=selectedUpdateFile;
                    end
                else
                    MessageBox({title = "Not agreed", message = "Update file not selected.", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
                end
            end
            updateSelectorUI:Parent():Remove(updateSelectorUI:Index());
            coroutine.yield();
        end
    end
    if (selectedUpdateFile ~= "") then
        o.FunctionButtons.Right.UpdateBtn.enabled = true;
        o.FunctionButtons.Right.CancelBtn.enabled = true;
    end
end

signalTable.DoDeleteUpdateFiles = function(caller)
    local updateSelector = Root().Menus.SelectUpdate;
    if (updateSelector) then
        local updateSelectorUI = updateSelector:CommandCall(caller,false);
        if (updateSelectorUI) then
            result = updateSelectorUI:InputRun();
            if (result) then
                local pkgForRemove = result.Value;
                local res = MessageBox({
                    title="Delete packets",
                    message="You are about to delete update packets from " .. pkgForRemove:split(";")[1] .. "\nDo you want to continue ?",
                    commands={{value=1, name="Yes"}, {value=2, name="No"}},
                });
                if res.success then
                    if res.result == 1 then
                        local cmdstring = "DeleteOtherVersion \"" .. pkgForRemove .. "\"";
                        CmdIndirect(cmdstring);
                    end
                end
            end
            updateSelectorUI:Parent():Remove(updateSelectorUI:Index());
            coroutine.yield();
        end
    end
end

signalTable.OnEULAPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.EulaDialog:CommandCall(overlay.Content);
    end
end

signalTable.OnTrademarksPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.TrademarksDialog:CommandCall(overlay.Content);
    end
end

signalTable.OnPrivacyPolicyPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.PrivacyPolicyDialog:CommandCall(overlay.Content);
    end
end

signalTable.OnCreditPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.CreditDialog:CommandCall(overlay.Content);
    end
end

signalTable.OnReleaseNotesPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.ReleaseNotesDialog:CommandCall(overlay.Content);
    end
end

signalTable.OnBetaReleaseNotesPageVisible = function(caller,status,visible)
    if (visible) then
        local overlay = caller:GetOverlay();
        local plugin     =my_handle:Parent();
        local plugin_pool=plugin:Parent();
        plugin_pool.BetaReleaseNotesDialog:CommandCall(overlay.Content);
    end
end

signalTable.SoftwareUpdateLoaded = function(caller, str)
    local o = caller:GetOverlay();
    local socket=Root().ManetSocket;
    local selectedUpdateFile=socket.selectedUpdateFile;
    if (selectedUpdateFile ~= "") then
        if (selectedUpdateFile:split(";")[2] == GetPath("installation_packages")) then
            o.TitleBar.TitleBarText.Text = "Selected update " .. selectedUpdateFile:split(";")[1] .. " from internal drive";
        else
            o.TitleBar.TitleBarText.Text = "Selected update " .. selectedUpdateFile:split(";")[1] .. " from external drive";
        end

        o.FunctionButtons.Right.UpdateBtn.enabled = true;
        o.FunctionButtons.Right.CancelBtn.enabled = true;
    end

    if (ReleaseType() == "Alpha") then
        caller.MainMenu.PagesTab:SetListItemName(3, "Alpha\nNews");        
	end
end

signalTable.StationGridLoaded = function(caller)
	caller:WaitInit(2);
	local so = caller.GetSortOrder();
	if (so == Enums.GridSortOrder.None) then
		caller.SortByColumnName("IP", Enums.GridSortOrder.Asc);
	end
end

signalTable.DoAcceptEula = function(caller)
    local eulaUpdate = Root().Menus.EulaUpdate;
    if (eulaUpdate) then
        local thirdPartySelectorUI = eulaUpdate:CommandCall(caller,false);
        if (thirdPartySelectorUI) then
            result = thirdPartySelectorUI:InputRun();
            if (result) then
                selected3rdParty = result.Value;
                if (selected3rdParty ~= "0") then
                    thirdPartySelectorUI:Parent():Remove(thirdPartySelectorUI:Index());
                    coroutine.yield();
                    return true;
                end
            end
            thirdPartySelectorUI:Parent():Remove(thirdPartySelectorUI:Index());
            coroutine.yield();
        end
    end
    -- MessageBox({title = "Not agreed", message = "Nothing to do...", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
    return false;
end

signalTable.PageChanged = function( caller,status,creator )
    local overlay = caller:GetOverlay();
    local onTabUpdate   = (caller.SelectedItemValueStr == "UpdatePage");
    local onTabEula     = (caller.SelectedItemValueStr == "EULAPage");
    local onTabPP       = (caller.SelectedItemValueStr == "PrivacyPolicyPage");
    local onTabTM       = (caller.SelectedItemValueStr == "TrademarksPage");

    overlay.FunctionButtons.Left.EmptyFirst.visible = onTabUpdate;
    overlay.FunctionButtons.Left.EmptyLast.visible = onTabUpdate;
    overlay.FunctionButtons.Left.DeleteBtn.visible = onTabUpdate;
    overlay.FunctionButtons.Right.EmptyFirst.visible = onTabUpdate;
    overlay.FunctionButtons.Right.SelectBtn.visible = onTabUpdate;
    overlay.FunctionButtons.Right.UpdateBtn.visible = onTabUpdate;
    overlay.FunctionButtons.Right.CancelBtn.visible  = onTabUpdate;

    overlay.FunctionButtons.Left.EmptyEula.visible  = onTabEula;
    overlay.FunctionButtons.Right.ThirdpartyBtn.visible  = onTabEula;
    overlay.FunctionButtons.Right.EmptyEula.visible  = onTabEula;


    overlay.FunctionButtons.Left.EmptyTrademarks.visible  = onTabTM;
    overlay.FunctionButtons.Right.EmptyTrademarks.visible  = onTabTM;

    overlay.FunctionButtons.Left.EmptyPrivacyPolicy.visible  = onTabPP;
    overlay.FunctionButtons.Right.UserName.visible  = onTabPP;
    overlay.FunctionButtons.Right.PrivacyPolicyAgreeBtn.visible  = onTabPP;
    overlay.FunctionButtons.Right.EmptyPrivacyPolicy.visible  = onTabPP;

    overlay.FunctionButtons.Right.EmptyOther.visible = not onTabUpdate and not onTabEula and not onTabPP and not onTabTM;
    overlay.FunctionButtons.Left.EmptyOther.visible = not onTabUpdate and not onTabEula and not onTabPP and not onTabTM;

end

signalTable.SetUserName = function(caller,status,creator)
	if caller["IsValid"] and caller:IsValid() then
        caller.Text = "User:\n".. CurrentUser().Name;
	end
end

signalTable.SetPrivacyPolicyAgreeBtnTarget = function(caller,status,creator)
	local cu = CurrentUser();
    if caller["IsValid"] and caller:IsValid() then
        caller.Target = cu;
    end
end


