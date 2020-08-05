-- main.lua


panelWidth3d = 2048 
panelHeight3d = 2048


components = {
	electrical({})
}

local popup = contextWindow {
	name = "Battery Panel",
	position = {50, 50, 390, 296},
	noResize = true,
	visible = true,
	vrAuto = true,
	components = {electrical{position={0, 0, 512, 512}}},
}

--Function show hide 
function show_hide()
	popup:setIsVisible(not popup:isVisible())
end


local status	= true

-- will be called when clicking on the first menu
function change_menu()
	-- flip status
	status = not status
	-- update status of menu entry (normal or greyed)
	sasl.enableMenuItem( menu_action, status and 1 or 0)
	-- change menu text accordingly
	sasl.setMenuItemName( status)
	-- check menu if enabled
	sasl.setMenuItemState(status and MENU_CHECKED or MENU_UNCHECKED)
end

-- create our top level menu in plugins menu
menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "Electrical Panel")
-- make our menu entry a submenu
menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, menu_master)
-- add a menu entry


-- add menu entry
menu_action	= sasl.appendMenuItem(menu_main, "Show/hide popup", show_hide)
-- set initial state
change_menu()

