local version = "0.1.0"
local mod_storage = minetest.get_mod_storage ()



lwwires = { }



function lwwires.version ()
	return version
end



local utils = { }

utils.modpath = minetest.get_modpath ("lwwires")


loadfile (utils.modpath.."/utils.lua") (utils)
loadfile (utils.modpath.."/connections.lua") (utils, mod_storage)
loadfile (utils.modpath.."/api.lua") (utils)
loadfile (utils.modpath.."/wires.lua") (utils)
loadfile (utils.modpath.."/bundles.lua") (utils)
loadfile (utils.modpath.."/switch.lua") (utils)
loadfile (utils.modpath.."/crafting.lua") (utils)



--
