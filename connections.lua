local utils, mod_storage = ...



local connections = { }



function connections:new (mod_storage, name)
	local obj = { }

   setmetatable (obj, self)
   self.__index = self

   obj.connector_list = { }
   obj.name = tostring (name)
   obj.storage = mod_storage
   obj.power_found = false
   obj.power_source_checked = { }
   obj.action_pos = nil
   obj.action_wires = { }
   obj.notify_positions = { }

	if mod_storage then
		local stored = mod_storage:get_string (obj.name)

		if stored == "" then
			stored = "{ }"
		end

		obj.connector_list = minetest.deserialize (stored)

		if not obj.connector_list then
			obj.connector_list = { }
		end
	end

	obj:uncheck_all ()

	return obj
end



function connections:load ()
	if self.storage then
		local stored = self.storage:get_string (self.name)

		if stored == "" then
			stored = "{ }"
		end

		self.connector_list = minetest.deserialize (stored)

		self:uncheck_all ()
	end
end



function connections:store ()
	if self.storage then
		self.storage:set_string (self.name, minetest.serialize (self.connector_list))
	end
end



function connections:add_node (pos, id, color)
	self.connector_list[minetest.pos_to_string (pos, 0)] =
	{
		id = (id and tostring (id)) or nil,
		color = (color and tostring (color)) or nil,
		checked = false
	}

	self:store ()
end



function connections:remove_node (pos)
	self.connector_list[minetest.pos_to_string (pos, 0)] = nil

	self:store ()
end



function connections:uncheck_all ()
	for k, v in pairs (self.connector_list) do
		v.checked = false
	end
end



local function for_each (self, color, pos, caller_id, caller_color, caller_pos, func, test_coords)
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		local continue, checked = func (self, color, pos, con.id, con.color, caller_pos, caller_id, caller_color)

		con.checked = checked

		if not continue then
			return
		end

		for i = 1, #test_coords do
			for_each (self, color, vector.add (pos, test_coords[i]), con.id, con.color, pos, func, test_coords)
		end
	end
end



function connections:for_each (color, pos, func, bundle)
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		local test_coords =
		{
			{ x =  1, y =  0, z =  0 },
			{ x = -1, y =  0, z =  0 },
			{ x =  0, y =  0, z =  1 },
			{ x =  0, y =  0, z = -1 },
			{ x =  0, y =  1, z =  0 },
			{ x =  0, y = -1, z =  0 }
		}

		local continue, checked = true, true

		if not bundle then
			continue, checked = func (self, color, pos, con.id, con.color, pos, con.id, con.color)
		end

		con.checked = checked

		if not continue then
			return
		end

		for i = 1, #test_coords do
			for_each (self, color, vector.add (pos, test_coords[i]), con.id, con.color, pos, func, test_coords)
		end
	end
end



-- operations



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



local function add_node_notify_on (self, pos)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		local node = utils.get_far_node (test_pos)

		if node then
			local def = minetest.registered_nodes[node.name]

			if def and def._wires and def._wires.bundle_on then
				local spos = minetest.pos_to_string (test_pos, 0)

				if not self.notify_positions[spos] then
					self.notify_positions[spos] = true
				end
			end
		end
	end
end



local function add_node_notify_off (self, pos)
	for i = 1, #switch_coords, 1 do
		local test_pos = vector.add (pos, switch_coords[i])
		local node = utils.get_far_node (test_pos)

		if node then
			local def = minetest.registered_nodes[node.name]

			if def and def._wires and def._wires.bundle_off then
				local spos = minetest.pos_to_string (test_pos, 0)

				if not self.notify_positions[spos] then
					self.notify_positions[spos] = true
				end
			end
		end
	end
end



local function notify_on (self)
	for k, _ in pairs (self.notify_positions) do
		if k ~= self.action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local node = utils.get_far_node (pos)

				if node then
					local def = minetest.registered_nodes[node.name]

					if def and def._wires and def._wires.bundle_on then
						def._wires.bundle_on (pos, table.copy (self.action_wires))
					end
				end
			end
		end
	end

	self.action_pos = nil
	self.notify_positions = { }
	self.action_wires = { }
end



local function notify_off (self)
	for k, _ in pairs (self.notify_positions) do
		if k ~= self.action_pos then
			local pos = minetest.string_to_pos (k)

			if pos then
				local node = utils.get_far_node (pos)

				if node then
					local def = minetest.registered_nodes[node.name]

					if def and def._wires and def._wires.bundle_off then
						def._wires.bundle_off (pos, table.copy (self.action_wires))
					end
				end
			end
		end
	end

	self.action_pos = nil
	self.notify_positions = { }
	self.action_wires = { }
end



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



local function find_bundle_power_source (self, pos, color)
	for i = 1, #powered_coords, 1 do
		local test_pos = vector.add (pos, powered_coords[i])
		local spos = minetest.pos_to_string (test_pos, 0)

		if self.power_source_checked[spos] then
			return false
		end

		self.power_source_checked[spos] = true

		local node = utils.get_far_node (test_pos)

		if node then
			local def = minetest.registered_nodes[node.name]

			if def and def._wires and def._wires.current_state then
				local state = def._wires.current_state (test_pos, vector.new (pos))

				if type (state) == "table" then
					if state[color] then
						return true
					end
				end
			end
		end
	end

	return false
end



local function find_power_source_worker (self, pos, is_mesecons)
	local spos = minetest.pos_to_string (pos, 0)

	if self.power_source_checked[spos] then
		return false
	end

	self.power_source_checked[spos] = true

	local node = utils.get_far_node (pos)

	if node then
		local def = minetest.registered_nodes[node.name]

		if def then
			if minetest.get_item_group (node.name, "lwwires_wire") > 0 then
				if is_mesecons then
					-- new wire circuit
					local new_color = string.sub (node.name, 9)

					if self:continue_powered_directions (new_color, pos) then
						return true
					end
				end
			end

			if def.mesecons and def.mesecons.receptor and
				def.mesecons.receptor.state == mesecon.state.on then

				return true
			end

			if def.mesecons and def.mesecons.conductor then
				local conductor_on = false

				if def.mesecons.conductor.state then
					conductor_on = def.mesecons.conductor.state == mesecon.state.on
				elseif def.mesecons.conductor.states then
					conductor_on = mesecon.getstate (node.name, def.mesecons.conductor.states) ~= 1
				end

				if conductor_on then
					local rules = def.mesecons.conductor.rules

					if rules then
						if type (rules) == "function" then
							rules = rules (node)
						end
					else
						rules = mesecon.rules.default
					end

					for i = 1, #rules do
						if find_power_source_worker (self, vector.add (pos, rules[i]), true) then
							return true
						end
					end
				end
			end

		end
	end

	return false
end



local function find_power_source (self, pos, color)
	self.power_source_checked[minetest.pos_to_string (pos, 0)] = true

	for i = 1, #powered_coords, 1 do
		if find_power_source_worker (self, vector.add (pos, powered_coords[i]), false) then
			self.power_source_checked = { }

			return true
		end
	end

	self.power_source_checked = { }

	return false
end



local function check_for_power (self, color, pos, connect_id, connect_color, caller_pos, caller_id, caller_color)
	if connect_id == "bundle" then
		if caller_id == "bundle" and caller_color ~= connect_color then
			return false, false
		end

		if find_bundle_power_source (self, pos, color) then
			self.power_found = true

			return false, true
		end

		return true, true
	end

	if connect_id == "wire" and connect_color == color then
		if find_power_source (self, pos, color) then
			self.power_found = true

			return false, true
		end

		return true, true
	end

	return false, true
end



function connections:continue_powered_directions (color, pos)
	local sides = { }
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		self.power_found = false

		for i = 1, #powered_coords, 1 do
			con.checked = true

			for_each (self, color, vector.add (pos, powered_coords[i]),
						 con.id, con.color, pos, check_for_power, powered_coords)

			if self.power_found then
				sides[#sides + 1] = powered_coords[i]
			end

			self.power_found = false
		end
	end

	if #sides > 0 then
		return sides
	end

	return nil
end



function connections:get_powered_directions (color, pos)
	local sides = { }
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		self.power_found = false
		con.checked = true

		for i = 1, #powered_coords, 1 do
			for_each (self, color, vector.add (pos, powered_coords[i]),
						 con.id, con.color, pos, check_for_power, powered_coords)

			if self.power_found then
				sides[#sides + 1] = powered_coords[i]
			end

			self.power_found = false
		end

		self:uncheck_all ()
	end

	if #sides > 0 then
		return sides
	end

	return nil
end



function connections:get_unpowered_directions (color, pos)
	local sides = { }
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		self.power_found = false
		con.checked = true

		for i = 1, #powered_coords, 1 do
			for_each (self, color, vector.add (pos, powered_coords[i]),
						 con.id, con.color, pos, check_for_power, powered_coords)

			if not self.power_found then
				sides[#sides + 1] = powered_coords[i]
			end

			self.power_found = false
		end

		self:uncheck_all ()
	end

	if #sides > 0 then
		return sides
	end

	return nil
end



-- turn off


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



local function turn_wire_off (self, color, pos, connect_id, connect_color, caller_pos, caller_id, caller_color)
	if connect_id == "bundle" then
		if caller_id == "bundle" and caller_color ~= connect_color then
			return false, false
		end

		add_node_notify_off (self, pos)

		return true, true
	end

	if connect_id == "wire" and connect_color == color then
		local rules = get_switchable_sides_off (pos)

		if rules then
			mesecon.receptor_off (pos, rules)
		end

		return true, true
	end

	return false, true
end



function connections:switch_pos_off (pos)
	local rules = get_switchable_sides_off (pos)

	if rules then
		mesecon.receptor_off (pos, rules)
	end
end



function connections:turn_off (src_pos, wires, pos, bundle)
	local colors = utils.wires_to_color_list (wires)

	self.action_wires = colors
	self.action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

	for i = 1, #colors, 1 do
		local sides = self:get_unpowered_directions (colors[i], pos)

		if sides then
			for j = 1, #sides, 1 do
				self:for_each (colors[i], vector.add (pos, sides[j]), turn_wire_off, false)
			end
		end

		self:uncheck_all ()
	end

	self:switch_pos_off (pos)

	notify_off (self)
end



function connections:turn_off_wire (color, pos)
	local sides_on = self:get_powered_directions (color, pos)

	if sides_on then
		self:switch_pos_on (pos)
	else
		self:turn_off (pos, { color }, pos, false)
	end
end


function connections:dig_wire (color, pos)
	local sides_off = self:get_unpowered_directions (color, pos)

	self.action_wires = { color }
	self.action_pos = minetest.pos_to_string (pos, 0)

	if sides_off then
		local con = self.connector_list[minetest.pos_to_string (pos, 0)]

		if con and not con.checked then
			con.checked = true

			for j = 1, #sides_off, 1 do
				self:for_each (color, vector.add (pos, sides_off[j]), turn_wire_off, false)
			end

			self:uncheck_all ()
		end
	end

	self:switch_pos_off (pos)

	notify_off (self)
end



function connections:dig_bundle (pos)
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		self.action_wires = utils.color_string_list ()
		self.action_pos = minetest.pos_to_string (pos, 0)

		for i = 1, #self.action_wires, 1 do
			local sides_off = self:get_unpowered_directions (self.action_wires[i], pos)

			if sides_off then
				con.checked = true

				for j = 1, #sides_off, 1 do
					self:for_each (self.action_wires[i], vector.add (pos, sides_off[j]), turn_wire_off, false)
				end

				self:uncheck_all ()
			end
		end

		notify_off (self)
	end
end



-- turn on


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



local function turn_wire_on (self, color, pos, connect_id, connect_color, caller_pos, caller_id, caller_color)
	if connect_id == "bundle" then
		if caller_id == "bundle" and caller_color ~= connect_color then
			return false, false
		end

		add_node_notify_on (self, pos)

		return true, true
	end

	if connect_id == "wire" and connect_color == color then
		local rules = get_switchable_sides_on (pos)

		if rules then
			mesecon.receptor_on (pos, rules)
		end

		return true, true
	end

	return false, true
end



function connections:switch_pos_on (pos)
	local rules = get_switchable_sides_on (pos)

	if rules then
		mesecon.receptor_on (pos, rules)
	end
end



function connections:turn_on (src_pos, wires, pos, bundle)
	local colors = utils.wires_to_color_list (wires)

	self.action_wires = colors
	self.action_pos = (src_pos and minetest.pos_to_string (src_pos, 0)) or ""

	for i = 1, #colors, 1 do
		local sides = self:get_unpowered_directions (colors[i], pos)

		if sides then
			for j = 1, #sides, 1 do
				self:for_each (colors[i], vector.add (pos, sides[j]), turn_wire_on, false)
			end
		end

		self:uncheck_all ()
	end

	self:switch_pos_on (pos)

	notify_on (self)
end



function connections:place_wire (color, pos)
	local sides_on = self:get_powered_directions (color, pos)

	self.action_wires = { color }
	self.action_pos = minetest.pos_to_string (pos, 0)

	if sides_on then
		local con = self.connector_list[minetest.pos_to_string (pos, 0)]

		if con and not con.checked then
			con.checked = true

			for j = 1, #switch_coords, 1 do
				self:for_each (color, vector.add (pos, switch_coords[j]), turn_wire_on, false)
			end

			self:uncheck_all ()
		end
	end

	self:switch_pos_on (pos)

	notify_on (self)
end



function connections:place_bundle (pos)
	local con = self.connector_list[minetest.pos_to_string (pos, 0)]

	if con and not con.checked then
		self.action_wires = utils.color_string_list ()
		self.action_pos = minetest.pos_to_string (pos, 0)

		for i = 1, #self.action_wires, 1 do
			local sides_on = self:get_powered_directions (self.action_wires[i], pos)

			if sides_on then
				con.checked = true

				for j = 1, #switch_coords, 1 do
					self:for_each (self.action_wires[i], vector.add (pos, switch_coords[j]), turn_wire_on, false)
				end

				self:uncheck_all ()
			end
		end

		notify_on (self)
	end
end



-- queries


function connections:power_at_pos (wires, pos)
	local colors = utils.wires_to_color_list (wires)
	local result = { }

	for i = 1, #colors, 1 do
		local sides = self:get_powered_directions (colors[i], pos)

		if sides then
			result[colors[i]] = true
		elseif result[colors[i]] == nil then
			result[colors[i]] = false
		end
	end

	return result
end



-- init


utils.wire_connections = connections:new (mod_storage, "lwwires_connections")



--
