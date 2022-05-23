local version = "0.1.9"



lwwires = { }



function lwwires.version ()
	return version
end



local utils = { }

utils.modpath = minetest.get_modpath ("lwwires")


loadfile (utils.modpath.."/utils.lua") (utils)
loadfile (utils.modpath.."/connections.lua") (utils)
loadfile (utils.modpath.."/api.lua") (utils)
loadfile (utils.modpath.."/wires.lua") (utils)
loadfile (utils.modpath.."/bundles.lua") (utils)
loadfile (utils.modpath.."/bundle_blocks.lua") (utils)
loadfile (utils.modpath.."/through_wire.lua") (utils)
loadfile (utils.modpath.."/terminal.lua") (utils)
loadfile (utils.modpath.."/switch.lua") (utils)
loadfile (utils.modpath.."/compatibility.lua") ()
loadfile (utils.modpath.."/crafting.lua") (utils)



mesecon.queue:add_function ("lwwires_wire_on_construct", function (pos, color)
	utils.wire_connections.on_construct_wire (color, pos)

	local meta = minetest.get_meta (pos)

	if meta then
		meta:from_table (nil)
	end
end)



mesecon.queue:add_function ("lwwires_wire_on_blast", function (pos, color)
	utils.wire_connections.on_blast_wire (color, pos)
end)



mesecon.queue:add_function ("lwwires_bundle_on_destruct", function (pos, color)
	utils.wire_connections.on_destruct_bundle (color, pos)
end)



mesecon.queue:add_function ("lwwires_execute_action_queue", function (pos)
	utils.wire_connections.execute_action_queue (pos)
end)



minetest.register_on_placenode (function (pos, newnode, placer, oldnode, itemstack, pointed_thing)
	utils.wire_connections.global_on_placenode (pos, newnode)

	return nil
end)



--
