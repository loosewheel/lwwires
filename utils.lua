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



function utils.is_creative (player)
	if minetest.settings:get_bool ("creative_mode") then
		return true
	end

	if player and player:is_player () then
		return minetest.is_creative_enabled (player:get_player_name ()) or
				 minetest.check_player_privs (player, "creative")
	end

	return false
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



-- flag to lock out mesecons action_on during construction
utils.wire_on_construct_lockout_flag = false



--
