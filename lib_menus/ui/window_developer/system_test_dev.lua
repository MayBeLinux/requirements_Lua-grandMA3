local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local SystemTestRef

local function LoadSystemTest()
    if not DataPool().Plugins["SystemTest"] then
        Cmd("cd pl; import lib 'system_test.xml' /NC; cd root")
    end
    SystemTestRef = DataPool().Plugins["SystemTest"]
end

local function UpdateStatusButton(statusButton)
    if not SystemTestRef or not IsObjectValid(SystemTestRef) then
        statusButton.Text = "Not loaded."
    else
        statusButton.Text = "Systemtest loaded."
    end
end

local function delayedInit(x,y,overlay)
    LoadSystemTest()
    UpdateStatusButton(overlay.Content.Status)
end

signalTable.OnLoaded = function(caller,status,creator)
    local testSelector = caller.Content.TestList;
    testSelector:AddListStringItem("WorkInProgress","");
    testSelector:AddListStringItem("Test","");
    testSelector:SelectListItemByIndex(1);

    -- HookObjectChange(signalTable.PluginsChanged,  -- 1. function to call
    -- DataPool().Plugins,                 -- 2. object to hook
    -- my_handle:Parent(),                 -- 3. plugin object ( internally needed )
    -- caller)                             -- 4. user callback parameter

    -- Timer(delayedInit,1,0,nil,caller)
    
    LoadSystemTest()
    UpdateStatusButton(overlay.Content.Status)
end