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

	if not check_list[spos] then
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
		local _, wires, mese = utils.get_component_interface (pos)

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



-- notifications -------------------------------------------------------



local notify_on_positions = { }
local notify_off_positions = { }



local function add_node_notify_on (pos, color)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		local wires = utils.get_wires_interface (test_pos)

		if wires and wires.bundle_on then
			local stest_pos = minetest.pos_to_string (test_pos, 0)
			local list = notify_on_positions[stest_pos]

			if not list then
				notify_on_positions[stest_pos] = { }
				list = notify_on_positions[stest_pos]
				list.bundle_pos = vector.new (pos)
			end

			list[color] = true
		end
	end
end



local function add_node_notify_off (pos, color)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		local wires = utils.get_wires_interface (test_pos)

		if wires and wires.bundle_off then
			local stest_pos = minetest.pos_to_string (test_pos, 0)
			local list = notify_off_positions[stest_pos]

			if not list then
				notify_off_positions[stest_pos] = { }
				list = notify_off_positions[stest_pos]
				list.bundle_pos = vector.new (pos)
			end

			list[color] = true
		end
	end
end



local function notify (action_wires, action_pos)
	for k, v in pairs (notify_off_positions) do
		if k ~= action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local wires = utils.get_wires_interface (pos)

				if wires and wires.bundle_off then
					local colors = { }

					for color, _ in pairs (v) do
						if color ~= "bundle_pos" then
							colors[#colors + 1] = color
						end
					end

					wires.bundle_off (pos, colors, v.bundle_pos)
				end
			end
		end
	end

	notify_off_positions = { }

	for k, v in pairs (notify_on_positions) do
		if k ~= action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local wires = utils.get_wires_interface (pos)

				if wires and wires.bundle_on then
					local colors = { }

					for color, _ in pairs (v) do
						if color ~= "bundle_pos" then
							colors[#colors + 1] = color
						end
					end

					wires.bundle_on (pos, colors, v.bundle_pos)
				end
			end
		end
	end

	notify_on_positions = { }
end



-- mesecons integration ------------------------------------------------



local function get_mesecons_rules (src_rules, rules_node)
	if src_rules then
		if type (src_rules) == "function" then
			return src_rules (rules_node)
		end
	else
		return mesecon.rules.default
	end

	return src_rules
end



-- get flattened linked rules from pos to linked_pos
local function get_linked_rules (pos, linked_pos, src_rules, rules_node)
	local rules = get_mesecons_rules (src_rules, rules_node)
	local linked = { }
	local rule = nil

	if #rules > 0 and #rules[1] > 0 then
		-- as individual rule sets
		for _, rs in ipairs (rules) do
			for _, r in ipairs (rs) do
				if r.x and r.y and r.z and vector.equals (linked_pos, vector.add (pos, r)) then
					linked[#linked + 1] = table.copy (rs)
					rule = table.copy (r)

					break
				end
			end
		end

	else
		for _, r in ipairs (rules) do
			if r.x and r.y and r.z and vector.equals (linked_pos, vector.add (pos, r)) then
				linked = table.copy (rules)
				rule = table.copy (r)

				break
			end
		end
	end

	if #linked > 0 then
		return mesecon.flattenrules (linked, rules_node), rule
	end

	return nil, nil
end



-- does pos at rule connect back by its rules
local function is_connected_by_rule (pos, rule, conductors, receptors, effectors)
	if rule.x and rule.y and rule.z then
		local tpos = vector.add (pos, rule)
		local node, wire, mese = utils.get_component_interface (tpos)

		if wire then
			return (rule.y ~= 0 and rule.x == 0 and rule.z == 0) or
					 (rule.y == 0 and rule.x ~= 0 and rule.z == 0) or
					 (rule.y == 0 and rule.x == 0 and rule.z ~= 0)
		end

		if mese then
			if conductors and mese.conductor then
				local _, r = get_linked_rules (tpos, pos, mese.conductor.rules, node)

				if r then
					return true
				end

			elseif receptors and mese.receptor then
				local _, r = get_linked_rules (tpos, pos, mese.receptor.rules, node)

				if r then
					return true
				end

			elseif effectors and mese.effector then
				local _, r = get_linked_rules (tpos, pos, mese.effector.rules, node)

				if r then
					return true
				end

			end
		end
	end

	return false
end



-- does pos at any rule connect back by its rules
local function is_connected_by_rules (pos, connect_pos, test, test_back)
	local node, wires, mese = utils.get_component_interface (pos)

	if wires then
		return true
	end

	local conductors = (test_back and test_back.conductors) or false
	local receptors = (test_back and test_back.receptors) or false
	local effectors = (test_back and test_back.effectors) or false
	local one_way = test_back == nil

	if mese then
		if test.conductors and mese.conductor then
			local _, r = get_linked_rules (pos, connect_pos, mese.conductor.rules, node)

			if r then
				if one_way then
					return true
				else
					return is_connected_by_rule (pos, r, conductors, receptors, effectors)
				end
			end
		end

		if test.receptors and mese.receptor then
			local _, r = get_linked_rules (pos, connect_pos, mese.receptor.rules, node)

			if r then
				if one_way then
					return true
				else
					return is_connected_by_rule (pos, r, conductors, receptors, effectors)
				end
			end
		end

		if test.effectors and mese.effector then
			local _, r = get_linked_rules (pos, connect_pos, mese.effector.rules, node)

			if r then
				if one_way then
					return true
				else
					return is_connected_by_rule (pos, r, conductors, receptors, effectors)
				end
			end
		end
	end

	return false
end



local function is_conductor_on (conductor, node, pos, ref_pos)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.on
		end

		if conductor.states then
			if not ref_pos then
				return mesecon.getstate (node.name, conductor.states) ~= 1
			end

			local rulename = vector.subtract (ref_pos, pos)

			local bit = mesecon.rule2bit (rulename, get_mesecons_rules (conductor.rules, node))
			local binstate = mesecon.getbinstate (node.name, conductor.states)

			return mesecon.get_bit (binstate, bit)
		end
	end

	return false
end



local function is_conductor_off (conductor, node, pos, ref_pos)
	if conductor then
		if conductor.state then
			return conductor.state == mesecon.state.off
		end

		if conductor.states then
			if not ref_pos then
				return mesecon.getstate (node.name, conductor.states) == 1
			end

			local rulename = vector.subtract (ref_pos, pos)
			local bit = mesecon.rule2bit (rulename, get_mesecons_rules (conductor.rules, node))
			local binstate = mesecon.getbinstate (node.name, conductor.states)

			return not mesecon.get_bit (binstate, bit)
		end
	end

	return false
end



-- is mesecons turned on
local function is_mesecons_on (pos, connect_pos, conductors, receptors, effectors)
	local node, wires, mese = utils.get_component_interface (pos)

	if not wires and mese then
		local test =
		{
			conductors = conductors and mese.conductor and
							 is_conductor_on (mese.conductor, node, pos, connect_pos),
			receptors = receptors and mese.receptor and
							mese.receptor.state == mesecon.state.on,
			effectors = effectors and mese.effector and
							(mese.effector.action_off or mese.effector.action_change)
		}

		return is_connected_by_rules (pos, connect_pos, test, nil)
	end

	return false
end



-- is any mesecons turned off
local function is_mesecons_off (pos, connect_pos, conductors, receptors, effectors)
	local node, wires, mese = utils.get_component_interface (pos)

	if not wires and mese then
		local test =
		{
			conductors = conductors and mese.conductor and
							 is_conductor_off (mese.conductor, node, pos, connect_pos),
			receptors = receptors and mese.receptor and
							mese.receptor.state == mesecon.state.off,
			effectors = effectors and mese.effector and
							(mese.effector.action_on or mese.effector.action_change)
		}

		return is_connected_by_rules (pos, connect_pos, test, nil)
	end

	return false
end



-- is mesecons power state on
local function is_mesecons_power (pos, connect_pos)
	local _, wires, mese = utils.get_component_interface (pos)

	if not wires and mese and mese.receptor and
			mese.receptor.state == mesecon.state.on then

		if connect_pos then
			return is_connected_by_rules (pos, connect_pos, { receptors = true }, nil)
		end

		return true
	end

	return false
end



-- is a mesecons component
local function is_mesecons_component (pos)
	local _, wires, mese = utils.get_component_interface (pos)

	return not wires and mese ~= nil
end



local function action_mesecons_effector (pos, rule, newstate)
	local node, wire, mese = utils.get_component_interface (pos)

	if not wire and mese and mese.effector and mese.effector.action_change then
		local _, r = get_linked_rules (pos, vector.subtract (pos, rule), mese.effector.rules, node)

		if r then
			mese.effector.action_change (pos, node, r, newstate)

			return true
		end
	end

	return false
end



local function mesecon_receptor_off (pos, rules)
	rules = rules or mesecon.rules.default

	-- Call turnoff on all linking positions
	for _, rule in ipairs (mesecon.flattenrules (rules)) do
		local np = vector.add (pos, rule)
		local rulenames = mesecon.rules_link_rule_all (pos, rule)

		for _, rulename in ipairs (rulenames) do
			mesecon.vm_begin ()
			mesecon.changesignal (np, minetest.get_node (np), rulename, mesecon.state.off, 2)

			-- Turnoff returns true if turnoff process was successful, no onstate receptor
			-- was found along the way. Commit changes that were made in voxelmanip. If turnoff
			-- returns true, an onstate receptor was found, abort voxelmanip transaction.
			if (mesecon.turnoff (np, rulename)) then
				mesecon.vm_commit ()
			else
				mesecon.vm_abort ()
			end
		end
	end
end



local function mesecon_receptor_on (pos, rules)
	mesecon.vm_begin ()

	rules = rules or mesecon.rules.default

	-- Call turnon on all linking positions
	for _, rule in ipairs (mesecon.flattenrules (rules)) do
		local np = vector.add (pos, rule)
		local rulenames = mesecon.rules_link_rule_all (pos, rule)

		for _, rulename in ipairs (rulenames) do
			mesecon.turnon (np, rulename)
		end
	end

	mesecon.vm_commit ()
end



-- action queue --------------------------------------------------------



local action_queue = { }



local function add_action_queue (action, pos, rules)
	for i = #action_queue, 1, -1 do
		if	vector.equals (pos, action_queue[i].pos) and
			minetest.serialize (rules) == minetest.serialize (action_queue[i].rules) then

			table.remove (action_queue, i)
		end
	end

	action_queue[#action_queue + 1] =
	{
		action = action,
		pos = pos,
		rules = rules
	}
end



local function queue_receptor_on (pos, rules)
	add_action_queue ("receptor_on", pos, rules)
end



local function queue_receptor_off (pos, rules)
	add_action_queue ("receptor_off", pos, rules)
end



function connections.execute_action_queue (pos)
	for _, e in ipairs (action_queue) do
		if e.action == "receptor_on" then
			mesecon_receptor_on (e.pos, e.rules)
		elseif e.action == "receptor_off" then
			mesecon_receptor_off (e.pos, e.rules)
		end
	end

	action_queue = { }
end



local function run_action_queue (pos)
	mesecon.queue:add_action (vector.new (pos),
									  "lwwires_execute_action_queue",
									  { }, nil, nil, 0)
end



-- circuit analysis ----------------------------------------------------



local power_found = false



-- look for adjacent bundle power source
local function find_bundle_power_source (pos, color, check_list)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])

		local wires = utils.get_wires_interface (test_pos)

		if wires and wires.current_state then
			local state = wires.current_state (test_pos, vector.new (pos))

			if type (state) == "table" then
				if state[color] then
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
			local tb = (is_mesecons and { conductors = true }) or nil

			if is_connected_by_rules (pos, caller_pos, { receptors = true }, tb) then
				power_found = true

				return false, false, caller_type, caller_color, true
			else
				return false, false, caller_type, caller_color, true
			end
		end

		if mese.conductor and is_conductor_on (mese.conductor, node, pos, caller_pos) then
			local rules = get_linked_rules (pos, caller_pos, mese.conductor.rules, node)

			local raw_rules = get_mesecons_rules (mese.conductor.rules, node)
			if not raw_rules[1] or raw_rules[1].x then
				check_list[minetest.pos_to_string (pos, 0)] = true
			end

			if rules then
				for _, r in ipairs (rules) do
					if is_connected_by_rule (pos, r, true, true, false) then
						for_each_recurse (color, vector.add (pos, r), pos, caller_type,
												caller_color, true, check_for_power, powered_coords, check_list)

						if power_found then
							return false, true, caller_type, caller_color, true
						end
					end
				end
			end
		end

		if mese.effector then
			return false, true, caller_type, caller_color, true
		end

	end

	return false, true, caller_type, caller_color, false
end



-- check single color
local function is_pos_powered_wire (color, pos, exclude_pos, check_self, check_list)
	if check_self then
		if is_mesecons_power (pos, exclude_pos) then
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

			if mese.effector then
				local rules = get_mesecons_rules (mese.effector.rules, node)

				if rules then
					rules = mesecon.flattenrules (rules)

					check_list[spos] = true

					for _, r in ipairs (rules) do
						if is_connected_by_rule (pos, r, true, true, false) then
							for_each_recurse (color, vector.add (pos, r), pos, "wire", color,
													true, check_for_power, powered_coords, check_list)
						end

						if power_found then
							power_found = false

							return true
						end
					end
				end
			else
				for_each (color, pos, check_for_power, not check_self, powered_coords, check_list)

				if power_found then
					power_found = false

					return true
				end
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
		if is_mesecons_power (pos, exclude_pos) then
			return "mesecons"
		end
	end

	if color then
		if is_pos_powered_wire (color, pos, exclude_pos, false, check_list) then
			return color
		end
	else
		local colors = utils.color_string_list ()
		local powered = { }

		for i = 1, #colors, 1 do
			local cl = table.copy (check_list)

			if is_pos_powered_wire (colors[i], pos, exclude_pos, false, cl) then
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


--[[
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
]]


-- turn on -------------------------------------------------------------



-- returns list of adjacent sides that are turned off
local function get_switchable_sides_on (pos)
	local rules = { }

	for i = 1, #powered_coords do
		local tpos = vector.add (pos, powered_coords[i])

		if is_mesecons_off (tpos, pos, true, false, true) then
			rules[#rules + 1] = table.copy (powered_coords[i])
		end
	end

	if #rules > 0 then
		return rules
	end

	return nil
end



-- turn off according to rules but only if not powered
local function turn_on_nodes (pos, rules)
	for i = #rules, 1, -1 do
		local tpos = vector.add (pos, rules[i])

		if action_mesecons_effector (tpos, rules[i], mesecon.state.on) then
			table.remove (rules, i)
		end
	end

	if #rules > 0 then
		queue_receptor_on (pos, rules)
	end
end



-- switch all adjacent nodes that are off to on
local function switch_pos_on (pos)
	local rules = get_switchable_sides_on (pos)

	if rules then
		turn_on_nodes (pos, rules)
	end
end



-- callback for for_each
-- returns continue, checked, con_type, con_color, is_mesecons
local function turn_wire_on (color, pos, caller_pos, caller_type,
									  caller_color, is_mesecons, check_list)
	local _, wires = utils.get_component_interface (pos)

	if wires then
		if wires.type == "bundle" then
			if caller_type == "bundle" and caller_color ~= wires.color then
				return false, false, wires.type, wires.color, false
			end

			add_node_notify_on (pos, color)

			return true, true, wires.type, wires.color, false
		end

		if wires.type == "wire" and wires.color == color then
			local rules = get_switchable_sides_on (pos)

			if rules then
				turn_on_nodes (pos, rules)
			end

			return true, true, wires.type, wires.color, false
		end
	end

	return false, true, caller_type, caller_color, is_mesecons
end



-- turn power on at pos, must be wire or bundle
-- if src_pos is give will not be notified
function connections.turn_on (src_pos, wires, pos)
	local inter = utils.get_wires_interface (pos)

	if inter then
		local action_wires = utils.wires_to_color_list (wires)
		local action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

		for i = 1, #action_wires, 1 do
			if not is_pos_powered_wire (action_wires[i], pos, src_pos, true, { }) then
				for_each (action_wires[i], pos, turn_wire_on, false, powered_coords, { })
			end
		end

		switch_pos_on (pos)

		notify (action_wires, action_pos)

		run_action_queue (src_pos or pos)
	end
end



-- turn power on, exclusively for wire mesecons.action_on
function connections.turn_on_wire (color, pos, rule)
	local src_pos = nil

	if rule and rule.x then
		src_pos = vector.add (pos, rule)
	end

	connections.turn_on (src_pos, color, pos)
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
			for j = 1, #powered_coords, 1 do
				for_each (color, vector.add (pos, powered_coords[j]),
							 turn_wire_on, false, powered_coords, { [spos] = true })
			end

			switch_pos_on (pos)
		end

		notify (action_wires, action_pos)

		run_action_queue (pos)
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

				for j = 1, #powered_coords, 1 do
					local twires = utils.get_wires_interface (vector.add (pos, powered_coords[j]))

					if not twires or not twires.type or twires.type ~= "bundle" or
						(twires.type == "bundle" and twires.color == wires.color) then

						sides_on[#sides_on + 1] = powered_coords[j]
					end
				end

				for j = 1, #sides_on, 1 do
					for_each (action_wires[i], vector.add (pos, sides_on[j]),
								 turn_wire_on, false, powered_coords, { [spos] = true })
				end
			end
		end

		notify (action_wires, action_pos)

		run_action_queue (pos)
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

	for i = 1, #powered_coords do
		local tpos = vector.add (pos, powered_coords[i])

		if is_mesecons_on (tpos, pos, true, false, true) then
			rules[#rules + 1] = table.copy (powered_coords[i])
		end
	end

	if #rules > 0 then
		return rules
	end

	return nil
end



-- turn off according to rules but only if not powered
local function turn_off_nodes (color, pos, rules, check_list)
	check_list = check_list or { }

	for i = #rules, 1, -1 do
		local tpos = vector.add (pos, rules[i])

		if action_mesecons_effector (tpos, rules[i], mesecon.state.off) then
			table.remove (rules, i)
		else
			local cl = table.copy (check_list)
			local power = is_pos_powered (color, tpos, pos, true, cl)

			if power then
				table.remove (rules, i)
			end
		end
	end

	if #rules > 0 then
		queue_receptor_off (pos, rules)
	end
end



-- callback for for_each
-- returns continue, checked, con_type, con_color, is_mesecons
local function turn_wire_off (color, pos, caller_pos, caller_type,
										caller_color, is_mesecons, check_list)
	local _, wires = utils.get_component_interface (pos)

	if wires then
		if wires.type == "bundle" then
			if caller_type == "bundle" and caller_color ~= wires.color then
				return false, false, wires.type, wires.color, false
			end

			add_node_notify_off (pos, color)

			return true, true, wires.type, wires.color, false
		end

		if wires.type == "wire" and wires.color == color then
			local rules = get_switchable_sides_off (pos)

			if rules then
				turn_off_nodes (color, pos, rules, check_list)
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
		turn_off_nodes (nil, pos, rules)
	end
end



-- turn power off at pos, must be wire or bundle
-- if src_pos is give will not be notified
function connections.turn_off (src_pos, wires, pos)
	local inter = utils.get_wires_interface (pos)

	if inter then
		local action_wires = utils.wires_to_color_list (wires)
		local action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

		for i = 1, #action_wires, 1 do
			if not is_pos_powered_wire (action_wires[i], pos, src_pos, true, { }) then
				for_each (action_wires[i], pos, turn_wire_off, false, powered_coords, { })
			end
		end

		switch_pos_off (pos)

		notify (action_wires, action_pos)

		run_action_queue (src_pos)
	end
end



-- turn power off, exclusively for wire mesecons.action_off
function connections.turn_off_wire (color, pos, rule)
	local sides_on = get_powered_directions (color, pos)

	if sides_on then
		switch_pos_on (pos)
		run_action_queue (pos)
		notify ({ color }, minetest.pos_to_string (pos))
	else
		connections.turn_off (pos, { color }, pos)
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
			turn_off_nodes (color, pos, switch_off_rules, { [spos] = true })
		end

		notify (action_wires, action_pos)

		run_action_queue (pos)
	end
end



-- called from queued mesecons function in on_blast
function connections.on_blast_wire (color, pos)
	local spos = minetest.pos_to_string (pos, 0)
	local action_wires = { color }
	local action_pos = spos

	for i = 1, #action_wires, 1 do
		local sides_off = { }

		for j = 1, #powered_coords, 1 do
			if not is_pos_powered (color, vector.add(pos, powered_coords[j]),
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
			for_each (color, vector.add (pos, sides[j]),
						 turn_wire_off, false, powered_coords, { [spos] = true })
		end
	end

	notify (action_wires, action_pos)

	run_action_queue (pos)
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

	notify (action_wires, action_pos)

	run_action_queue (pos)
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
