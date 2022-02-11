local utils = ...
local S = utils.S



local mesecons_rules =
{
	{ x = -1, y =  0, z =  0 },
	{ x =  1, y =  0, z =  0 },
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y = -1, z =  0 },
	{ x =  0, y =  1, z =  0 },
}



local function register_wire (color)
	minetest.register_node ("lwwires:"..color, {
		description = S("Wire ("..color..")"),
		short_description = S("Wire ("..color..")"),
		groups = { dig_immediate = 3, lwwires_wire = 1 },
		inventory_image = "lwwires_"..color.."_item.png",
		wield_image = "lwwires_"..color.."_wield.png",
		wield_scale = {x = 1, y = 1, z = 1},
		stack_max = 99,
		liquids_pointable = false,
		light_source = 0,
		sounds = default.node_sound_defaults (),
		drawtype = "nodebox",
		visual_scale = 1.0,
		tiles = { "lwwires_"..color..".png" },
		paramtype = "light",
		paramtype2 = "none",
		is_ground_content = false,
		sunlight_propagates = true,
		walkable = false,
		pointable = true,
		diggable = true,
		climbable = false,
		buildable_to = false,
		floodable = false,
		liquidtype = "none",

		node_box = {
			type = "connected",
			fixed = 				{ -2/16, -8/16, -2/16,  2/16, -6/16,  2/16 },
			connect_top = 		{ -2/16, -6/16, -2/16,  2/16,  8/16,  2/16 },
			connect_front = 	{ -2/16, -8/16, -8/16,  2/16, -6/16, -2/16 },
			connect_left =  	{ -8/16, -8/16, -2/16, -2/16, -6/16,  2/16 },
			connect_back =  	{ -2/16, -8/16,  2/16,  2/16, -6/16,  8/16 },
			connect_right = 	{  2/16, -8/16, -2/16,  8/16, -6/16,  2/16 }
		},
		connect_sides = { "top", "front", "left", "back", "right" },
		connects_to = { "group:lwwires_bundle", "lwwires:"..color,
							 "lwwires:through_"..color.."_off",
							 "lwwires:through_"..color.."_on",
							 "group:mesecon_conductor_craftable",
							 "group:wires_connect", unpack (utils.connect_to) },

		selection_box = {
			type = "connected",
			fixed = 				{ -2/16, -8/16, -2/16,  2/16, -6/16,  2/16 },
			connect_top = 		{ -2/16, -6/16, -2/16,  2/16,  8/16,  2/16 },
			connect_front = 	{ -2/16, -8/16, -8/16,  2/16, -6/16, -2/16 },
			connect_left =  	{ -8/16, -8/16, -2/16, -2/16, -6/16,  2/16 },
			connect_back =  	{ -2/16, -8/16,  2/16,  2/16, -6/16,  8/16 },
			connect_right = 	{  2/16, -8/16, -2/16,  8/16, -6/16,  2/16 }
		},

		drop = "lwwires:"..color,

		_wires =
		{
			color = color.."",
			type = "wire"
		},

		mesecons = {
			effector = {
				rules = mesecons_rules,

				action_on = function (pos, node, rule)
					if not utils.wire_on_construct_lockout_flag then
						utils.wire_connections.turn_on_wire (color, pos, rule)
					end
				end,

				action_off = function (pos, node, rule)
					utils.wire_connections.turn_off_wire (color, pos)
				end,
			}
		},

		on_construct = function (pos)
			utils.wire_on_construct_lockout_flag = true
			mesecon.queue:add_action (pos, "lwwires_wire_on_construct", { color }, 0.1, true, 0)
		end,

		on_destruct = function (pos)
			utils.wire_connections.on_destruct_wire (color, pos)
		end,

		on_blast = function (pos, intensity)
			local node = minetest.get_node (pos)

			minetest.remove_node (pos)
			mesecon.queue:add_action (pos, "lwwires_wire_on_blast", { color }, 0.1, true, 0)

			return minetest.get_node_drops (node.name, "")
		end,
	})
end



local through_wire_get_rules = function (node)
	local rules = { { x =  0, y =  0, z = -1 },
						 { x =  0, y =  0, z =  1 },
						 { x =  0, y = -1, z =  0 },
						 { x =  0, y =  1, z =  0 },
						 { x = -1, y =  0, z =  0 },
						 { x =  2, y =  0, z =  0 },
						 { x =  3, y =  0, z =  0 } }

	if node.param2 == 2 then
		rules = mesecon.rotate_rules_left(rules)
	elseif node.param2 == 3 then
		rules = mesecon.rotate_rules_right(mesecon.rotate_rules_right(rules))
	elseif node.param2 == 0 then
		rules = mesecon.rotate_rules_right(rules)
	end

	return rules
end



local function register_through_wire (color)
	mesecon.register_node ("lwwires:through_"..color, {
		description = S("Through Wire ("..color..")"),
		short_description = S("Through Wire ("..color..")"),
		wield_scale = {x = 1, y = 1, z = 1},
		stack_max = 99,
		liquids_pointable = false,
		light_source = 0,
		sounds = default.node_sound_defaults (),
		drawtype = "nodebox",
		visual_scale = 1.0,
		tiles = { "lwwires_"..color..".png" },
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		sunlight_propagates = true,
		walkable = false,
		pointable = true,
		diggable = true,
		climbable = false,
		buildable_to = false,
		floodable = false,
		liquidtype = "none",

		node_box = {
			type = "fixed",
			fixed = {
				{ -1/32, -1/32,  8/16, 1/32,   1/32, 3/2   }, -- the wire through the block
				{-0.125, -0.125, 0.375, 0.125, 0.125, 0.5}, -- connect_pad
				{-0.125, 0.375, -0.125, 0.125, 0.5, 0.125}, -- base_x
				{-0.5, -0.5, -0.125, 0.5, -0.375, 0.125}, -- wire_x
				{-0.125, -0.5, -0.5, 0.125, -0.375, 0.125}, -- wire_z
				{-0.125, -0.125, 0, 0.125, 0.125, 0.5}, -- wire_vert
				{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- wire_top
			}
		},

		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.5, 0.1875, 0.5, 0.5}, -- connect_pad
			}
		},

		drop = "lwwires:through_"..color.."_off",
	}, {
		tiles = { "lwwires_"..color..".png" },
		groups = { dig_immediate = 3 },
		mesecons = {
			conductor = {
				state = mesecon.state.off,
				rules = through_wire_get_rules,
				onstate = "lwwires:through_"..color.."_on"
			}
		}
	}, {
		tiles = { "lwwires_"..color..".png" },
		groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
		mesecons = {
			conductor = {
				state = mesecon.state.on,
				rules = through_wire_get_rules,
				offstate = "lwwires:through_"..color.."_off"
			}
		}
	})
end



for k, v in pairs (utils.colors) do
	if type (k) == "string" then
		register_wire (k.."")
		register_through_wire (k.."")
	end
end



--
