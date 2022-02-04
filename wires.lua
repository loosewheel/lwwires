local utils = ...
local S = utils.S


-- flag to lock out mesecons updating
local lockout = false

mesecon.queue:add_function ("lwwires_wire_on_construct", function (pos)
	lockout = false
end)



local function register_wire (color)
	minetest.register_node ("lwwires:"..color, {
		description = S("Wire ("..color..")"),
		short_description = S("Wire ("..color..")"),
		groups = { dig_immediate = 2, lwwires_wire = 1 },
		inventory_image = "lwwires_"..color.."_item.png",
		wield_image = "lwwires_"..color.."_item.png",
		wield_scale = {x = 1, y = 1, z = 1},
		stack_max = 99,
		liquids_pointable = false,
		light_source = 0,
		--sound = { },
		drawtype = "nodebox",
		visual_scale = 1.0,
		tiles = { "lwwires_"..color..".png", "lwwires_"..color..".png",
					 "lwwires_"..color..".png", "lwwires_"..color..".png",
					 "lwwires_"..color..".png", "lwwires_"..color..".png" },
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
		connects_to = { "group:lwwires_bundle", "lwwires:"..color, "group:mesecon_conductor_craftable",
							 "group:wires_connect", unpack (utils.connect_to) },

		selection_box = {
			type = "connected",
			fixed = 				{ -2/16, -8/16, -2/16,  2/16, -6/16,  2/16 },
			connect_top = 		{ -2/16, -5/16, -2/16,  2/16,  8/16,  2/16 },
			connect_front = 	{ -2/16, -8/16, -8/16,  2/16, -6/16, -2/16 },
			connect_left =  	{ -8/16, -8/16, -2/16, -2/16, -6/16,  2/16 },
			connect_back =  	{ -2/16, -8/16,  2/16,  2/16, -6/16,  8/16 },
			connect_right = 	{  2/16, -8/16, -2/16,  8/16, -6/16,  2/16 }
		},

		drop = "lwwires:"..color,

		mesecons = {
			effector = {
				rules = {
								{ x = -1, y =  0, z =  0 },
								{ x =  1, y =  0, z =  0 },
								{ x =  0, y =  0, z = -1 },
								{ x =  0, y =  0, z =  1 },
								{ x =  0, y = -1, z =  0 },
								{ x =  0, y =  1, z =  0 },
				},

				action_on = function (pos, node)
					utils.wire_connections:turn_on (pos, color.."", pos, false)
				end,

				action_off = function (pos, node)
					if not lockout then
						utils.wire_connections:turn_off_wire (color.."", pos)
					end
				end,
			}
		},

		on_construct = function (pos)
			utils.wire_connections:add_node (pos, "wire", color.."")

			lockout = true
			mesecon.queue:add_action (pos, "lwwires_wire_on_construct", { }, nil, true, 0)

			utils.wire_connections:place_wire (color.."", pos)
		end,

		on_destruct = function (pos)
			utils.wire_connections:dig_wire (color.."", pos)

			utils.wire_connections:remove_node (pos)
		end,
	})
end



for k, v in pairs (utils.colors) do
	if type (k) == "string" then
		register_wire (k.."")
	end
end



--
