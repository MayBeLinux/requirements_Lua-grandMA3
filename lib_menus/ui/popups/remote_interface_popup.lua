local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	local TempInterfaces = Root().Temp.TempNetworkInterfaces;
	local Interfaces = TempInterfaces:Ptr(1);
	HookObjectChange(signalTable.InterfaceListChanged   ,Interfaces  ,my_handle:Parent(), caller);
end


signalTable.InterfaceListChanged =  function(caller,status,popup)
	local TempInterfaces = Root().Temp.TempNetworkInterfaces;
	local Interfaces = TempInterfaces:Ptr(1);
	local n=Interfaces:Count();
	popup:ClearList()
	local Text="Auto";
	local Value=string.format("0.0");
	popup:AddListStringItem(Text,Value);

	local ColorTheme = Root().ColorTheme.ColorGroups;
	local color_off=ColorTheme.Network.Standalone;
	local color_on=ColorTheme.Network.Connected;
	local network_icon=FindTexture("network");
	local color;

	for i=1,n do
		local Interface=Interfaces:Ptr(i);
		local m=Interface:Count();
		for j=1,m do
			if (Interface.Name ~= "imx6") then
				local Text=Interface.Name;
				local InterfaceIP=Interface:Ptr(j);
				if (InterfaceIP.IP == "") then
					Text=Text.." (No IP)";
				else
					Text=Text.." ("..InterfaceIP.IP.. ")";
				end
				if (Interface.Link) then
					color=color_on;
				else
					color=color_off;
				end
				local Value=string.format("%d.%d",i,j);
				popup:AddListStringItem(Text,Value,{left={image=network_icon, image_color=color.Val32}});
			end
		end
	end
	if(popup.Value ~= "Auto") then 
		popup:SelectListItemByIndex(tonumber(popup.Value)+1);
	end
	popup:Changed();
	popup.Frame.Popup.ShowLeftIcon=true;
	popup.Visible=true;
end