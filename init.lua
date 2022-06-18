-----------------------------------------------------------------------------------------------
local title		= "Fishing - Crabman77's (MFF team) version"
local version 	= "2.0.0"
local mname		= "fishing"
-----------------------------------------------------------------------------------------------
-- original by wulfsdad (http://forum.minetest.net/viewtopic.php?id=4375)
-- rewrited by Mossmanikin (https://forum.minetest.net/viewtopic.php?id=6480)
-- this version rewrited by Crabman77
-- License (code & textures): 	WTFPL
-- Contains code from: 		animal_clownfish, animal_fish_blue_white, fishing (original), stoneage
-- Looked at code from:		default, farming
-- Dependencies: 			default
-- Supports:				animal_clownfish, animal_fish_blue_white, animal_rat, mobs
-----------------------------------------------------------------------------------------------
local S = minetest.get_translator(minetest.get_current_modname())

minetest.log("action","[mod fishing] Loading...")
local path = minetest.get_modpath("fishing").."/"
fishing = {}
fishing.get_translator = S


fishing.settings = {}
fishing.func = {}
fishing.is_creative_mode = minetest.settings:get_bool("creative_mode")
fishing.file_settings = minetest.get_worldpath() .. "/fishing_config.txt"
fishing.file_trophies = minetest.get_worldpath() .. "/fishing_trophies.txt"
fishing.file_contest = minetest.get_worldpath() .. "/fishing_contest.txt"
fishing.file_planned = minetest.get_worldpath() .. "/fishing_planned.txt"
fishing.contest = {}
fishing.planned = {}

fishing.baits = {}
fishing.hungry = {}
fishing.prizes = {}
fishing.trophies = {}


dofile(path .."settings.txt")
dofile(path .."functions.lua")

--default_settings
fishing.settings["message"] = MESSAGES
fishing.settings["worm_is_mob"] = WORM_IS_MOB
fishing.settings["worm_chance"] = WORM_CHANCE
fishing.settings["new_worm_source"] = NEW_WORM_SOURCE
fishing.settings["wear_out"] = WEAR_OUT
fishing.settings["simple_deco_fishing_pole"] = SIMPLE_DECO_FISHING_POLE
fishing.settings["bobber_view_range"] = BOBBER_VIEW_RANGE
fishing.settings["fish_chance"] = FISH_CHANCE
fishing.settings["shark_chance"] = SHARK_CHANCE
fishing.settings["treasure_chance"] = TREASURE_CHANCE
fishing.settings["treasure_enable"] = TREASURE_RANDOM_ENABLE
fishing.settings["escape_chance"] = ESCAPE_CHANCE

-- to mobs_fish|mobs_sharks modpack
if (minetest.get_modpath("mobs_fish") ~= nil or minetest.get_modpath("mobs_sharks") ~= nil) then
  fishing.have_true_fish = true
end 

-- load config file if exist in worldpath
fishing.func.load()

dofile(path .."worms.lua")
dofile(path .."crafting.lua")
dofile(path .."baits.lua")
dofile(path .."prizes.lua")
dofile(path .."baitball.lua")
dofile(path .."bobber.lua")
dofile(path .."bobber_shark.lua")
dofile(path .."fishes.lua")
dofile(path .."trophies.lua")
dofile(path .."poles.lua")

--random hungry bait
fishing.func.hungry_random()
--load table caught fish by players
fishing.func.load_trophies()
--load table contest
fishing.func.load_contest()
fishing.func.tick()
fishing.func.planned_tick()
-----------------------------------------------------------------------------------------------
minetest.log("action", "[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
-----------------------------------------------------------------------------------------------
