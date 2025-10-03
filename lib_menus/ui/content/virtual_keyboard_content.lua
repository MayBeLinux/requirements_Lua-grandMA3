local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LanguageSwitch = function(caller,status)
    local overlay = caller:GetOverlay();
    if (overlay) then
        local currentUser = CmdObj().User;	
        if (currentUser) then
            local currentKeyboard = currentUser.Keyboard;
            if (currentKeyboard) then
                local parent = currentKeyboard:Parent();
                local nextId = (currentKeyboard:Index()) % parent:Count();
                nextId = nextId + 1;
                Cmd("Keyboard "..nextId);
                currentKeyboard = currentUser.Keyboard;
                if (currentKeyboard) then
                    caller.Text = currentKeyboard.Name;
                else
                    caller.Text = "No keyboards";
                end
            else
                Echo("LanguageSwitch: no current keyboard found");
                Cmd("Keyboard 1");
                currentKeyboard = currentUser.Keyboard;
                if (currentKeyboard) then
                    caller.Text = currentKeyboard.Name;
                else
                    caller.Text = "No keyboards";
                end
            end
        else
            Echo("LanguageSwitch: no current profile found");
        end
    end
end

