---------------------------------------------------------------------------
function activateDebuggee()
    local json = require 'json'
    debuggee = require 'vscode-debuggee'

    local config = {
        dumpCommunication = false; -- dump communication in debug console
        dumpGMA3 = false;
    }

    if (HostType() == "Linux" or HostType() == "Console") then
        local cmdresult = gma3_helpers:osExecuteWithResult("grep nfs /proc/mounts | cut -f1 -d ':'");
        if (cmdresult ~= nil) then
            config.controllerHost = cmdresult;
            Echo("LUA debugger IP: " .. config.controllerHost);
        end
    end

    local startResult, breakerType = debuggee.start(json, config)
    Printf('json library:         '..tostring(json))
    Printf('debuggee library:     '..tostring(debuggee))
    Printf('debuggee breakertype: '..tostring(breakerType))
    Printf('debuggee startresult: '..tostring(startResult))
    return debuggee;
end
---------------------------------------------------------------------------
return activateDebuggee