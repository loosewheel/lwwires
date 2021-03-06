
local names =
{
	"mesecons_blinkyplant:blinky_plant_on",
	"mesecons_blinkyplant:blinky_plant_off",
	"mesecons_button:button_on",
	"mesecons_button:button_off",
	"mesecons_commandblock:commandblock_on",
	"mesecons_commandblock:commandblock_off",
	"mesecons_delayer:delayer_off_1",
	"mesecons_delayer:delayer_off_2",
	"mesecons_delayer:delayer_off_3",
	"mesecons_delayer:delayer_off_4",
	"mesecons_delayer:delayer_on_1",
	"mesecons_delayer:delayer_on_2",
	"mesecons_delayer:delayer_on_3",
	"mesecons_delayer:delayer_on_4",
	"mesecons_detector:object_detector_on",
	"mesecons_detector:object_detector_off",
	"mesecons_detector:node_detector_off",
	"mesecons_detector:node_detector_on",
	"mesecons_extrawires:vertical_on",
	"mesecons_extrawires:vertical_off",
	"mesecons_extrawires:vertical_top_on",
	"mesecons_extrawires:vertical_top_off",
	"mesecons_extrawires:vertical_bottom_on",
	"mesecons_extrawires:vertical_bottom_off",
	"mesecons_fpga:fpga0000",
	"mesecons_fpga:fpga0001",
	"mesecons_fpga:fpga0010",
	"mesecons_fpga:fpga0011",
	"mesecons_fpga:fpga0100",
	"mesecons_fpga:fpga0101",
	"mesecons_fpga:fpga0110",
	"mesecons_fpga:fpga0111",
	"mesecons_fpga:fpga1000",
	"mesecons_fpga:fpga1001",
	"mesecons_fpga:fpga1010",
	"mesecons_fpga:fpga1011",
	"mesecons_fpga:fpga1100",
	"mesecons_fpga:fpga1101",
	"mesecons_fpga:fpga1110",
	"mesecons_fpga:fpga1111",
	"mesecons_gates:diode_on",
	"mesecons_gates:not_on",
	"mesecons_gates:and_on",
	"mesecons_gates:nand_on",
	"mesecons_gates:xor_on",
	"mesecons_gates:nor_on",
	"mesecons_gates:or_on",
	"mesecons_gates:diode_off",
	"mesecons_gates:not_off",
	"mesecons_gates:and_off",
	"mesecons_gates:nand_off",
	"mesecons_gates:xor_off",
	"mesecons_gates:nor_off",
	"mesecons_gates:or_off",
	"mesecons_hydroturbine:hydro_turbine_on",
	"mesecons_hydroturbine:hydro_turbine_off",
	"mesecons_lamp:lamp_on",
	"mesecons_lamp:lamp_off",
	"mesecons_lightstone:lightstone_red_on",
	"mesecons_lightstone:lightstone_green_on",
	"mesecons_lightstone:lightstone_blue_on",
	"mesecons_lightstone:lightstone_gray_on",
	"mesecons_lightstone:lightstone_darkgray_on",
	"mesecons_lightstone:lightstone_yellow_on",
	"mesecons_lightstone:lightstone_orange_on",
	"mesecons_lightstone:lightstone_white_on",
	"mesecons_lightstone:lightstone_pink_on",
	"mesecons_lightstone:lightstone_magenta_on",
	"mesecons_lightstone:lightstone_cyan_on",
	"mesecons_lightstone:lightstone_violet_on",
	"mesecons_lightstone:lightstone_red_off",
	"mesecons_lightstone:lightstone_green_off",
	"mesecons_lightstone:lightstone_blue_off",
	"mesecons_lightstone:lightstone_gray_off",
	"mesecons_lightstone:lightstone_darkgray_off",
	"mesecons_lightstone:lightstone_yellow_off",
	"mesecons_lightstone:lightstone_orange_off",
	"mesecons_lightstone:lightstone_white_off",
	"mesecons_lightstone:lightstone_pink_off",
	"mesecons_lightstone:lightstone_magenta_off",
	"mesecons_lightstone:lightstone_cyan_off",
	"mesecons_lightstone:lightstone_violet_off",
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
	"mesecons_microcontroller:microcontroller0000",
	"mesecons_microcontroller:microcontroller0001",
	"mesecons_microcontroller:microcontroller0010",
	"mesecons_microcontroller:microcontroller0011",
	"mesecons_microcontroller:microcontroller0100",
	"mesecons_microcontroller:microcontroller0101",
	"mesecons_microcontroller:microcontroller0110",
	"mesecons_microcontroller:microcontroller0111",
	"mesecons_microcontroller:microcontroller1000",
	"mesecons_microcontroller:microcontroller1001",
	"mesecons_microcontroller:microcontroller1010",
	"mesecons_microcontroller:microcontroller1011",
	"mesecons_microcontroller:microcontroller1100",
	"mesecons_microcontroller:microcontroller1101",
	"mesecons_microcontroller:microcontroller1110",
	"mesecons_microcontroller:microcontroller1111",
	"mesecons_movestones:movestone",
	"mesecons_movestones:sticky_movestone",
	"mesecons_movestones:movestone_vertical",
	"mesecons_movestones:sticky_movestone_vertical",
	"mesecons_noteblock:noteblock",
	"mesecons_pistons:piston_normal_on",
	"mesecons_pistons:piston_normal_off",
	"mesecons_pistons:piston_sticky_on",
	"mesecons_pistons:piston_sticky_off",
	"mesecons_powerplant:power_plant",
	"mesecons_pressureplates:pressure_plate_wood_on",
	"mesecons_pressureplates:pressure_plate_wood_off",
	"mesecons_pressureplates:pressure_plate_stone_on",
	"mesecons_pressureplates:pressure_plate_stone_off",
	"mesecons_random:removestone",
	"mesecons_random:ghoststone",
	"mesecons_random:ghoststone_active",
	"mesecons_receiver:receiver_on",
	"mesecons_receiver:receiver_off",
	"mesecons_receiver:receiver_up_on",
	"mesecons_receiver:receiver_up_off",
	"mesecons_receiver:receiver_down_on",
	"mesecons_receiver:receiver_down_off",
	"mesecons_solarpanel:solar_panel_off",
	"mesecons_solarpanel:solar_panel_on",
	"mesecons_switch:mesecon_switch_on",
	"mesecons_switch:mesecon_switch_off",
	"mesecons_torch:mesecon_torch_on",
	"mesecons_torch:mesecon_torch_off",
	"mesecons_walllever:wall_lever_on",
	"mesecons_walllever:wall_lever_off",
	"area_containers:container_off",
	"area_containers:container_0001",
	"area_containers:container_0010",
	"area_containers:container_0011",
	"area_containers:container_0100",
	"area_containers:container_0101",
	"area_containers:container_0110",
	"area_containers:container_0111",
	"area_containers:container_1000",
	"area_containers:container_1001",
	"area_containers:container_1010",
	"area_containers:container_1011",
	"area_containers:container_1100",
	"area_containers:container_1101",
	"area_containers:container_1110",
	"area_containers:container_on",
	"area_containers:port_nx_on",
	"area_containers:port_nx_off",
	"area_containers:port_pz_on",
	"area_containers:port_pz_off",
	"area_containers:port_px_on",
	"area_containers:port_px_off",
	"area_containers:port_nz_on",
	"area_containers:port_nz_off",
	"tnt:tnt",
}


-- lots of wires
for a = 0, 1, 1 do
	for b = 0, 1, 1 do
		for c = 0, 1, 1 do
			for d = 0, 1, 1 do
				for e = 0, 1, 1 do
					for f = 0, 1, 1 do
						for g = 0, 1, 1 do
							for h = 0, 1, 1 do
								names[#names + 1] =
									string.format ("mesecons:wire_%d%d%d%d%d%d%d%d_on", a, b, c, d, e, f, g, h)
								names[#names + 1] =
									string.format ("mesecons:wire_%d%d%d%d%d%d%d%d_off", a, b, c, d, e, f, g, h)
							end
						end
					end
				end
			end
		end
	end
end



local function add_wire_compatibility (name)
	local def = minetest.registered_nodes[name]

	if def then
		if type (def.groups) == "table" then
			local groups = table.copy (def.groups)
			groups.wires_connect = 1

			minetest.override_item (name, { groups = groups })
		end
	end
end



for _, name in ipairs (names) do
	add_wire_compatibility (name)
end



--
