----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/16/2014 9:49:42 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.MenuHelper = _G.GoonBase.MenuHelper or {}
local Menu = _G.GoonBase.MenuHelper

function Menu:SetupMenu( menu, id )
	if menu[id] == nil then
		Print("[Error] Could not find '" .. id .. "' in menu!")
		return
	end
	self.menu_to_clone = menu[id]
end

function Menu:SetupMenuButton( menu, id, button_id )
	if menu[id] == nil then
		Print("[Error] Could not find '" .. id .. "' in menu!")
		return
	end
	if button_id == nil then
		button_id = 1
	end
	self.menubutton_to_clone = menu[id]:items()[button_id]
end

function Menu:NewMenu( menu_id )

	self.menus = self.menus or {}

	local new_menu = deep_clone( self.menu_to_clone )
	new_menu._items = {}
	self.menus[menu_id] = new_menu

	return new_menu

end

function Menu:GetMenu( menu_id )
	local menu = self.menus[menu_id]
	if menu == nil then
		Print("[Error] Could not find menu with id '" .. menu_id .. "'!")
	end
	return menu
end

function Menu:AddBackButton( menu_id )
	local menu = self:GetMenu( menu_id )
	MenuManager:add_back_button( menu )
end

function Menu:AddButton( button_data )

	local data = {
		type = "CoreMenuItem.Item",
	}

	local params = {
		name = button_data.id,
		text_id = button_data.title,
		help_id = button_data.desc,
		callback = button_data.callback,
		back_callback = button_data.back_callback,
		disabled_color = Color(0.25, 1, 1, 1),
		next_node = button_data.next_node,
	}

	local menu = self:GetMenu( button_data.menu_id )
	local item = menu:create_item(data, params)
	item._priority = button_data.priority or 0

	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end

function Menu:AddDivider( divider_data )

	local data = {
		type = "MenuItemDivider",
		size = divider_data.size or 8,
		no_text = divider_data.no_text or true,
	}

	local params = {
		name = divider_data.id,
	}

	local menu = self:GetMenu( divider_data.menu_id )
	local item = menu:create_item( data, params )
	item._priority = divider_data.priority or 0
	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end

function Menu:AddToggle( toggle_data )

	local data = {
		type = "CoreMenuItemToggle.ItemToggle",
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "on",
			x = 24,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 24,
			s_y = 24,
			s_w = 24,
			s_h = 24
		},
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "off",
			x = 0,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 0,
			s_y = 24,
			s_w = 24,
			s_h = 24
		}
	}

	local params = {
		name = toggle_data.id,
		text_id = toggle_data.title,
		help_id = toggle_data.desc,
		callback = toggle_data.callback,
		disabled_color = toggle_data.disabled_color or Color( 0.25, 1, 1, 1 ),
		icon_by_text = toggle_data.icon_by_text or false
	}

	local menu = self:GetMenu( toggle_data.menu_id )
	local item = menu:create_item( data, params )
	item:set_value( toggle_data.value and "on" or "off" )
	item._priority = toggle_data.priority or 0
	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end

function Menu:AddSlider( slider_data )

	local data = {
		type = "CoreMenuItemSlider.ItemSlider",
		min = slider_data.min or 0,
		max = slider_data.max or 10,
		step = slider_data.step or 1,
		show_value = slider_data.show_value or false
	}

	local params = {
		name = slider_data.id,
		text_id = slider_data.title,
		help_id = slider_data.desc,
		callback = slider_data.callback,
		disabled_color = slider_data.disabled_color or Color( 0.25, 1, 1, 1 ),
	}

	local menu = self:GetMenu( slider_data.menu_id )
	local item = menu:create_item(data, params)
	item:set_value( math.clamp(slider_data.value, data.min, data.max) or data.min )
	item._priority = slider_data.priority or 0

	if slider_data.disabled then
		item:set_enabled( not slider_data.disabled )
	end

	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end

function Menu:AddMultipleChoice( multi_data )

	local data = {
		type = "MenuItemMultiChoice"
	}
	for k, v in ipairs( multi_data.items or {} ) do
		table.insert( data, { _meta = "option", text_id = v, value = k } )
	end
	
	local params = {
		name = multi_data.id,
		text_id = multi_data.title,
		help_id = multi_data.desc,
		callback = multi_data.callback,
		filter = true
	}
	
	local menu = self:GetMenu( multi_data.menu_id )
	local item = menu:create_item(data, params)
	item._priority = multi_data.priority or 0
	item:set_value( multi_data.value or 1 )

	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end

function Menu:AddKeybinding( button_data )

	local data = {
		type = "MenuItemCustomizeController",
	}

	local params = {
		name = button_data.id,
		text_id = button_data.title,
		connection_name = button_data.connection_name,
		binding = button_data.binding,
		localize = "false",
		button = button_data.button,
		callback = button_data.callback,
	}

	local menu = self:GetMenu( button_data.menu_id )
	local item = menu:create_item(data, params)
	item._priority = button_data.priority or 0

	menu._items_list = menu._items_list or {}
	table.insert( menu._items_list, item )

end


function Menu:BuildMenu( menu_id )

	-- Check menu exists
	local menu = self.menus[menu_id]
	if menu == nil then
		Print("[Error] Attempting to build menu '" .. menu_id .."' which doesn't exist!")
		return
	end

	-- Check items exist for this menu
	if menu._items_list ~= nil then

		local priority_items = {}
		local nonpriority_items = {}
		for k, v in pairs( menu._items_list ) do
			if v._priority ~= nil and v._priority > 0 then
				table.insert( priority_items, v )
			else
				table.insert( nonpriority_items, v )
			end
		end

		-- Sort table by priority, higher priority first
		table.sort( priority_items, function(a, b)
			return a._priority > b._priority
		end)

		-- Sort non-priority items alphabetically
		table.sort( nonpriority_items, function(a, b)
			return managers.localization:text(a._parameters.text_id or "") < managers.localization:text(b._parameters.text_id or "")
		end)

		-- Add items to menu
		for k, item in pairs( priority_items ) do
			menu:add_item( item )
		end
		for k, item in pairs( nonpriority_items ) do
			menu:add_item( item )
		end

		-- Slider dirty callback fix
		for k, item in pairs( menu._items ) do
			if item._type == "slider" or item._parameters.type == "CoreMenuItemSlider.ItemSlider" then
				item.dirty_callback = nil
			end
		end

	end

	-- Add back button to menu
	self:AddBackButton( menu_id )

	-- Build menu data
	self.menus[menu_id] = menu

	return self.menus[menu_id]

end

function Menu:AddMenuItem( parent_menu, child_menu, name, desc, menu_position, subposition )

	if parent_menu == nil then
		Print( string.gsub("[Menus][Warning] Parent menu for child '{1}' is null, ignoring...", "{1}", child_menu) )
		return
	end

	-- Put at end of menu
	if menu_position == nil then
		menu_position = #parent_menu._items + 1
	end

	-- Get menu position from string
	if type( menu_position ) == "string" then
		for k, v in pairs( parent_menu._items ) do
			if menu_position == v["_parameters"]["name"] then

				if subposition == nil then
					subposition = "after"
				end

				if subposition == "after" then
					menu_position = k + 1
				else
					menu_position = k
				end

				break

			end
		end
	end

	-- Insert in menu
	local button = deep_clone( self.menubutton_to_clone )
	button._parameters.name = name
	button._parameters.text_id = name
	button._parameters.help_id = desc
	button._parameters.next_node = child_menu
	table.insert( parent_menu._items, menu_position, button )

end

-- END OF FILE
