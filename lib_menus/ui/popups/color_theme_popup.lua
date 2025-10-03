local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

local function RemoveExt(FileName, ext)
	if (string.upper(string.sub(FileName, -string.len(ext))) == string.upper(ext)) then
		FileName = string.sub(FileName, 0, -string.len(ext) - 1);
	end
	return FileName;
end

local function ThemeClicked(caller, libNum)
	local oldAddr = CmdObj().Destination:Addr();
	Cmd("CD Root");--workaround
	Cmd("Library");--workaround
	Cmd("CD ColorTheme");
	Cmd("Library");
	Cmd("Import Library "..libNum);
	local result = RemoveExt(CmdObj().Library[libNum].Name, ".xml");
	Cmd("CD Root "..oldAddr);

	return caller, result;
end

signalTable.OnLoaded = function(caller,status,creator)
	Echo("ColorThemePopup loaded");
	local oldAddr = CmdObj().Destination:Addr();
	Cmd("CD Root");--workaround
	Cmd("Library");--workaround
	Cmd("CD ColorTheme");
	Cmd("Library");

	local lib = CmdObj().Library;
	for i,libFile in ipairs(lib:Children()) do
		local themeFileName = RemoveExt(libFile.Name, ".xml");
		caller:AddListLuaItem(themeFileName, "ThemeClicked"..i, ThemeClicked, i);
	end
	caller:SelectListItemByName(Root().ColorTheme.FileName);
	caller.Visible=true; caller:Changed(); -- visibility change should NOT be necessary any more, but to be sure, I leave it in for now...
	Cmd("cd Root "..oldAddr);
end
