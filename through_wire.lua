local utils = ...
local S = utils.S



local through_wire_up_rules = {
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y = -1, z = -1 },
	{ x =  0, y =  1, z = -1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y = -1, z =  1 },
	{ x =  0, y =  1, z =  1 },
	{ x = -1, y =  0, z =  0 },
	{ x = -1, y = -1, z =  0 },
	{ x = -1, y =  1, z =  0 },
	{ x =  1, y =  0, z =  0 },
	{ x =  1, y = -1, z =  0 },
	{ x =  1, y =  1, z =  0 },
	{ x =  0, y = -1, z =  0 },
	{ x =  0, y =  2, z =  0 },
	{ x =  0, y =  3, z =  0 }
}



mesecon.register_node ("lwwires:through_wire_up", {
	description = S("Wires Through Wire"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "node",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.0625, -0.5, -0.0625, 0.0625,     0.5, 0.0625 }, -- center_wire
			{    -0.5, -0.5,    -0.5,    0.5, -0.4375,    0.5 }, -- base
		}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.03125,     0.5, -0.03125, 0.03125,      1.5, 0.03125 }, -- the wire through the block
			{   -0.125, 0.40625,   -0.125,   0.125,      0.5,   0.125 }, -- connect_pad
			{  -0.0625,     -0.5,    -0.5,  0.0625,  -0.4375,     0.5 }, -- horz_connect_wire
			{     -0.5,     -0.5, -0.0625,     0.5,  -0.4375,  0.0625 }, -- left right wire
			{   -0.125,     -0.5,  -0.125,   0.125, -0.40625,   0.125 }, -- center_pad
			{  -0.0625,     -0.5, -0.0625,  0.0625,      0.5,  0.0625 }, -- center_wire
		}
	},
	drop = "lwwires:through_wire_off",
	sounds = default.node_sound_defaults(),
}, {
	tiles = { "mesecons_wire_off.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			rules = through_wire_up_rules,
			onstate = "lwwires:through_wire_up_on"
		}
	}
}, {
	tiles = { "mesecons_wire_on.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			rules = through_wire_up_rules,
			offstate = "lwwires:through_wire_up_off"
		}
	}
})



local through_wire_down_rules = {
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y = -1, z = -1 },
	{ x =  0, y =  1, z = -1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y = -1, z =  1 },
	{ x =  0, y =  1, z =  1 },
	{ x = -1, y =  0, z =  0 },
	{ x = -1, y = -1, z =  0 },
	{ x = -1, y =  1, z =  0 },
	{ x =  1, y =  0, z =  0 },
	{ x =  1, y = -1, z =  0 },
	{ x =  1, y =  1, z =  0 },
	{ x =  0, y =  1, z =  0 },
	{ x =  0, y = -2, z =  0 },
	{ x =  0, y = -3, z =  0 }
}



mesecon.register_node ("lwwires:through_wire_down", {
	description = S("Wires Through Wire"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "node",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.0625, -0.5, -0.0625, 0.0625,     0.5, 0.0625 }, -- center_wire
			{    -0.5, -0.5,    -0.5,    0.5, -0.4375,    0.5 }, -- base
		}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.03125,    -0.5, -0.03125, 0.03125,   -1.5,  0.03125 }, -- the wire through the block
			{  -0.0625,     -0.5,    -0.5,  0.0625,  -0.4375,    0.5 }, -- horz_connect_wire
			{     -0.5,     -0.5, -0.0625,     0.5,  -0.4375, 0.0625 }, -- left right wire
			{   -0.125,     -0.5,  -0.125,   0.125, -0.40625,  0.125 }, -- center_pad
			{  -0.0625,     -0.5, -0.0625,  0.0625,      0.5, 0.0625 }, -- center_wire
		}
	},
	drop = "lwwires:through_wire_off",
	sounds = default.node_sound_defaults(),
}, {
	tiles = { "mesecons_wire_off.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			rules = through_wire_down_rules,
			onstate = "lwwires:through_wire_down_on"
		}
	}
}, {
	tiles = { "mesecons_wire_on.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			rules = through_wire_down_rules,
			offstate = "lwwires:through_wire_down_off"
		}
	}
})



local through_wire_get_rules = function (node)
	local rules = { { x =  0, y =  0, z = -1 },
						 { x =  0, y = -1, z = -1 },
						 { x =  0, y =  1, z = -1 },
						 { x =  0, y =  0, z =  1 },
						 { x =  0, y = -1, z =  1 },
						 { x =  0, y =  1, z =  1 },
						 { x =  0, y = -1, z =  0 },
						 { x =  0, y =  1, z =  0 },
						 { x = -1, y =  0, z =  0 },
						 { x = -1, y = -1, z =  0 },
						 { x = -1, y =  1, z =  0 },
						 { x =  2, y =  0, z =  0 },
						 { x =  3, y =  0, z =  0 } }

	if node.param2 == 2 then
		rules = mesecon.rotate_rules_left (rules)
	elseif node.param2 == 3 then
		rules = mesecon.rotate_rules_right (mesecon.rotate_rules_right (rules))
	elseif node.param2 == 0 then
		rules = mesecon.rotate_rules_right (rules)
	end

	return rules
end



local function on_place (itemstack, placer, pointed_thing)
	local param2 = nil

	if pointed_thing and pointed_thing.type == "node" then
		local dir = vector.subtract (pointed_thing.under, pointed_thing.above)

		if dir.y < 0 then
			minetest.item_place (ItemStack ("lwwires:through_wire_down_off"), placer, pointed_thing)

			if not utils.is_creative (placer) then
				itemstack:take_item (1)
			end

			return itemstack
		elseif dir.y > 0 then
			minetest.item_place (ItemStack ("lwwires:through_wire_up_off"), placer, pointed_thing)

			if not utils.is_creative (placer) then
				itemstack:take_item (1)
			end

			return itemstack
		elseif dir.x < 0 then
			param2 = 3
		elseif dir.x > 0 then
			param2 = 1
		elseif dir.z < 0 then
			param2 = 2
		elseif dir.z > 0 then
			param2 = 0
		end
	end

	return minetest.item_place (itemstack, placer, pointed_thing, param2)
end



mesecon.register_node ("lwwires:through_wire", {
	description = S("Wires Through Wire"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.0625, -0.5, -0.0625, 0.0625,     0.5, 0.0625 }, -- center_wire
			{    -0.5, -0.5,    -0.5,    0.5, -0.4375,    0.5 }, -- base
		}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.03125, -0.03125,     0.5, 0.03125,  0.03125,    1.5 }, -- the wire through the block
			{   -0.125,   -0.125, 0.40625,   0.125,    0.125,    0.5 }, -- connect_pad
			{  -0.0625,     -0.5,  0.4375,  0.0625,    0.125,    0.5 }, -- vert_connect_wire
			{  -0.0625,     -0.5,    -0.5,  0.0625,  -0.4375,    0.5 }, -- horz_connect_wire
			{     -0.5,     -0.5, -0.0625,     0.5,  -0.4375, 0.0625 }, -- left right wire
			{   -0.125,     -0.5,  -0.125,   0.125, -0.40625,  0.125 }, -- center_pad
			{  -0.0625,     -0.5, -0.0625,  0.0625,      0.5, 0.0625 }, -- center_wire
		}
	},
	drop = "lwwires:through_wire_off",
	sounds = default.node_sound_defaults(),
}, {
	tiles = { "mesecons_wire_off.png" },
	groups = { dig_immediate = 3, wires_connect = 1 },
	on_place = on_place,
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			rules = through_wire_get_rules,
			onstate = "lwwires:through_wire_on"
		}
	}
}, {
	tiles = { "mesecons_wire_on.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			rules = through_wire_get_rules,
			offstate = "lwwires:through_wire_off"
		}
	}
})



--
