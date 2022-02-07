local utils = ...
local S = utils.S


if utils.digilines_supported then



local sides =
{
	{ x =  1, y =  0, z =  0 },
	{ x = -1, y =  0, z =  0 },
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y =  1, z =  0 },
	{ x =  0, y = -1, z =  0 }
}



local function check_state_table (state)
	if type (state) ~= "table" then
		state = { }

		for k, v in pairs (utils.colors) do
			if type (k) == "string" then
				state[k] = false
			end
		end
	end

	return state
end



local function get_current_state (pos, bundle_pos)
	local meta = minetest.get_meta (pos)

	if not meta then
		return
	end

	return check_state_table (minetest.deserialize (meta:get_string ("state")))
end



local function switch_on (pos, wires)
	local meta = minetest.get_meta (pos)

	if not meta then
		return
	end

	local colors = utils.wires_to_color_list (wires)

	if #colors < 1 then
		return
	end

	local state = check_state_table (minetest.deserialize (meta:get_string ("state")))

	for i = 1, #colors, 1 do
		state[colors[i]] = true
	end

	meta:set_string ("state", minetest.serialize (state))

	for i = 1, #sides, 1 do
		lwwires.bundle_on (pos, vector.add (pos, sides[i]), colors)
	end
end



local function switch_off (pos, wires)
	local meta = minetest.get_meta (pos)

	if not meta then
		return
	end

	local colors = utils.wires_to_color_list (wires)

	if #colors < 1 then
		return
	end

	local state = check_state_table (minetest.deserialize (meta:get_string ("state")))

	for i = 1, #colors, 1 do
		state[colors[i]] = false
	end

	meta:set_string ("state", minetest.serialize (state))

	for i = 1, #sides, 1 do
		lwwires.bundle_off (pos, vector.add (pos, sides[i]), colors)
	end
end



local function send_state (pos, channel, wires)
	local meta = minetest.get_meta (pos)

	if not meta then
		return
	end

	local colors = utils.wires_to_color_list (wires)

	if not wires then
		colors = utils.color_string_list ()
	elseif #colors < 1 then
		return
	end

	local msg =
	{
		action = "current_state",
		wires = { }
	}

	local state = check_state_table (minetest.deserialize (meta:get_string ("state")))

	for i = 1, #colors, 1 do
		msg.wires[colors[i]] = state[colors[i]]
	end

	digilines.receptor_send (pos, sides, channel, msg)
end



local function send_power (pos, channel, wires)
	local msg =
	{
		action = "current_power",
		wires = { }
	}

	for i = 1, #sides, 1 do
		local result = lwwires.bundle_power (vector.add (pos, sides[i]), wires)

		if result then
			if #msg.wires < 1 then
				msg.wires = result
			else
				for k, v in pairs (result) do
					if v then
						msg.wires[k] = v
					end
				end
			end
		end
	end

	digilines.receptor_send (pos, sides, channel, msg)
end



local function send_bundle_on (pos, wires)
	local meta = minetest.get_meta (pos)

	if meta then
		local channel = meta:get_string ("channel")

		if channel:len () > 0 then
			local msg =
			{
				action = "bundle_on",
				wires = wires
			}


			digilines.receptor_send (pos, sides, channel, msg)
		end
	end
end



local function send_bundle_off (pos, wires)
	local meta = minetest.get_meta (pos)

	if meta then
		local channel = meta:get_string ("channel")

		if channel:len () > 0 then
			local msg =
			{
				action = "bundle_off",
				wires = wires
			}


			digilines.receptor_send (pos, sides, channel, msg)
		end
	end
end



local function digilines_support ()
	return
	{
		wire =
		{
			rules =
			{
				{ x =  1, y =  0, z =  0 },
				{ x = -1, y =  0, z =  0 },
				{ x =  0, y =  0, z = -1 },
				{ x =  0, y =  0, z =  1 },
				{ x =  0, y =  1, z =  0 },
				{ x =  0, y = -1, z =  0 }
			}
		},

		effector =
		{
			action = function (pos, node, channel, msg)
				local meta = minetest.get_meta (pos)

				if meta then
					local mychannel = meta:get_string ("channel")

					if mychannel ~= "" and mychannel == channel then
						if type (msg) == "string" then
							local words = { }

							for word in string.gmatch (msg, "%S+") do
								words[#words + 1] = word
							end

							if words[1] == "on" then
								switch_on (pos, tonumber (words[2]) or words[2])
							elseif words[1] == "off" then
								switch_off (pos, tonumber (words[2]) or words[2])
							elseif words[1] == "state" then
								send_state (pos, mychannel, nil)
							elseif words[1] == "power" then
								send_power (pos, mychannel, nil)
							end

						elseif type (msg) == "table" and msg.action and msg.wires then
							if msg.action == "on" then
								switch_on (pos, msg.wires)
							elseif msg.action == "off" then
								switch_off (pos, msg.wires)
							elseif msg.action == "state" then
								send_state (pos, mychannel, msg.wires)
							elseif msg.action == "power" then
								send_power (pos, mychannel, msg.wires)
							end

						end
					end
				end
			end,
		}
	}
end



local function on_construct (pos)
	local meta = minetest.get_meta (pos)

	if meta then
		meta:set_string ("channel", "")

		local formspec =
		"formspec_version[3]\n"..
		"size[6.0,4.0]\n"..
		"field[1.0,0.8;4.0,1.0;channel;Channel;${channel}]\n"..
		"button_exit[2.0,2.5;2.0,1.0;set;Set]\n"

		meta:set_string ("formspec", formspec)
	end
end



local function on_destruct (pos)
	switch_off (pos, utils.color_string_list ())
end



local function on_receive_fields (pos, formname, fields, sender)
	if fields.channel then
		local meta = minetest.get_meta (pos)

		if meta then
			meta:set_string ("channel", fields.channel or "")
		end
	end
end



minetest.register_node ("lwwires:switch", {
   description = S("Bundle Switch"),
   tiles = { "lwwires_switch_top.png", "lwwires_switch_top.png",
				 "lwwires_switch_side.png", "lwwires_switch_side.png",
				 "lwwires_switch_side.png", "lwwires_switch_side.png" },
   sunlight_propagates = false,
   drawtype = "normal",
   node_box = {
      type = "fixed",
      fixed = {
         {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
      }
   },
	groups = { cracky = 2, oddly_breakable_by_hand = 2, bundles_connect = 1 },
	sounds = default.node_sound_stone_defaults (),
	digiline = digilines_support (),
	_digistuff_channelcopier_fieldname = "channel",

	_wires =
	{
		bundle_on = send_bundle_on,
		bundle_off = send_bundle_off,
		current_state = get_current_state,
	},

   on_construct = on_construct,
   on_destruct = on_destruct,
	on_receive_fields = on_receive_fields,
})



end -- utils.digilines_supported



--
