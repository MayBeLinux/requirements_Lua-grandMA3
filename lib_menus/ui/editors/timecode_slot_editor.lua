local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnUpdateTitle = function(caller,status,creator)
	local slot = caller.EditTarget
	if(slot.SourceIP ~= "") then
		caller.TitleBar.Title.Text = caller.TitleBar.Title.Text .. " : "..slot.SourceIP
	end
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame:SetChildren("Target",target);
end
