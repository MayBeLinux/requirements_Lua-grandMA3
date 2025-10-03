local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local visibleTab = "FrameAtFilter";
local BtnLineHeight = nil;
local BtnSelectAll = nil;
local BtnSelectNone = nil;

signalTable.OnFilterLoaded = function(caller,status,creator)
    signalTable.AtFilterSettings = CurrentProfile().TemporaryWindowSettings.AtFilterSettings;
    BtnLineHeight = caller.TitleBar.Auto.BtnLineHeight;
    BtnSelectAll = caller.TitleBar.Auto.BtnSelectAll;
    BtnSelectNone = caller.TitleBar.Auto.BtnSelectNone;
end

signalTable.OnTabChanged = function(caller,nextVisible)
    visibleTab = nextVisible;
    
    if BtnLineHeight ~= nil then
        if (visibleTab == "FrameAtFilter") then
           BtnLineHeight.Visible = true;
        else
           BtnLineHeight.Visible = false;
        end
    end

    if BtnSelectAll then
        if (visibleTab == "FrameAtFilter") then
           BtnSelectAll.Visible = true;
        else
           BtnSelectAll.Visible = false;
        end
    end

    if BtnSelectNone then
        if (visibleTab == "FrameAtFilter") then
           BtnSelectNone.Visible = true;
        else
           BtnSelectNone.Visible = false;
        end
    end

end

signalTable.OnPoolScreenLoaded = function(caller,status,creator)
    caller:Changed();    
end

signalTable.PoolLoaded = function(PoolObj)
	PoolObj.PoolObject = DataPool().Filters;
end

signalTable.CloneAtFilterChangeLineHeight = function(caller)
	local Overlay = caller:Parent():Parent():Parent();
	local InnerGrid = Overlay.Frame.DC.FrameAtFilter.Box.InnerGrid;
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
