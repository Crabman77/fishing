
local S = fishing.get_translator


fishing.prizes["rivers"] = {}
fishing.prizes["rivers"]["little"] = {
	{"fishing",  				"fish_raw",				0,			S("a Fish")},
	{"fishing",  				"carp_raw",				0,			S("a Carp")},
}

fishing.prizes["rivers"]["big"] = {
	{"fishing",  				"pike_raw",				0,			S("a Northern Pike")},
	{"fishing",  				"perch_raw",			0,			S("a Perch")},
	{"fishing",  				"catfish_raw",			0,			S("a Catfish")},
}


fishing.prizes["sea"] = {}
fishing.prizes["sea"]["little"] = {
	{"fishing",  				"clownfish_raw",		0,			S("a Clownfish")},
	{"fishing",  				"bluewhite_raw",		0,			S("a Bluewhite")},
	{"fishing",  				"exoticfish_raw",		0,			S("a Exoticfish")},
}

fishing.prizes["sea"]["big"] = {
	{"fishing",  				"shark_raw",			0,			S("a small Shark")},
}


if (minetest.get_modpath("flowers_plus")) then -- exception flowers_plus register flowers:*
 minetest.register_alias("flowers_plus:seaweed", "flowers:seaweed")
end

local stuff = {
--	 mod 						item						wear				message ("You caught "..)		  		chance
	{"flowers_plus",			"seaweed",					0,					S("some Seaweed"),						10},
	{"farming",					"string",					0,					S("a String"),							5},
	{"trunks",					"twig_1",					0,					S("a Twig"),							5},
	{"mobs",					"rat",						0,					S("a Rat"),								5},
	{"default",					"stick",					0,					S("a Twig"),							5},
	{"seaplants",				"kelpgreen",				0,					S("a Green Kelp"),						5},
	{"3d_armor",				"boots_steel",				"random",			S("some very old Boots"),				2},
	{"3d_armor",				"leggings_gold",			"random",			S("some very old Leggings"),			5},
	{"3d_armor",				"chestplate_bronze",		"random",			S("a very old ChestPlate"),				5},
	{"fishing",					"pole_wood",				"randomtools",		S("an old Fishing Pole"),				10},
	{"3d_armor",				"boots_wood",				"random",			S("some very old Boots"),				5},
	{"maptools",				"gold_coin",				0,					S("a Gold Coin"),						1},
	{"3d_armor",				"helmet_diamond",			"random",			S("a very old Helmet"),					1},
	{"shields",					"shield_enhanced_cactus",	"random",			S("a very old Shield"),					2},
	{"default",					"sword_bronze",				"random",			S("a very old Sword"),					2},
	{"default",					"sword_mese",				"random",			S("a very old Sword"),					2},
	{"default",					"sword_nyan",				"random",			S("a very old Sword"),					2},
}

fishing.prizes["stuff"] = {}
local nrmin = 1
for i,v in ipairs(stuff) do
	if minetest.get_modpath(v[1]) ~= nil and minetest.registered_items[v[1]..":"..v[2]] ~= nil then
		table.insert(fishing.prizes["stuff"], {v[1], v[2], v[3], v[4], nrmin, v[5]})
		nrmin = nrmin + v[5]
	end
end


local treasure = {
	{"default",					"mese",						0,					S("a mese block")},
	{"default",					"nyancat",					0,					S("a Nyan Cat")},
	{"default",					"diamondblock",				0,					S("a Diamond Block")},
}
fishing.prizes["treasure"] = fishing.func.ignore_mod(treasure)

-- to true fish mobs
fishing.prizes["true_fish"] = {little = {}, big = {}}
--to mobs_fish modpack
if (minetest.get_modpath("mobs_fish")) then
	fishing.prizes["true_fish"]["little"]["mobs_fish:clownfish"] = {"mobs_fish", "clownfish", 0, S("a Clownfish")}
	fishing.prizes["true_fish"]["little"]["mobs_fish:tropical"] = {"mobs_fish", "tropical", 0, S("a tropical fish")}
end
--to mobs_fish modpack
if (minetest.get_modpath("mobs_sharks")) then
	fishing.prizes["true_fish"]["big"]["mobs_sharks:shark_lg"] = {"mobs_sharks", "shark_lg", 0, S("a big Shark")}
	fishing.prizes["true_fish"]["big"]["mobs_sharks:shark_md"] = {"mobs_sharks", "shark_md", 0, S("a medium Shark")}
	fishing.prizes["true_fish"]["big"]["mobs_sharks:shark_sm"] = {"mobs_sharks", "shark_sm", 0, S("a small Shark")}
end

