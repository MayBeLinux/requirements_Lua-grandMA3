local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SplashScreenDialogLoaded = function(caller,status,creator)
	local path = GetPath(Enums.PathType.Shared);
	local lFile = io.open(path.."/language/splash_screens/splash_screen.txt", "r");
	local notes = "File with release info not found at:"..path.."/language/splash_screens/splash_screen.txt";
	if (lFile ~= nil) then
		notes = lFile:read("*a");
	end
	caller.SplashScreenText.Text = notes;
	
	if (caller:GetDisplayIndex() >= 6) then
       caller.Font = "Regular9"	    
 	end	
end
