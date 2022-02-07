local utils = ...



if minetest.get_translator and minetest.get_translator ("lwwires") then
	utils.S = minetest.get_translator ("lwwires")
elseif minetest.global_exists ("intllib") then
   if intllib.make_gettext_pair then
      utils.S = intllib.make_gettext_pair ()
   else
      utils.S = intllib.Getter ()
   end
else
   utils.S = function (s) return s end
end



utils.digilines_supported = minetest.global_exists ("digilines")



utils.colors =
{
	black		= 0,
	orange	= 1,
	magenta	= 2,
	sky		= 3,
	yellow	= 4,
	pink		= 5,
	cyan		= 6,
	gray		= 7,
	silver	= 8,
	red		= 9,
	green		= 10,
	blue		= 11,
	brown		= 12,
	lime		= 13,
	purple	= 14,
	white		= 15,
	[0] = "black",
	[1] = "orange",
	[2] = "magenta",
	[3] = "sky",
	[4] = "yellow",
	[5] = "pink",
	[6] = "cyan",
	[7] = "gray",
	[8] = "silver",
	[9] = "red",
	[10] = "green",
	[11] = "blue",
	[12] = "brown",
	[13] = "lime",
	[14] = "purple",
	[15] = "white",
}



utils.connect_to =
{
	"group:mesecon_needs_receiver",
	"mesecons_blinkyplant:blinky_plant_on",
	"mesecons_blinkyplant:blinky_plant_off",
	"mesecons_commandblock:commandblock_off",
	"mesecons_commandblock:commandblock_on",
	"mesecons_detector:object_detector_off",
	"mesecons_detector:object_detector_on",
	"mesecons_detector:node_detector_off",
	"mesecons_detector:node_detector_on",
	"group:mesecon", -- fpga, lightstone, microcontroller, power_plant
	"mesecons_hydroturbine:hydro_turbine_off",
	"mesecons_hydroturbine:hydro_turbine_on",
	"group:mesecon_effector_on", -- lamp
	"group:mesecon_effector_off", -- lamp, lightstone
	"mesecons_luacontroller:luacontroller0000",
	"mesecons_luacontroller:luacontroller0001",
	"mesecons_luacontroller:luacontroller0010",
	"mesecons_luacontroller:luacontroller0011",
	"mesecons_luacontroller:luacontroller0100",
	"mesecons_luacontroller:luacontroller0101",
	"mesecons_luacontroller:luacontroller0110",
	"mesecons_luacontroller:luacontroller0111",
	"mesecons_luacontroller:luacontroller1000",
	"mesecons_luacontroller:luacontroller1001",
	"mesecons_luacontroller:luacontroller1010",
	"mesecons_luacontroller:luacontroller1011",
	"mesecons_luacontroller:luacontroller1100",
	"mesecons_luacontroller:luacontroller1101",
	"mesecons_luacontroller:luacontroller1110",
	"mesecons_luacontroller:luacontroller1111",
	"mesecons_movestones:movestone",
	"mesecons_movestones:sticky_movestone",
	"mesecons_movestones:movestone_vertical",
	"mesecons_movestones:sticky_movestone_vertical",
	"mesecons_noteblock:noteblock",
	"mesecons_pistons:piston_normal_off",
	"mesecons_pistons:piston_normal_on",
	"mesecons_pistons:piston_sticky_off",
	"mesecons_pistons:piston_sticky_on",
	"mesecons_pressureplates:pressure_plate_wood_on",
	"mesecons_pressureplates:pressure_plate_wood_off",
	"mesecons_pressureplates:pressure_plate_stone_on",
	"mesecons_pressureplates:pressure_plate_stone_off",
	"mesecons_random:removestone",
	"mesecons_random:ghoststone",
	"mesecons_random:ghoststone_active",
	"mesecons_receiver:receiver",
	"mesecons_receiver:receiver_up",
	"mesecons_receiver:receiver_down",
	"mesecons_solarpanel:solar_panel",
	"mesecons_stickyblocks:sticky_block_all",
	"mesecons_switch:mesecon_switch_on",
	"mesecons_switch:mesecon_switch_off",
	"mesecons_torch:mesecon_torch_off",
	"mesecons_torch:mesecon_torch_on",
	"mesecons_extrawires:vertical_on",
	"mesecons_extrawires:vertical_off",
	"mesecons_extrawires:vertical_top_on",
	"mesecons_extrawires:vertical_top_off",
	"mesecons_extrawires:vertical_bottom_on",
	"mesecons_extrawires:vertical_bottom_off",
}



function utils.get_far_node (pos)
	local node = minetest.get_node (pos)

	if node.name == "ignore" then
		minetest.get_voxel_manip ():read_from_map (pos, pos)

		node = minetest.get_node (pos)

		if node.name == "ignore" then
			return nil
		end
	end

	return node
end



function utils.can_interact_with_node (pos, player)
	if player and player:is_player () then
		if minetest.check_player_privs (player, "protection_bypass") then
			return true
		end

		return not minetest.is_protected (pos, player:get_player_name ())
	end

	return not minetest.is_protected (pos, "")
end



function utils.wires_to_color_list (wires)

	if type (wires) == "number" then
		local idx = utils.colors[wires]

		if not idx then
			return { }
		end

		return { idx }
	elseif type (wires) == "string" then
		if not utils.colors[wires] then
			return { }
		end

		return { wires.."" }
	elseif type (wires) == "table" then
		local result = { }

		for i = 1, #wires, 1 do
			local idx = utils.colors[wires[i]]

			if idx then
				if type (wires[i]) == "string" then
					result[#result + 1] = wires[i]
				elseif type (idx) == "string" then
					result[#result + 1] = idx
				end
			end
		end

		return result
	end

	return { }
end



function utils.color_string_list ()
	local colors = { }

	for k, v in pairs (utils.colors) do
		if type (k) == "string" then
			colors[#colors + 1] = k..""
		end
	end

	return colors
end



function utils.is_wire_in_list (wire, list)
	local scolor = nil
	local icolor = nil

	if type (wire) == "string" then
		icolor = utils.colors[wire]

		if not icolor then
			return false
		end

		scolor = wire

	elseif type (wire) == "number" then
		scolor = utils.colors[wire]

		if not scolor then
			return false
		end

		icolor = wire

	else
		return false
	end

	for i = 1, #list, 1 do
		if type (list[i]) == "string" then
			if scolor == list[i] then
				return true
			end
		elseif type (list[i]) == "number" then
			if icolor == list[i] then
				return true
			end
		end
	end

	return false
end



function utils.get_wires_interface (pos)
	local node = utils.get_far_node (pos)

	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			return def._wires
		end
	end

	return nil
end



function utils.get_component_interface (pos)
	local node = utils.get_far_node (pos)

	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			if def._wires then
				return node, def._wires, nil
			end

			if def.mesecons then
				return node, nil, def.mesecons
			end
		end
	end

	return nil, nil, nil
end



--
