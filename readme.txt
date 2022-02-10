LW Wires
	by loosewheel


Licence
=======
Code licence:
LGPL 2.1

Media licence:
CC-BY-SA 3.0


Version
=======
0.1.3


Minetest Version
================
This mod was developed on version 5.4.1


Dependencies
============
default
mesecons
dye


Optional Dependencies
=====================
intllib
digilines


Installation
============
Copy the 'lwwires' folder to your mods folder.


Bug Report
==========
https://forum.minetest.net/viewtopic.php?f=9&t=27770


Description
===========
This mod provides wires, bundle cables and bundle blocks. 16 colored wires
and 16 colored bundle cables. Bundle blocks are the same as bundle cables
but full node size.


Limitations
-----------
Breaking or placing wires sends notifications for that color even if
the power state wasn't changed at the notified position. (See definition
interface in mod_api.txt about notifications).

Individual mesecons circuits connected to wires may flick off and then on
if multiple power sources are connected via the wires, and the power
source connected to the mesecons circuit is turned off.


Bundle Switch
-------------
The bundle switch is only defined if digilines is loaded. The bundle switch
controls every bundle cable on any of the 6 sides with digilines messages.

Messages:

"on <wire>"
	or
{
	action = "on",
	wires = { <wire>[, <wire>, ...] }
}
	Turns one or more wires on. <wire> can be one of the wire colors or
	numbers.


"off <wire>"
	or
{
	action = "off",
	wires = { <wire>[, <wire>, ...] }
}
	Turns one or more wires off. <wire> can be one of the wire colors or
	numbers.


"state"
	or
{
	action = "state",
	wires = { <wire>[, <wire>, ...] }
}
	Sends a message with the switch's channel with a table of the set state
	of the queried wires. <wire> can be one of the wire colors or numbers.
	If the string message or wires is nil all wires are queried:
	{
		action = "current_state",
		wires = { "<color>" = true | false[, "<color>" = true | false, ...] }
	}


"power"
	or
{
	action = "power",
	wires = { <wire>[, <wire>, ...] }
}
	Sends a message with the switch's channel with a table of the powered
	state of the queried wires. This tests external power to the wire/s.
	<wire> can be one of the wire colors or numbers. If the string message
	or wires is nil all wires are queried:
	{
		action = "current_power",
		wires = { "<color>" = true | false[, "<color>" = true | false, ...] }
	}

A notification message is sent with the switch's channel when power to any
wires in the bundle is turned on, with a list of the wires (color strings)
affected.
{
	action = "bundle_on",
	wires = { <wire>[, <wire>, ...] }
}

A notification message is sent with the switch's channel when power to any
wires in the bundle is turned off, with a list of the wires (color strings)
affected.
{
	action = "bundle_off",
	wires = { <wire>[, <wire>, ...] }
}



Wire colors and numbers
black		= 0
orange	= 1
magenta	= 2
sky		= 3
yellow	= 4
pink		= 5
cyan		= 6
gray		= 7
silver	= 8
red		= 9
green		= 10
blue		= 11
brown		= 12
lime		= 13
purple	= 14
white		= 15


An api is exposed to interact with the mod. See mod_api.txt.


------------------------------------------------------------------------
