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



for k, v in pairs (utils.colors) do
	if type (k) == "string" then
		register_wire (k.."")
	end
end



--
