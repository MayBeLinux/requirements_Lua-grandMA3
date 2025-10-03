-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
-- The 'GetPool' function called by 'signalTable.OnLoaded' from the 'generic_popup.lua'
signalTable.GetPool = function()
	return CurrentProfile().RenderQualities;
end
signalTable.GetEmptyText = function()
	return "<Link Selected>";
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end