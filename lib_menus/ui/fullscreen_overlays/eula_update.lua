local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.EulaUpdateLoaded = function(caller,status,creator)

	local codecBtn = caller.TB.CodecBtn;
	--ToggleButton

	if (codecBtn) then
		--codecBtn.Visible = false;
		--codecBtn.Visible = true;
		codecBtn:AddListNumericItem("Free", 1);
		codecBtn:AddListNumericItem("Full", 2);
		codecBtn:SelectListItemByValue(2);
	end

	local plugin     =my_handle:Parent();
	local plugin_pool=plugin:Parent();
	plugin_pool.EulaDialog:CommandCall(caller);


end

signalTable.DontAgree = function(caller,dummy)
	local overlay = caller:GetOverlay();
	overlay.Value = "0";
    overlay.Close();
end

signalTable.Agree = function(caller,dummy)
	local overlay = caller:GetOverlay();
	local codecBtn = caller:Parent().CodecBtn;
	if (codecBtn) then
		--MessageBox({title = "Agreed", message = "Please confirm " .. codecBtn:GetListSelectedItemIndex(), display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
		if (codecBtn:GetListSelectedItemIndex() == 2) then
			overlay.Value = "3";
		--	Root().StationSettings.LocalSettings.Accepted3rdParty = true;
		--	Root().StationSettings.LocalSettings.EULAAccepted = true;
		else
			overlay.Value = "1";
		--	Root().StationSettings.LocalSettings.Accepted3rdParty = false;
		--	Root().StationSettings.LocalSettings.EULAAccepted = true;
		end
		--Root().StationSettings:Save("", "");
	end
	overlay.Close();
end
