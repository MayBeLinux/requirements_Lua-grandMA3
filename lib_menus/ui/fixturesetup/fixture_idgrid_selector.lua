local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnFIDSelectorLoaded = function(caller)
	local p = Patch();
	local g = caller.Frame.FIDGrid;

	g.SelectCell('', p.IDTypes.Fixture.MaxID + 1, 0);
end

signalTable.DoSelectNone = function(caller)
	local o = caller:GetOverlay();
	o.Value = "";
	o.Close();
end

signalTable.DoSelect = function(caller)
	local o = caller:GetOverlay();
	local g = o.Frame.FIDGrid;
	local addArgs = caller.AdditionalArgs;
	local count = 1;
	if (addArgs ~= nil and addArgs.FixtureCount ~= nil) then count = tonumber(addArgs.FixtureCount); end
	local fid = tonumber(g.SelectedRow);
	local proceed = true;

	if (CheckFIDCollision(fid, count) == false) then
		proceed = Confirm("Fixture Id Collisions", "There are collisions with the selected starting Id and amount of fixtures.\nDo you want to continue ?");
	end

	if (proceed == true) then
		o.Value = g.SelectedRow;
		o.Close();
	end
end

signalTable.OnSelectedCell = function(caller)
	signalTable.DoSelect(caller);
end
