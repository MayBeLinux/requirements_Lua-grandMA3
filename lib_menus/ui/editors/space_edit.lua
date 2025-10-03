local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local val = caller.Value;
	local myspace = nil;
	local ed = caller.EditTarget;
	if IsObjectValid(ed) then
		myspace = ed:FindParent("Space");
		if(myspace ~= nil) then
			caller.Content:SetChildren("Target",myspace);
			caller.Content.Grid.TargetObject = myspace;
		end
	end
end

