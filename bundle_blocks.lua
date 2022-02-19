local utils = ...
local S = utils.S



local function register_bundle_block (color)
	minetest.register_node ("lwwires:bundle_block_"..color, {
		description = S("Wire Bundle Block ("..color..")"),
		short_description = S("Wire Bundle Block ("..color..")"),
		groups = { dig_immediate = 3, lwwires_bundle = 1 },
		wield_scale = {x = 1, y = 1, z = 1},
		stack_max = 99,
		liquids_pointable = false,
		light_source = 0,
		sounds = default.node_sound_defaults (),
		drawtype = "normal",
		visual_scale = 1.0,
		tiles = { "lwwires_bundle_block_"..color.."_top.png", "lwwires_bundle_block_"..color.."_top.png",
					 "lwwires_bundle_block_"..color.."_side.png", "lwwires_bundle_block_"..color.."_side.png",
					 "lwwires_bundle_block_"..color.."_side.png", "lwwires_bundle_block_"..color.."_side.png" },
		paramtype = "light",
		paramtype2 = "none",
		is_ground_content = false,
		sunlight_propagates = false,
		walkable = true,
		pointable = true,
		diggable = true,
		climbable = false,
		buildable_to = false,
		floodable = false,
		liquidtype = "none",

		drop = "lwwires:bundle_block_"..color,

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
		register_bundle_block (k.."")
	end
end



--
