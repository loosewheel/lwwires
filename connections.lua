local utils = ...



local connections = { }



local switch_coords =
{
	{ x = -1, y =  0, z =  0 },
	{ x =  1, y =  0, z =  0 },
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y =  1, z =  0 },
	{ x =  0, y = -1, z =  0 }
}

local powered_coords =
{
	{ x =  1, y =  0, z =  0 },
	{ x = -1, y =  0, z =  0 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y =  1, z =  0 },
	{ x =  0, y = -1, z =  0 }
}


-- generic callers -----------------------------------------------------



local function for_each_recurse (color, pos, caller_pos, caller_type, caller_color,
											is_mesecons, func, test_coords, check_list)
	local spos = minetest.pos_to_string (pos, 0)

	if check_list[spos] ~= true then
		local continue, checked, con_type, con_color, con_mesecons =
			func (color, pos, caller_pos, caller_type, caller_color, is_mesecons, check_list)

		check_list[spos] = checked

		if not continue then
			return
		end

		for i = 1, #test_coords, 1 do
			for_each_recurse (color, vector.add (pos, test_coords[i]), pos, con_type,
									con_color, con_mesecons, func, test_coords, check_list)
		end
	end
end



local function for_each (color, pos, func, not_first, test_coords, check_list)
	local spos = minetest.pos_to_string (pos, 0)

	if not check_list[spos] then
		local continue, checked, con_type, con_color, con_mesecons = true, true, "wire", color, false
		local node, wires, mese = utils.get_component_interface (pos)

		if wires and wires.type then
			con_type = wires.type
			con_color = wires.color
		elseif mese then
			con_mesecons = true
		end

		if not not_first then
			continue, checked, con_type, con_color, con_mesecons =
				func (color, pos, pos, con_type, con_color, con_mesecons, check_list)
		end

		check_list[spos] = checked

		if not continue then
			return
		end

		for i = 1, #test_coords, 1 do
			for_each_recurse (color, vector.add (pos, test_coords[i]), pos, con_type,
									con_color, con_mesecons, func, test_coords, check_list)
		end
	end
end



-- operations ----------------------------------------------------------


-- variables for operations tally (deep nested)
local power_found = false
local notify_positions = { }



local function add_node_notify_on (pos)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		notify_positions[minetest.pos_to_string (test_pos, 0)] = true
	end
end



local function add_node_notify_off (pos)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		notify_positions[minetest.pos_to_string (test_pos, 0)] = true
	end
end



local function notify_on (action_wires, action_pos)
	for k, _ in pairs (notify_positions) do
		if k ~= action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local inter = utils.get_wires_interface (pos)

				if inter and inter.bundle_on then
					inter.bundle_on (pos, table.copy (action_wires))
				end
			end
		end
	end

	notify_positions = { }
end



local function notify_off (action_wires, action_pos)
	for k, _ in pairs (notify_positions) do
		if k ~= action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local inter = utils.get_wires_interface (pos)

				if inter and inter.bundle_off then
					inter.bundle_off (pos, table.copy (action_wires))
				end
			end
		end
	end

	notify_positions = { }
end



-- is mesecons turned on
local function is_mesecons_on (node)
	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			local mese = def.mesecons

			if mese then
				if mese.conductor then
					if mese.conductor.state then
						if mese.conductor.state == mesecon.state.on then
							return true
						end
					elseif mese.conductor.states then
						if mesecon.getstate (node.name, mese.conductor.states) ~= 1 then
							return true
						end
					end
				end

				if mese.receptor and mese.receptor.state == mesecon.state.on then
					return true
				end

				if mese.effector and mese.effector.action_off and
					minetest.get_item_group (node.name, "lwwires_wire") == 0 then

					return true
				end
			end
		end
	end

	return false
end



-- is any mesecons turned off
local function is_mesecons_off (node)
	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			local mese = def.mesecons

			if mese then
				if mese.conductor then
					if mese.conductor.state then
						if mese.conductor.state == mesecon.state.off then
							return true
						end
					elseif mese.conductor.states then
						if mesecon.getstate (node.name, mese.conductor.states) == 1 then
							return true
						end
					end
				end

				if mese.receptor and mese.receptor.state == mesecon.state.off then
					return true
				end

				if mese.effector and mese.effector.action_on and
					minetest.get_item_group (node.name, "lwwires_wire") == 0 then

					return true
				end
			end
		end
	end

	return false
end



-- is mesecons power state on
local function is_mesecons_power (node)
	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			local mese = def.mesecons

			if mese then
				if mese.receptor and mese.receptor.state == mesecon.state.on then
					return true
				end
			end
		end
	end

	return false
end



-- is a mesecons component
local function is_mesecons_component (pos)
	local node, wires, mese = utils.get_component_interface (pos)

	return mese ~= nil
end



-- look for adjacent bundle power source
local function find_bundle_power_source (pos, color, check_list)
	for i = 1, #powered_coords, 1 do
		local test_pos = vector.add (pos, powered_coords[i])
		local spos = minetest.pos_to_string (test_pos, 0)

		if check_list[spos] then
			return false
		end

		local wires = utils.get_wires_interface (test_pos)

		if wires and wires.current_state then
			local state = wires.current_state (test_pos, vector.new (pos))

			check_list[spos] = true

			if type (state) == "table" then
				if state[color] then
					return true
				end
			end
		end
	end

	return false
end


-- does pos at rule connect back by its rules
local function is_connected_by_rules (pos, rule)
	local tpos = vector.add (pos, rule)
	local node, wire, mese = utils.get_component_interface (tpos)

	if wire then
		return true
	end

	if mese then
		local rules = nil

		if mese.conductor then
			rules = mesecon.conductor_get_rules (node)
		elseif mese.receptor then
			rules = mesecon.receptor_get_rules (node)
		elseif mese.effector then
			rules = mesecon.effector_get_rules (node)
		end

		if rules then
			for _, v in ipairs (rules) do
				if vector.equals (pos, vector.add (tpos, v)) then
					return true
				end
			end
		end
	end

	return false
end



-- callback for for_each
-- returns continue, checked, con_type, con_color, is_mesecons
local function check_for_power (color, pos, caller_pos, caller_type,
										  caller_color, is_mesecons, check_list)
	local node, wires, mese = utils.get_component_interface (pos)

	if wires then
		if wires.type == "bundle" then
			if caller_type == "bundle" and caller_color ~= wires.color then
				return false, false, wires.type, wires.color, false
			end

			if find_bundle_power_source (pos, color, check_list) then
				power_found = true

				return false, true, wires.type, wires.color, false
			end

			return true, true, wires.type, wires.color, false

		elseif wires.type == "wire" then
			if is_mesecons then
				-- new wire circuit
				check_list[minetest.pos_to_string (pos, 0)] = true

				for i = 1, #powered_coords, 1 do
					for_each_recurse (wires.color, vector.add (pos, powered_coords[i]), pos, wires.type,
											wires.color, false, check_for_power, powered_coords, check_list)

					if power_found then
						return false, true, wires.type, wires.color, false
					end
				end

			elseif wires.color == color then
				return true, true, wires.type, wires.color, false
			end

		elseif wires.current_state then
			return false, false, wires.type, wires.color, false

		else
			return true, true, wires.type, wires.color, false

		end

	elseif mese then
		if mese.receptor and mese.receptor.state == mesecon.state.on then
			power_found = true

			return false, true, caller_type, caller_color, true
		end

		if mese.conductor then
			local conductor_on = false

			if mese.conductor.state then
				conductor_on = mese.conductor.state == mesecon.state.on
			elseif mese.conductor.states then
				conductor_on = mesecon.getstate (node.name, mese.conductor.states) ~= 1
			end

			if conductor_on then
				local rules = mese.conductor.rules

				if rules then
					if type (rules) == "function" then
						rules = rules (node)
					end
				else
					rules = mesecon.rules.default
				end

				check_list[minetest.pos_to_string (pos, 0)] = true

				for i = 1, #rules do
					if is_connected_by_rules (pos, rules[i]) then
						for_each_recurse (color, vector.add (pos, rules[i]), pos, caller_type,
												caller_color, true, check_for_power, powered_coords, check_list)

						if power_found then
							return false, true, caller_type, caller_color, true
						end
					end
				end
			end
		end

	end

	return false, true, caller_type, caller_color, false
end



-- check single color
local function is_pos_powered_wire (color, pos, exclude_pos, check_self, check_list)
	if check_self then
		if is_mesecons_power (utils.get_far_node (pos)) then
			return true
		end
	end

	local spos = minetest.pos_to_string (pos, 0)
	local sepos = (exclude_pos and minetest.pos_to_string (exclude_pos, 0)) or ""
	local node, wires, mese = utils.get_component_interface (pos)

	if wires and wires.type then
		if not check_list[spos] then
			power_found = false
			check_list[sepos] = true

			for_each (color, pos, check_for_power, not check_self, powered_coords, check_list)

			if power_found then
				power_found = false

				return true
			end
		end

	elseif mese then
		if not check_list[spos] then
			power_found = false
			check_list[sepos] = true

			for_each (color, pos, check_for_power, not check_self, powered_coords, check_list)

			if power_found then
				power_found = false

				return true
			end
		end

	else
		power_found = false

		local cl = table.copy (check_list)
		cl[sepos] = true

		for i = 1, #powered_coords, 1 do
			for_each (color, pos, check_for_power, not check_self, powered_coords, cl)

			if power_found then
				power_found = false

				return true
			end
		end

	end

	return false
end



-- check one or more colors
local function is_pos_powered (color, pos, exclude_pos, check_self, check_list)
	if check_self then
		if is_mesecons_power (utils.get_far_node (pos)) then
			return "mesecons"
		end
	end

	if color then
		if is_pos_powered_wire (color, pos, exclude_pos, check_self, check_list) then
			return color
		end
	else
		local colors = utils.color_string_list ()
		local powered = { }

		for i = 1, #colors, 1 do
			local cl = table.copy (check_list)

			if is_pos_powered_wire (colors[i], pos, exclude_pos, check_self, cl) then
				powered[#powered + 1] = colors[i]
			end
		end

		if #powered > 0 then
			return powered
		end
	end

	return nil
end



-- returns list of adjacent sides that have power to them
local function get_powered_directions (color, pos, check_list)
	local sides = { }
	local spos = minetest.pos_to_string (pos, 0)
	check_list = check_list or { }

	if not check_list[spos] then
		power_found = false
		check_list[spos] = true

		for i = 1, #powered_coords, 1 do
			local con_color, con_type, con_mesecons = color, "wire", true
			local wires = utils.get_wires_interface (pos)

			if wires and wires.type then
				con_color = wires.color
				con_type = wires.type
				con_mesecons = false
			end

			for_each_recurse (color, vector.add (pos, powered_coords[i]), pos, con_type,
									con_color, con_mesecons, check_for_power, powered_coords, check_list)

			if power_found then
				sides[#sides + 1] = powered_coords[i]
			end

			power_found = false
		end
	end

	if #sides > 0 then
		return sides
	end

	return nil
end



-- returns list of adjacent sides that do not have power to them
local function get_unpowered_directions (color, pos, check_list)
	local sides = { }
	local spos = minetest.pos_to_string (pos, 0)
	check_list = check_list or { }

	if not check_list[spos] then
		power_found = false
		check_list[spos] = true

		for i = 1, #powered_coords, 1 do
			local con_color, con_type, con_mesecons = color, "wire", true
			local wires = utils.get_wires_interface (pos)

			if wires and wires.type then
				con_color = wires.color
				con_type = wires.type
				con_mesecons = false
			end

			for_each_recurse (color, vector.add (pos, powered_coords[i]), pos, con_type,
									con_color, con_mesecons, check_for_power, powered_coords, check_list)

			if not power_found then
				sides[#sides + 1] = powered_coords[i]
			end

			power_found = false
		end
	end

	if #sides > 0 then
		return sides
	end

	return nil
end



-- turn on -------------------------------------------------------------



-- returns list of adjacent sides that are turned off
local function get_switchable_sides_on (pos)
	local rules = { }

	for i = 1, #switch_coords do
		local node = utils.get_far_node (vector.add (pos, switch_coords[i]))

		if is_mesecons_off (node) then
			rules[#rules + 1] = table.copy (switch_coords[i])
		end
	end

	if #rules > 0 then
		return rules
	end

	return nil
end



-- switch all adjacent nodes that are off to on
local function switch_pos_on (pos)
	local rules = get_switchable_sides_on (pos)

	if rules then
		mesecon.receptor_on (pos, rules)
	end
end



-- callback for for_each
-- returns continue, checked, con_type, con_color, is_mesecons
local function turn_wire_on (color, pos, caller_pos, caller_type,
									  caller_color, is_mesecons, check_list)
	local node, wires, mese = utils.get_component_interface (pos)

	if wires then
		if wires.type == "bundle" then
			if caller_type == "bundle" and caller_color ~= wires.color then
				return false, false, wires.type, wires.color, false
			end

			add_node_notify_on (pos)

			return true, true, wires.type, wires.color, false
		end

		if wires.type == "wire" and wires.color == color then
			local rules = get_switchable_sides_on (pos)

			if rules then
				mesecon.receptor_on (pos, rules)
			end

			return true, true, wires.type, wires.color, false
		end
	end

	return false, true, caller_type, caller_color, is_mesecons
end



-- turn power on at pos, must be wire or bundle
-- if src_pos is give will not be notified
function connections.turn_on (src_pos, wires, pos, bundle)
	local spos = minetest.pos_to_string (pos, 0)
	local inter = utils.get_wires_interface (pos)

	if inter then
		local colors = utils.wires_to_color_list (wires)
		local action_wires = colors
		local action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

		for i = 1, #colors, 1 do
			local sides = get_unpowered_directions (colors[i], pos)
			local check_list = { [spos] = true }

			if sides then
				for j = 1, #sides, 1 do
					for_each (colors[i], vector.add (pos, sides[j]),
								 turn_wire_on, false, powered_coords, check_list)
				end
			end
		end

		switch_pos_on (pos)

		notify_on (action_wires, action_pos)
	end
end



-- called from queued mesecons function in on_construct
function connections.on_construct_wire (color, pos)
	local spos = minetest.pos_to_string (pos, 0)
	local wires = utils.get_wires_interface (pos)

	if wires and wires.type == "wire" then
		local sides_on = get_powered_directions (color, pos)

		local action_wires = { color }
		local action_pos = minetest.pos_to_string (pos, 0)

		if sides_on then
			for j = 1, #switch_coords, 1 do
				for_each (color, vector.add (pos, switch_coords[j]),
							 turn_wire_on, false, powered_coords, { [spos] = true })
			end

			switch_pos_on (pos)
		end

		notify_on (action_wires, action_pos)
	end
end



-- call from on_construct
function connections.on_construct_bundle (pos)
	local spos = minetest.pos_to_string (pos, 0)
	local wires = utils.get_wires_interface (pos)

	if wires and wires.type == "bundle" then
		local action_wires = utils.color_string_list ()
		local action_pos = spos

		for i = 1, #action_wires, 1 do
			local sides_on = get_powered_directions (action_wires[i], pos)

			if sides_on then
				sides_on = { }

				for j = 1, #switch_coords, 1 do
					local twires = utils.get_wires_interface (vector.add (pos, switch_coords[j]))

					if not twires or not twires.type or twires.type ~= "bundle" or
						(twires.type == "bundle" and twires.color == wires.color) then

						sides_on[#sides_on + 1] = switch_coords[j]
					end
				end

				for j = 1, #sides_on, 1 do
					for_each (action_wires[i], vector.add (pos, sides_on[j]),
								 turn_wire_on, false, powered_coords, { [spos] = true })
				end
			end
		end

		notify_on (action_wires, action_pos)
	end
end



-- called from global on_placenode
function connections.global_on_placenode (pos, node)
	local def = minetest.registered_nodes[node.name]

	if def and def.mesecons and
		(def.mesecons.conductor or def.mesecons.effector) then

		for i = 1, #powered_coords, 1 do
			local tpos = vector.add (pos, powered_coords[i])
			local wires = utils.get_wires_interface (tpos)

			if wires and wires.type and wires.type == "wire" and
				is_pos_powered (wires.color, tpos, pos, false, { }) then

				if def.mesecons.conductor then
					mesecon.receptor_on (tpos, { vector.subtract (pos, tpos) })

				elseif def.mesecons.effector then
					local rules = mesecon.effector_get_rules (node)

					if rules then
						for _, v in ipairs (rules) do
							if vector.equals (vector.add (pos, v), tpos) then
								mesecon.receptor_on (tpos, { vector.subtract (pos, tpos) })

								return
							end
						end
					end
				end
			end
		end
	end
end



-- turn off ------------------------------------------------------------



-- returns list of adjacent sides that are turned on
local function get_switchable_sides_off (pos)
	local rules = { }

	for i = 1, #switch_coords do
		local node = utils.get_far_node (vector.add (pos, switch_coords[i]))

		if is_mesecons_on (node) then
			rules[#rules + 1] = table.copy (switch_coords[i])
		end
	end

	if #rules > 0 then
		return rules
	end

	return nil
end



-- turn off according to rules but only if not powered
local function turn_off_nodes (pos, rules, check_list)
	check_list = check_list or { }

	for i = #rules, 1, -1 do
		local tpos = vector.add (pos, rules[i])
		local cl = table.copy (check_list)
		local power = is_pos_powered (nil, tpos, pos, false, cl)

		if power then
			table.remove (rules, i)
		end
	end

	if #rules > 0 then
		mesecon.receptor_off (pos, rules)
	end
end



-- callback for for_each
-- returns continue, checked, con_type, con_color, is_mesecons
local function turn_wire_off (color, pos, caller_pos, caller_type,
										caller_color, is_mesecons, check_list)
	local node, wires, mese = utils.get_component_interface (pos)

	if wires then
		if wires.type == "bundle" then
			if caller_type == "bundle" and caller_color ~= wires.color then
				return false, false, wires.type, wires.color, false
			end

			add_node_notify_off (pos)

			return true, true, wires.type, wires.color, false
		end

		if wires.type == "wire" and wires.color == color then
			local rules = get_switchable_sides_off (pos)

			if rules then
				turn_off_nodes (pos, rules, check_list)
			end

			return true, true, wires.type, wires.color, false
		end
	end

	return false, true, caller_type, caller_color, is_mesecons
end



-- switch all adjacent nodes that are on to off but only if not powered
local function switch_pos_off (pos)
	local rules = get_switchable_sides_off (pos)

	if rules then
		turn_off_nodes (pos, rules)
	end
end



-- turn power off at pos, must be wire or bundle
-- if src_pos is give will not be notified
function connections.turn_off (src_pos, wires, pos, bundle)
	local spos = minetest.pos_to_string (pos, 0)
	local inter = utils.get_wires_interface (pos)

	if inter then
		local colors = utils.wires_to_color_list (wires)

		local action_wires = colors
		local action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

		for i = 1, #colors, 1 do
			local sides = get_unpowered_directions (colors[i], pos)

			if sides then
				for j = 1, #sides, 1 do
					for_each (colors[i], vector.add (pos, sides[j]),
								 turn_wire_off, false, powered_coords, { })
				end
			end
		end

		switch_pos_off (pos)

		notify_off (action_wires, action_pos)
	end
end



-- turn power off, exclusively for wire mesecons.action_off
function connections.turn_off_wire (color, pos)
	local sides_on = get_powered_directions (color, pos)

	if sides_on then
		switch_pos_on (pos)
	else
		connections.turn_off (pos, { color }, pos, false)
	end
end



-- called from on_destruct
function connections.on_destruct_wire (color, pos)
	local spos = minetest.pos_to_string (pos, 0)
	local wires = utils.get_wires_interface (pos)

	if wires and wires.type == "wire" then
		local switch_off_rules = { }

		local action_wires = { color }
		local action_pos = spos

		for i = 1, #powered_coords, 1 do
			local tpos = vector.add (pos, powered_coords[i])

			if is_mesecons_component (tpos) then
				if not is_pos_powered (nil, tpos, pos, true, { }) then
					switch_off_rules[#switch_off_rules + 1] = powered_coords[i]
				end
			end
		end

		local sides_off = { }

		for i = 1, #powered_coords, 1 do
			if not is_pos_powered (color, vector.add (pos, powered_coords[i]),
										  pos, true, { }) then
				sides_off[#sides_off + 1] = powered_coords[i]
			end
		end

		if sides_off then
			for i = 1, #sides_off, 1 do
				for_each (color, vector.add (pos, sides_off[i]), turn_wire_off,
							 false, powered_coords, { [spos] = true })
			end
		end

		if #switch_off_rules > 0 then
			turn_off_nodes (pos, switch_off_rules, { [spos] = true })
		end

		notify_off (action_wires, action_pos)
	end
end



-- called from queued mesecons function in on_destruct
function connections.on_destruct_bundle (color, pos)
	local spos = minetest.pos_to_string (pos, 0)
	local action_wires = utils.color_string_list ()
	local action_pos = spos

	for i = 1, #action_wires, 1 do
		local sides_off = { }

		for j = 1, #powered_coords, 1 do
			if not is_pos_powered (action_wires[i], vector.add(pos, powered_coords[j]),
										  pos, false, { [spos] = true }) then
				sides_off[#sides_off + 1] = powered_coords[j]
			end
		end

		local sides = { }

		for j = 1, #sides_off, 1 do
			local twires = utils.get_wires_interface (vector.add (pos, sides_off[j]))

			if not twires or not twires.type or twires.type ~= "bundle" or
				(twires.type == "bundle" and twires.color == color) then

				sides[#sides + 1] = sides_off[j]
			end
		end


		for j = 1, #sides, 1 do
			for_each (action_wires[i], vector.add (pos, sides[j]),
						 turn_wire_off, false, powered_coords, { [spos] = true })
		end
	end

	notify_off (action_wires, action_pos)
end



-- queries -------------------------------------------------------------



-- returns table of power state at pos
-- in table key is color string and value is true/false
function connections.power_at_pos (wires, pos)
	local colors = utils.wires_to_color_list (wires)
	local result = { }

	for i = 1, #colors, 1 do
		local sides = get_powered_directions (colors[i], pos)

		if sides then
			result[colors[i]] = true
		elseif result[colors[i]] == nil then
			result[colors[i]] = false
		end
	end

	return result
end



-- init ----------------------------------------------------------------



utils.wire_connections = connections



--
