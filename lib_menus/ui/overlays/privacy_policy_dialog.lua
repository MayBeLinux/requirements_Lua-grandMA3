local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.PrivacyPolicyDialogLoaded = function(caller,status,creator)
    if(caller.PrivacyPolicyHelp ~= nil) then
	   local url  = "privacyPolicyScreen";
	   caller.PrivacyPolicyHelp.PrivacyPolicyUrl = url;	
	end
end

signalTable.ActivateAgreeBtn = function(caller,dummy)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local agreeBtn = overlay:FindRecursive("AgreeBtn", "Button");
		if (agreeBtn) then agreeBtn.Enabled = true; end
	end
end