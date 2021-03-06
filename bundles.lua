local utils = ...
local S = utils.S



local function register_bundle (color)
	minetest.register_node ("lwwires:bundle_"..color, {
		description = S("Wire Bundle ("..color..")"),
		short_description = S("Wire Bundle ("..color..")"),
		groups = { dig_immediate = 3, lwwires_bundle = 1 },
		inventory_image = "lwwires_bundle_"..color.."_item.png",
		wield_image = "lwwires_bundle_"..color.."_wield.png",
		wield_scale = {x = 1, y = 1, z = 1},
		stack_max = 99,
		liquids_pointable = false,
		light_source = 0,
		sounds = default.node_sound_defaults (),
		drawtype = "nodebox",
		visual_scale = 1.0,
		tiles = { "lwwires_bundle_"..color.."_y.png", "lwwires_bundle_"..color.."_y.png",
					 "lwwires_bundle_"..color.."_x.png", "lwwires_bundle_"..color.."_x.png",
					 "lwwires_bundle_"..color.."_z.png", "lwwires_bundle_"..color.."_z.png" },
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
			fixed = 				{ -2/16, -8/16, -2/16,  2/16, -4/16,  2/16 },
			connect_top = 		{ -2/16, -4/16, -2/16,  2/16,  8/16,  2/16 },
			connect_front = 	{ -2/16, -8/16, -8/16,  2/16, -4/16, -2/16 },
			connect_left =  	{ -8/16, -8/16, -2/16, -2/16, -4/16,  2/16 },
			connect_back =  	{ -2/16, -8/16,  2/16,  2/16, -4/16,  8/16 },
			connect_right = 	{  2/16, -8/16, -2/16,  8/16, -4/16,  2/16 }
		},
		connect_sides = { "top", "front", "left", "back", "right" },
		connects_to = { "group:lwwires_wire", "lwwires:bundle_"..color,
							 "lwwires:bundle_block_"..color, "group:bundles_connect" },

		selection_box = {
			type = "connected",
			fixed = 				{ -2/16, -8/16, -2/16,  2/16, -4/16,  2/16 },
			connect_top = 		{ -2/16, -4/16, -2/16,  2/16,  8/16,  2/16 },
			connect_front = 	{ -2/16, -8/16, -8/16,  2/16, -4/16, -2/16 },
			connect_left =  	{ -8/16, -8/16, -2/16, -2/16, -4/16,  2/16 },
			connect_back =  	{ -2/16, -8/16,  2/16,  2/16, -4/16,  8/16 },
			connect_right = 	{  2/16, -8/16, -2/16,  8/16, -4/16,  2/16 }
		},

		drop = "lwwires:bundle_"..color,

		_wires =
		{
			color = color.."",
			type = "bundle"
		},

		on_construct = function (pos)
			utils.wire_connections.on_construct_bundle (pos)
		end,

		on_destruct = function (pos)
			mesecon.queue:add_action (pos, "lwwires_bundle_on_destruct", { color }, 0.1, nil, 0)
		end,

		on_blast = function (pos, intensity)
			local node = minetest.get_node (pos)

			minetest.remove_node (pos)

			return minetest.get_node_drops (node.name, "")
		end,
	})
end



for k, v in pairs (utils.colors) do
	if type (k) == "string" then
		register_bundle (k.."")
	end
end



--
