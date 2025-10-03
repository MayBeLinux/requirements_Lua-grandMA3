local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local indexTemporaryWindowSettings  = 10;
local indexView3DSettings			= 10;

signalTable.LiveFixturePatchLoaded = function(caller, str)
	FixturePatchLoadedCommon(caller, str)

	local o								= caller:GetOverlay()
	local fixtureGrid					= o.Content.MainFixturesGridContainer.FixturesSetupGrid;
	local userProfile					= CurrentProfile();
	local ToolbarLeftTop				= o.Content.MainFixturesGridContainer.View3DArea.LayoutGrid.ToolbarLeftTop;
	local temporaryWindowSettings		= userProfile:Ptr(indexTemporaryWindowSettings);
	local View3DSettings				= temporaryWindowSettings:Ptr(indexView3DSettings);

	ToolbarLeftTop.Select.Target		= View3DSettings;
	ToolbarLeftTop.Move.Target			= View3DSettings;
	ToolbarLeftTop.Orbit.Target			= View3DSettings;
	ToolbarLeftTop.Zoom.Target			= View3DSettings;
	ToolbarLeftTop.Pivot.Target			= View3DSettings;
	ToolbarLeftTop.SetPivot.Target		= View3DSettings;
	ToolbarLeftTop.FocusControl.Target	= View3DSettings;

	Show3D(caller);
end

