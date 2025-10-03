local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
    if(caller.IsMainBuddy) then
	   signalTable.BaseInput=caller;
	   local display_index=caller:GetDisplayIndex();
	   local target=CmdObj().TempStoreSettings;
	   local addArgs = caller.AdditionalArgs;
	   if (addArgs.isParent == "y") then
		   local n = caller.Context:GetChildClass();
		   if (addArgs.firstWouldBeIndex ~= nil) then n = n .. " " .. addArgs.firstWouldBeIndex; end;
		   target.NewName           = n;
	   else
		   target.NewName           = caller.Context.Name;
	   end
	   target.ScreenContentMask = 1 << (display_index-1) ;
	end
end

signalTable.SelectAllText = function(caller,status,creator)
	caller:WaitInit(nil, true);--forcing re-init
	caller.SelectAll();
end

signalTable.OnSetTarget = function(caller,status,creator)
	caller.Target=CmdObj().TempStoreSettings;
end

signalTable.OnAllClicked = function(caller, button, x, y)
	local target=CmdObj().TempStoreSettings;
	target.ScreenContentMask=127;
end

signalTable.OnNoneClicked = function(caller, button, x, y)
	local target=CmdObj().TempStoreSettings;
	target.ScreenContentMask=0;
end

signalTable.OnDisplayClicked = function(caller)
	local target=CmdObj().TempStoreSettings;
	local scm = target.ScreenContentMask;
	Echo(scm);
	local dialogframe = caller:Parent():Parent()
	local screenshotbutton = dialogframe.Container.Screenshot;

	if( scm == 1  or scm == 2 or scm == 4 or scm == 8 or scm == 16 or scm == 32 or scm == 64) then 
		screenshotbutton.Enabled = true;
	else
		screenshotbutton.Enabled = false;
	end
end


signalTable.OnPleaseClicked = function(caller,status,creator)

	local storeCommand = signalTable.BaseInput.StrContext -- "Store Viewbutton 1.1"    
	local target=CmdObj().TempStoreSettings;
	local screenshot_enabled = CurrentProfile().ScreenshotEnabled;
	local first=true;
	local countDisplays = 0;
	local screenNr = "0";

	local text = string.format("%s '%s' /Overwrite /Screen '",
		storeCommand,
		target.NewName)

	for i=1, 7 do
		if(target["ScreenContentDisplay"..i]) then 
			if(first) then
				text = string.format("%s%s",text,i)
			else
				text = string.format("%s,%s",text,i)
			end 
			first=false;
			countDisplays = countDisplays + 1;
			screenNr = i
		end
	end	
	
	signalTable.BaseInput.Value=text;
	signalTable.BaseInput.Close();

	Cmd(text);
	coroutine.yield({ui=10}) --  adding delay to storeprocess of screenshot in a view in order to close the view store options before screenshot

	local storeObject = storeCommand:sub(7) -- "Viewbutton 1.1"
	local target = ObjectList(storeObject)[1] -- view button or view
		

	if(screenshot_enabled == true) then
		if(countDisplays == 1) then
			
            local image = signalTable.GetImageOfTarget(target);
			
			if(image==nil or image.FileName~="") then
				local imagepool =  Root().ShowData.MediaPools.Images;
				image = imagepool:Acquire();
				if(image~=nil) then
					image.name = CmdObj().TempStoreSettings.NewName
				end
			end
			
			if(image~=nil) then 
				CmdIndirect(string.format("Store %s /Screen=%d /XRes=128 /NC", HandleToStr(image),screenNr));
				CmdIndirect(string.format("Assign %s At %s /NC", HandleToStr(image), HandleToStr(target)));
			end
		end
	else
        local image = signalTable.GetImageOfTarget(target);
        if(image ~= nil and image.FileName == "") then
            local assigned_object = target.Object
            assigned_object.Appearance = nil;
        end
	end
end

signalTable.GetImageOfTarget = function(target)
    local image = nil;

    local assigned_object=target.Object;
    if(assigned_object~=nil) then
        local appearance=assigned_object.Appearance;
        if(appearance~=nil) then
            image=appearance.Image;								
        end
    else
        local appearance=target.Appearance;
        if(appearance~=nil) then
            image=appearance.Image;								
        end
    end

    return image;
end