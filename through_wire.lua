local utils = ...
local S = utils.S



local wiredefs =
{
	zp =
	{
		node_box = { -- z+
			type = "connected",
			fixed = {
				{-0.1875, -0.1875, 0.40625, 0.1875, 0.1875, 0.5}, -- connect_pad
				{-0.03125, -0.03125, 0.5, 0.03125, 0.03125, 1.5}, -- through_wire
				{-0.0625, -0.5, 0.4375, 0.0625, 0, 0.5}, -- connect_vert_wire
				{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- connect_horz_wire
			},
			connect_top = 		{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- y+ wire
			connect_left =  	{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- x- wire
			connect_front =  	{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- z- wire
			connect_right = 	{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- x+ wire
		},
		connect_sides = { "top", "front", "left", "right" },
		rules =
		{
			{ x =  0, y =  0, z = -1 },
			{ x = -1, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x =  0, y =  0, z =  2 },
			{ x =  0, y =  0, z =  3 }
		}
	},
	zn =
	{
		node_box = { -- z-
			type = "connected",
			fixed = {
				{-0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.40625}, -- connect_pad
				{-0.03125, -0.03125, -1.5, 0.03125, 0.03125, -0.5}, -- through_wire
				{-0.0625, -0.5, -0.5, 0.0625, 0, -0.4375}, -- connect_vert_wire
				{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- connect_horz_wire
			},
			connect_top = 		{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- y+ wire
			connect_back = 	{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- z+ wire
			connect_left =  	{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- x- wire
			connect_right = 	{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- x+ wire
		},
		connect_sides = { "top", "left", "back", "right" },
		rules =
		{
			{ x =  0, y =  0, z =  1 },
			{ x = -1, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x =  0, y =  0, z = -2 },
			{ x =  0, y =  0, z = -3 }
		}
	},
	xp =
	{
		node_box = { -- x+
			type = "connected",
			fixed = {
				{0.40625, -0.1875, -0.1875, 0.5, 0.1875, 0.1875}, -- connect_pad
				{0.5, -0.03125, -0.03125, 1.5, 0.03125, 0.03125}, -- through_wire
				{0.4375, -0.5, -0.0625, 0.5, 0, 0.0625}, -- connect_vert_wire
				{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- connect_horz_wire
			},
			connect_top = 		{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- y+ wire

			connect_front =  	{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- z- wire
			connect_left =  	{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- x- wire
			connect_back = 	{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- z+ wire
		},
		connect_sides = { "top", "front", "left", "back" },
		rules =
		{
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
			{ x = -1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x =  2, y =  0, z =  0 },
			{ x =  3, y =  0, z =  0 }
		}
	},
	xn =
	{
		node_box = { -- x-
			type = "connected",
			fixed = {
				{-0.5, -0.1875, -0.1875, -0.40625, 0.1875, 0.1875}, -- connect_pad
				{-1.5, -0.03125, -0.03125, -0.5, 0.03125, 0.03125}, -- through_wire
				{-0.5, -0.5, -0.0625, -0.4375, 0, 0.0625}, -- connect_vert_wire
				{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- connect_horz_wire
			},
			connect_top = 		{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- y+ wire
			connect_front =  	{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- z- wire
			connect_back = 	{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- z+ wire
			connect_right = 	{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- x+ wire
		},
		connect_sides = { "top", "front", "back", "right" },
		rules =
		{
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x = -2, y =  0, z =  0 },
			{ x = -3, y =  0, z =  0 }
		}
	},
	yp =
	{
		node_box = { -- y+
			type = "connected",
			fixed = {
				{-0.1875, 0.40625, -0.1875, 0.1875, 0.5, 0.1875}, -- connect_pad
				{-0.03125, 0.5, -0.03125, 0.03125, 1.5, 0.03125}, -- through_wire
				{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- center wire
			},
			connect_front =  	{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- z- wire
			connect_left =  	{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- x- wire
			connect_back = 	{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- z+ wire
			connect_right = 	{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- x+ wire
		},
		connect_sides = { "front", "left", "back", "right" },
		rules =
		{
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
			{ x = -1, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y = -1, z =  0 },
			{ x =  0, y =  2, z =  0 },
			{ x =  0, y =  3, z =  0 }
		}
	},
	yn =
	{
		node_box = { -- y-
			type = "connected",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.40625, 0.1875}, -- connect_pad
				{-0.03125, -1.5, -0.03125, 0.03125, -0.5, 0.03125}, -- through_wire
			},
			connect_top = 		{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- y+ wire
			connect_front =  	{-0.0625, -0.5, -0.5, 0.0625, -0.4375, 0.0625}, -- z- wire
			connect_left =  	{-0.5, -0.5, -0.0625, 0.0625, -0.4375, 0.0625}, -- x- wire
			connect_back = 	{-0.0625, -0.5, -0.0625, 0.0625, -0.4375, 0.5}, -- z+ wire
			connect_right = 	{-0.0625, -0.5, -0.0625, 0.5, -0.4375, 0.0625}, -- x+ wire
		},
		connect_sides = { "top", "front", "left", "back", "right" },
		rules =
		{
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  0, z =  1 },
			{ x = -1, y =  0, z =  0 },
			{ x =  1, y =  0, z =  0 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -2, z =  0 },
			{ x =  0, y = -3, z =  0 }
		}
	}
}



local function through_wire_on_place (itemstack, placer, pointed_thing)
	local name = nil

	if pointed_thing and pointed_thing.type == "node" then
		local dir = vector.subtract (pointed_thing.under, pointed_thing.above)

		if dir.y < 0 then
			name = "lwwires:through_wire_yn_off"
		elseif dir.y > 0 then
			name = "lwwires:through_wire_yp_off"
		elseif dir.x < 0 then
			name = "lwwires:through_wire_xn_off"
		elseif dir.x > 0 then
			name = "lwwires:through_wire_xp_off"
		elseif dir.z < 0 then
			name = "lwwires:through_wire_zn_off"
		elseif dir.z > 0 then
			name = "lwwires:through_wire_zp_off"
		end
	end

	if name then
		minetest.item_place (ItemStack (name), placer, pointed_thing)

		if not utils.is_creative (placer) then
			itemstack:take_item (1)
		end
	end

	return itemstack
end



local function register_through_wire (ext, def)

	local groups = { dig_immediate = 3, wires_connect = 1 }
	local on_place = nil

	if ext ~= "zp" then
		groups.not_in_creative_inventory = 1
	else
		on_place = through_wire_on_place
	end

	mesecon.register_node ("lwwires:through_wire_"..ext, {
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
			fixed = { -0.5, -0.5, -0.5, 0.5, -0.25, 0.5 }
		},
		node_box = def.node_box,
		connect_sides = def.connect_sides,
		connects_to = { "group:lwwires_wire", "group:wires_connect" },

		drop = "lwwires:through_wire_zp_off",
		sounds = default.node_sound_defaults(),
	}, {
		tiles = { "mesecons_wire_off.png" },
		groups = groups,
		on_place = on_place,
		mesecons = {
			conductor = {
				state = mesecon.state.off,
				rules = def.rules,
				onstate = "lwwires:through_wire_"..ext.."_on"
			}
		}
	}, {
		tiles = { "mesecons_wire_on.png" },
		groups = { dig_immediate = 3, wires_connect = 1, not_in_creative_inventory = 1 },
		mesecons = {
			conductor = {
				state = mesecon.state.on,
				rules = def.rules,
				offstate = "lwwires:through_wire_"..ext.."_off"
			}
		}
	})

end



for ext, def in pairs (wiredefs) do
	register_through_wire (ext, def)
end



--
