local utils = ...
local S = utils.S



function lwwires.wire (idx)
	return utils.colors[idx]
end



function lwwires.is_wire_in_list (wire, list)
	return utils.is_wire_in_list (wire, list)
end



function lwwires.color_string_list ()
	return utils.color_string_list ()
end



function lwwires.bundle_on (src_pos, pos, wires)
	local node = utils.get_far_node (pos)

	if not node or string.sub (node.name, 1, 15) ~= "lwwires:bundle_" then
		return false
	end

	local colors = utils.wires_to_color_list (wires)

	if #colors < 1 then
		return false
	end

	utils.wire_connections.turn_on (src_pos, colors, pos)
end



function lwwires.bundle_off (src_pos, pos, wires)
	local node = utils.get_far_node (pos)

	if not node or string.sub (node.name, 1, 15) ~= "lwwires:bundle_" then
		return false
	end

	local colors = utils.wires_to_color_list (wires)

	if #colors < 1 then
		return false
	end

	utils.wire_connections.turn_off (src_pos, colors, pos, true)
end



function lwwires.bundle_power (pos, wires)
	local node = utils.get_far_node (pos)

	if not node or string.sub (node.name, 1, 15) ~= "lwwires:bundle_" then
		return nil
	end

	if wires == nil then
		wires = utils.color_string_list ()
	end

	return utils.wire_connections.power_at_pos (wires, pos)
end



--
