local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function indexOf(tbl, value)
    for k, v in pairs(tbl) do
        if k == value then
            return v
        end
    end
    return nil
end

local function keyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

local function GetPrettyMessageName(signal)
    local prettyName;
    local parts = {};
    for value in string.gmatch(signal, '([^.*]+)') do
        parts[#parts + 1] = value;
    end

    local category = parts[1];
    local priority = parts[2];

    if (category and priority) then
        -- Get pretty category name
        local catIndex = indexOf(Enums.MessageCategory, parts[1]);
        category = keyOf(Enums.MessageCategoryName, catIndex);

        if (category == "Undefined" and priority ~= "Undefined") then
            prettyName = "All " .. priority;
        elseif (priority == "Undefined" and category ~= "Undefined") then
            prettyName = "All " .. category .. " Messages";
        elseif (priority ~= "Undefined" and category ~= "Undefined") then
            prettyName = category .. " " .. priority;
        else
            prettyName = "All Messages";
        end
    end

    return prettyName;
end

signalTable.OnSelectMessageType= function(caller,signal)
    local frame = caller:Parent():Parent();

    signalTable.UpdateTitle(caller, signal);
    signalTable.UpdateConfirm(caller, signal);

    frame.MessageGrid.MessageSheet.Internals.GridBase.MessageGridData.OnSelectMessageType(signal);
    frame.MessageCenter.Visible = false;
    frame.MessageGrid.Visible = true;
end

signalTable.BackToMain = function(caller,signal)
    local frame = caller:Parent():Parent():Parent();

    signalTable.UpdateTitle(caller, "");
    frame.MessageCenter.Visible = true;
    frame.MessageGrid.Visible = false;
end

signalTable.UpdateConfirm = function(caller,signal)
    local messageCenterContent = caller:Parent():Parent();
    if (messageCenterContent ~= nil) then
        local confirmButton = messageCenterContent.MessageGrid.BottomBar.Confirm;
        if (confirmButton ~= nil) then
            confirmButton.signalValue = signal;
            confirmButton.Text = "Confirm " .. GetPrettyMessageName(signal);
        end
    end
end

signalTable.ConfirmMessages = function(caller,signal)
    if (caller.SignalValue ~= "") then
        local parts = {};
        for value in string.gmatch(signal, '([^.*]+)') do
            parts[#parts + 1] = value;
        end

        local category = parts[1];
        local priority = parts[2];

        if (category ~= "Undefined" and priority ~= "Undefined") then
            Cmd("call 'MessageCenter'.'" .. category .. "'.'" .. priority .. "'");
        elseif (category == "Undefined" and priority ~= "Undefined") then
            Cmd("call 'MessageCenter'.'" .. category .. "'.'" .. priority .. "'");
        elseif (category ~= "Undefined" and priority == "Undefined") then
            Cmd("call 'MessageCenter'.'" .. category .. "'");
        else
            Cmd("call 'MessageCenter'");
        end
    end
end

signalTable.UpdateTitle = function(caller, signal)
    local finalTitle = "Message Center";
    if (signal ~= "") then
        finalTitle = finalTitle .. " : " .. GetPrettyMessageName(signal);
    end

    -- Find the parent that holds the title
    local messageCenterWindow = caller:FindParent("MessageCenterWindow");
    if (messageCenterWindow ~= nil) then
        messageCenterWindow.TitleBar.Title.Text = finalTitle;
    else
        local messageCenterOverlay = caller:FindParent("MainDialog");
        if (messageCenterOverlay ~= nil) then
            messageCenterOverlay.TitleBar.Title.Text = finalTitle;
        end
    end
end