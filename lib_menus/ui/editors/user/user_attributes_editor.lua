local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local pVars = nil;

signalTable.UserAttributesEditorLoaded = function(caller,status,creator)
	local t = caller.EditTarget
	local grid = caller.Content.UserAttributesGrid;
	caller.Content.DualButtons.TimeLayerRes.Target=t
	caller.Content.DualButtons.PhaserLayerRes.Target=t
	caller.Content.DualButtons.DualEncoderPressFactor.Target=t
	caller.Content.DualButtons.DualEncoderFactor.Target=t
	caller.Content.DualButtons.LinkResolution.Target=t
	grid.TargetObject=t

	caller.TitleBar.Title.Text = caller.TitleBar.Title.Text .. " - UserProfile " .. caller.EditTarget:Parent().No .. " \"" .. caller.EditTarget:Parent().Name .. "\""
end
