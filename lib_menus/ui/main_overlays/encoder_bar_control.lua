local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);




signalTable.EncoderBarControlLoaded = function(caller)

	local encoderbarcontainer = caller.ContentContainer.EncoderBarContainer
	local grandmastergrid = encoderbarcontainer.GrandMasterGrid
	grandmastergrid.Visible = false;
	local top = encoderbarcontainer.Top
	top.SelectionOverlay.Visible = false;
	top.PhaserOverlay.Visible = false;
	top.MatricksMenu.Visible = false;
	top.ProgFader.Visible = false;
	top.ExecFader.Visible = false;

end