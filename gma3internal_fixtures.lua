---------------------------------------------------------------------------
fixtures= 
{ 
};
---------------------------------------------------------------------------
function fixtures.DeleteAllStages()
    Cmd("cd Root");
    Cmd("cd 'ShowData'.'Patch'");
    Cmd("cd 'Stages'");
    Cmd("delete 1 thru");
end
---------------------------------------------------------------------------
function fixtures.DeleteAllFixtureTypes()
    Cmd("cd Root");
    Cmd("cd 'ShowData'.'Patch'");
    Cmd("set 'FixtureTypes' Source='grandMA3'");
    Cmd("delete 'Stages'.1 Thru");
    Cmd("cd FixtureTypes");
    Cmd("delete 1 thru");
end
---------------------------------------------------------------------------
function fixtures.NewShow()
	Cmd("Cd Root");
	CmdIndirect("NewShow");
    coroutine.yield(1);
end
---------------------------------------------------------------------------
function fixtures.ImportFixtureType(textFixtureType,bIndirect)
	local retryCnt=0;
    local root = Root();
	if (bIndirect)
	then
		Echo("library3d:ImportFixtureType '"..textFixtureType.." ' called.");
		CmdIndirect("cd Root");
		CmdIndirect("cd 'ShowData'.'Patch'");
		CmdIndirect("set 'FixtureTypes' Source='grandMA3'");
		CmdIndirect("cd 'FixtureTypes'");
		CmdIndirect("import lib '"..textFixtureType.."'");
		CmdIndirect("cd Root");
	else
		Echo("library3d:ImportFixtureType '"..textFixtureType.." ' called.");
		Cmd("cd Root");
		Cmd("cd 'ShowData'.'Patch'");
		Cmd("set 'FixtureTypes' Source='grandMA3'");
		Cmd("cd 'FixtureTypes'");
		Cmd("import lib '"..textFixtureType.."'");
		Cmd("cd Root");
	end
	coroutine.yield(1);
end
---------------------------------------------------------------------------
function fixtures.CreateFixtures(textFixtureType,count)
	local idx=root.ShowData.LivePatch.FixtureTypes:Find(textFixtureType);
	if (idx>=0)
	then
		Echo("FixtureType "..textFixtureType.." found");
	else
		Echo("FixtureType "..textFixtureType.." not found");
	end
end
---------------------------------------------------------------------------
