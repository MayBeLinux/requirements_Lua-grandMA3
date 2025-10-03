local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local content_table =
{
	{ displayName = "Color",    contentName="SpecialWindowContentPlaceholder" , contentMenu="ColorPickerContent"  , titlebuttonMenu="ColorPickerTitlebar"  },
	{ displayName = "Shapers",  contentName="SpecialWindowContentPlaceholder" , contentMenu="ShaperWindowContent" , titlebuttonMenu="ShaperWindowTitlebar" }
}

signalTable.OnLoaded = function(caller,status,creator)
	local vtab = caller.Frame.TabWrapper.VTab;
	if (vtab) then
        for k,v in ipairs(content_table) do
		    vtab:AddListStringItem(v.displayName, v.contentName);
        end
		vtab:SelectListItemByValue("DimmerTab");
	end
	caller.Visible=true; caller:Changed();
end

local function RebuildPlaceholder(ph, menu, user_triggered)
    if (menu) then
        if Root().Menus[menu] then
            Root().Menus[menu]:CommandCall(ph, user_triggered);
            Echo("RebuildPlaceholder: Menu %s called", menu)
        else
            ErrEcho("RebuildPlaceholder: Menu %s not found!", menu)
        end
    else
        Echo("RebuildPlaceholder: menu string is empty. deleting previous content...")
        local child = ph:GetUIChild(1);
        if child then
            child:CommandDelete();
        end
    end
end

signalTable.VMyTabChanged = function(caller,_,tab_id,tab_index, initial)
    local sel = content_table[tab_index + 1]
    local win = caller:FindParent("SpecialWindow")

    local contentPlaceholder = win.Frame.TabWrapper.VTabContents.SpecialWindowContentPlaceholder
    local titlebuttonsPlaceholder = win.TitleBar.SpecialDialogTitlebar

    RebuildPlaceholder(contentPlaceholder, sel.contentMenu, not initial)
    RebuildPlaceholder(titlebuttonsPlaceholder, sel.titlebuttonMenu, false)
    --
    -- if not initial then
    --     FindNextFocus();
    -- end
end

signalTable.SetTarget = function(caller)
    local win = caller:FindParent("SpecialWindow")
    caller.Target = win.WindowSettings
end
