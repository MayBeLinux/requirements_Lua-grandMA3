local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SetButtonHeigtTarget = function(caller)
	caller.Target  = signalTable.AtFilterSettings;
end

signalTable.ChangeLineHeight = function(caller)
	local Overlay = caller:Parent():Parent():Parent();
	local InnerGrid = nil;
	
	if(Overlay.Frame.Container) then
		InnerGrid = Overlay.Frame.Container.Box.InnerGrid;
	elseif(Overlay.Frame.Dialogs) then
		InnerGrid = Overlay.Frame.Dialogs.AtFilter.Box.InnerGrid;
	else
		InnerGrid = Overlay.Frame.AtFilter.Box.InnerGrid;
	end
	local ContentGrid = InnerGrid.ContentGrid;
	
	local Height;
	if(signalTable.AtFilterSettings.LineHeight == "Default") then
		Height = "50";
	else
		Height = signalTable.AtFilterSettings.LineHeight;
	end
	
	InnerGrid.TitleGrid.H = Height;

	if(Height < "40") then
		ContentGrid.DefaultMargin = 4;
		InnerGrid.TitleGrid.DefaultMargin = 4;
	else
		ContentGrid.DefaultMargin = 8;
		InnerGrid.TitleGrid.DefaultMargin = 8;
	end
end