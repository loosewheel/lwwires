local utils = ...
local S = utils.S



local terminal_get_rules = function (node)
	local rules = { { x =  0, y = -1, z =  0 },
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



mesecon.register_node ("lwwires:terminal", {
	description = S("Wires Terminal"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	on_rotate = false,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, -0.25, 0.5 }
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.03125, -0.03125,     0.5, 0.03125,  0.03125,    1.5 }, -- the wire through the block
			{   -0.1875, -0.1875, 0.40625,  0.1875,   0.1875,    0.5 }, -- connect_pad
			{  -0.0625,     -0.5,  0.4375,  0.0625,    0.125,    0.5 }, -- vert_connect_wire
			{  -0.0625,     -0.5,       0,  0.0625,  -0.4375,    0.5 }, -- horz_connect_wire
			{   -0.125,     -0.5,  -0.125,   0.125, -0.40625,  0.125 }, -- center_pad
		}
	},
	drop = "lwwires:terminal_off",
	sounds = default.node_sound_defaults(),
}, {
	tiles = { "mesecons_wire_off.png" },
	groups = { dig_immediate = 3, wires_connect = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			rules = terminal_get_rules,
			onstate = "lwwires:terminal_on"
		}
	}
}, {
	tiles = { "mesecons_wire_on.png" },
	groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			rules = terminal_get_rules,
			offstate = "lwwires:terminal_off"
		}
	}
})



--
