local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function RemoveExt(FileName, ext)
	if (string.upper(string.sub(FileName, -string.len(ext))) == string.upper(ext)) then
		FileName = string.sub(FileName, 0, -string.len(ext) - 1);
	end
	return FileName;
end

signalTable.ActiveSelectorLoaded = function(caller)
	local File = Root().ColorTheme.FileName
	local themeFileName = RemoveExt(File, ".xml");
	caller.Text = "Active Color Theme\n'" .. themeFileName .. "'";
end
