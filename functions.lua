
local S = fishing.get_translator



--function save settings
function fishing.func.save()
	local input, err = io.open(fishing.file_settings, "w")
	if input then
		input:write(minetest.serialize(fishing.settings))
		input:close()
	else
		minetest.log("error", "open(" .. fishing.file_settings .. ", 'w') failed: " .. err)
	end
end


function fishing.func.set_settings(new_settings, settings)
	if settings["message"] ~= nil then
		new_settings["message"] = settings["message"]
	end

	if settings["worm_is_mob"] ~= nil then
		new_settings["worm_is_mob"] = settings["worm_is_mob"]
	end

	if settings["worm_chance"] ~= nil then
		new_settings["worm_chance"] = settings["worm_chance"]
	end

	if settings["new_worm_source"] ~= nil then
		new_settings["new_worm_source"] = settings["new_worm_source"]
	end
	if settings["wear_out"] ~= nil then
		new_settings["wear_out"] = settings["wear_out"]
	end

	if settings["bobber_view_range"] ~= nil then
		new_settings["bobber_view_range"] = settings["bobber_view_range"]
	end

	if settings["simple_deco_fishing_pole"] ~= nil then
		new_settings["simple_deco_fishing_pole"] = settings["simple_deco_fishing_pole"]
	end

	if settings["fish_chance"] ~= nil then
		new_settings["fish_chance"] = settings["fish_chance"]
	end

	if settings["treasure_chance"] ~= nil then
		new_settings["treasure_chance"] = settings["treasure_chance"]
	end

	if settings["shark_chance"] ~= nil then
		new_settings["shark_chance"] = settings["shark_chance"]
	end

	if settings["treasure_enable"] ~= nil then
		new_settings["treasure_enable"] = settings["treasure_enable"]
	end

	if settings["escape_chance"] ~= nil then
		new_settings["escape_chance"] = settings["escape_chance"]
	end
end


--function load settings from file
function fishing.func.load()
	local file = io.open(fishing.file_settings, "r")
	local settings = {}
	if file then
		settings = minetest.deserialize(file:read("*all"))
		file:close()
		if settings and type(settings) == "table" then
			fishing.func.set_settings(fishing.settings, settings)
		end
	end
end

--function return wear tool value (old or new)
function fishing.func.wear_value(wear)
	local used = 0
	if wear == "random" then
		used = (2000*(math.random(20, 29)))
	elseif wear == "randomtools" then
		used = (65535/(30-(math.random(15, 29))))
	end
	return used
end


-- function return table where mods actived
function fishing.func.ignore_mod(list)
	local listOk = {}
	for i, v in ipairs(list) do
		if minetest.get_modpath(v[1]) ~= nil and minetest.registered_items[v[1]..":"..v[2]] ~= nil then
			table.insert(listOk, v)
		end
	end
	return listOk
end

--function random hungry by bait type
function fishing.func.hungry_random()
	for i,a in pairs(fishing.baits) do
		if string.find(i, "fishing:") ~= nil then
			fishing.baits[i]["hungry"] = math.random(15, 80)
		end
	end

	-- to mobs_fish modpack
	if fishing.baits["mobs_fish:clownfish"] then
		fishing.baits["mobs_fish:clownfish"]["hungry"] = fishing.baits["fishing:clownfish_raw"]["hungry"]
	end
	if fishing.baits["mobs_fish:tropical"] then
		fishing.baits["mobs_fish:tropical"]["hungry"] = fishing.baits["fishing:exoticfish_raw"]["hungry"]
	end

	--change hungry after random time, min 0h30, max 6h00
	minetest.after(math.random(1, 12)*1800, fishing.func.hungry_random )
end


function fishing.func.get_loot()
	if #fishing.prizes["stuff"] > 0 then
		local c = math.random(1, fishing.prizes["stuff"][#fishing.prizes["stuff"]][5])
		for i in pairs(fishing.prizes["stuff"]) do
			local min = fishing.prizes["stuff"][i][5]
			local chance = fishing.prizes["stuff"][i][6]
			local max = min + chance
			if c <= max and c >= min then
				return fishing.prizes["stuff"][i]
			end
		end
	end
	return ""
end


-- Show notification when a player catches treasure
function fishing.func.notify(f_name, treasure)
	local title = S("Lucky @1, he caught a treasure, @2!", f_name, treasure)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if player_name == f_name then
			minetest.chat_send_player(player_name, S("You caught a treasure, @1!", treasure))
		else
			minetest.chat_send_player(player_name, title)
		end
	end
end


-- Menu: fishing configuration
fishing.func.on_show_settings = function(player_name)
	if not fishing.tmp_setting then
		fishing.tmp_setting = {}
		fishing.func.set_settings(fishing.tmp_setting, fishing.settings)
	end
	local formspec = "size[10.8,9]label[4,0;"..S("Fishing configuration").."]"..
		-- Fish chance
		"label[1.6,0.5;"..S("Fish chance").."]"..
		"button[0,1;1,1;cfish;-1]"..
		"button[1,1;1,1;cfish;-10]"..
		"label[2.1,1.2;"..tostring(fishing.tmp_setting["fish_chance"]).."]"..
		"button[2.7,1;1,1;cfish;+10]"..
		"button[3.7,1;1,1;cfish;+1]"..
		-- Shark chance
		"label[1.5,2;"..S("Shark chance").."]"..
		"button[0,2.5;1,1;cshark;-1]"..
		"button[1,2.5;1,1;cshark;-10]"..
		"label[2.1,2.7;"..tostring(fishing.tmp_setting["shark_chance"]).."]"..
		"button[2.7,2.5;1,1;cshark;+10]"..
		"button[3.7,2.5;1,1;cshark;+1]"..
		-- Treasure chance
		"label[1.5,3.5;"..S("Treasure chance").."]"..
		"button[0,4.;1,1;ctreasure;-1]"..
		"button[1,4;1,1;ctreasure;-10]"..
		"label[2.1,4.2;"..tostring(fishing.tmp_setting["treasure_chance"]).."]"..
		"button[2.7,4;1,1;ctreasure;+10]"..
		"button[3.7,4;1,1;ctreasure;+1]"..
		-- Worm chance
		"label[7.5,0.5;"..S("Worm chance").."]"..
		"button[6,1;1,1;cworm;-1]"..
		"button[7,1;1,1;cworm;-10]"..
		"label[8.1,1.2;"..tostring(fishing.tmp_setting["worm_chance"]).."]"..
		"button[8.7,1;1,1;cworm;+10]"..
		"button[9.7,1;1,1;cworm;+1]"..
		-- Escape chance
		"label[7.4,2;"..S("Escape chance").."]"..
		"button[6,2.5;1,1;cescape;-1]"..
		"button[7,2.5;1,1;cescape;-10]"..
		"label[8.1,2.7;"..tostring(fishing.tmp_setting["escape_chance"]).."]"..
		"button[8.7,2.5;1,1;cescape;+10]"..
		"button[9.7,2.5;1,1;cescape;+1]"..
		-- Bobber view range
		"label[7.2,3.5;"..S("Bobber view range").."]"..
		"button[7,4;1,1;bvrange;-1]"..
		"label[8.1,4.2;"..tostring(fishing.tmp_setting["bobber_view_range"]).."]"..
		"button[8.7,4;1,1;bvrange;+1]"..
		-- Messages display
		"label[0,5.7;"..S("Display messages in chat").."]"..
		"button[4,5.5;1,1;dmessages;"..tostring(fishing.tmp_setting["message"]).."]"..
		--poledeco
		"label[0,6.5;"..S("Simple pole deco").."]"..
		"button[4,6.3;1,1;poledeco;"..tostring(fishing.tmp_setting["simple_deco_fishing_pole"]).."]"..
		-- Wearout
		"label[0,7.3;"..S("Poles wearout").."]"..
		"button[4,7.1;1,1;wearout;"..tostring(fishing.tmp_setting["wear_out"]).."]"..
		-- TREASURE_ENABLE
		"label[5.7,5.7;"..S("Enable treasure").."]"..
		"button[9.7,5.5;1,1;treasureenable;"..tostring(fishing.tmp_setting["treasure_enable"]).."]"..
		-- NEW_WORM_SOURCE
		"label[5.7,6.5;"..S("New worm source (reboot)").."]"..
		"button[9.7,6.3;1,1;newworm;"..tostring(fishing.tmp_setting["new_worm_source"]).."]"..
		-- WORM_IS_MOB
		"label[5.7,7.3;"..S("Worm is a mob (reboot)").."]"..
		"button[9.7,7.1;1,1;wormmob;"..tostring(fishing.tmp_setting["worm_is_mob"]).."]"..
		"button_exit[0,8.2;1.5,1;abort;"..S("Abort").."]"..
		"button_exit[9.2,8.2;1.5,1;save;"..S("Ok").."]"
	minetest.show_formspec(player_name, "fishing:settings", formspec)
end

local inc = function(value, field, min, max)
	local inc = tonumber(field)
	local v = value
	if inc ~= nil then
		v = value + inc
	end

	if v > max then
		return max
	end
	if v < min then
		return min
	end
	return v
end


local bool = function(field)
	return field ~= "true"
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local player_name = player:get_player_name()
	if not player_name then return end
	if formname == "fishing:settings" then
		if fields["save"]  then
			fishing.func.set_settings(fishing.settings, fishing.tmp_setting)
			fishing.func.save()
			fishing.tmp_setting = nil
			return
		elseif fields["quit"] or fields["abort"] then
			fishing.tmp_setting = nil
			return
		elseif fields["cfish"] then
			fishing.tmp_setting["fish_chance"] = inc(fishing.tmp_setting["fish_chance"], fields["cfish"], 1, 100)
		elseif fields["cshark"] then
			fishing.tmp_setting["shark_chance"] = inc(fishing.tmp_setting["shark_chance"], fields["cshark"], 1, 100)
		elseif fields["ctreasure"] then
			fishing.tmp_setting["treasure_chance"] = inc(fishing.tmp_setting["treasure_chance"], fields["ctreasure"], 1, 100)
		elseif fields["bvrange"] then
			fishing.tmp_setting["bobber_view_range"] = inc(fishing.tmp_setting["bobber_view_range"], fields["bvrange"], 4, 20)
		elseif fields["cworm"] then
			fishing.tmp_setting["worm_chance"] = inc(fishing.tmp_setting["worm_chance"], fields["cworm"], 1, 100)
		elseif fields["cescape"] then
			fishing.tmp_setting["escape_chance"] = inc(fishing.tmp_setting["escape_chance"], fields["cescape"], 1, 50)
		elseif fields["dmessages"] then
			fishing.tmp_setting["message"] = bool(fields["dmessages"])
		elseif fields["poledeco"] then
			fishing.tmp_setting["simple_deco_fishing_pole"] = bool(fields["poledeco"])
		elseif fields["wearout"] then
			fishing.tmp_setting["wear_out"] = bool(fields["wearout"])
		elseif fields["treasureenable"] then
			fishing.tmp_setting["treasure_enable"] = bool(fields["treasureenable"])
		elseif fields["newworm"] then
			fishing.tmp_setting["new_worm_source"] = bool(fields["newworm"])
		elseif fields["wormmob"] then
			fishing.tmp_setting["worm_is_mob"] = bool(fields["wormmob"])
		else
			return
		end

		fishing.func.on_show_settings(player_name)
	elseif formname == "fishing:admin_conf" then
		if fields["ranking"] then
			local formspec = fishing.func.get_stat()
			minetest.show_formspec(player_name, "fishing:ranking", formspec)
		elseif fields["contest"] then
			fishing.func.on_show_settings_contest(player_name)
		elseif fields["configuration"] then
			fishing.func.on_show_settings(player_name)
		elseif fields["hungerinfo"] then
			fishing.func.get_hunger_info(player_name)
		end
	end
end)

--function load settings from file
function fishing.func.load_trophies()
	local file = io.open(fishing.file_trophies, "r")
	fishing.trophies = {}
	if file then
		fishing.trophies = minetest.deserialize(file:read("*all"))
		file:close()
		if not fishing.trophies or type(fishing.trophies) ~= "table" then
			fishing.trophies = {}
		end
	end
end

function fishing.func.save_trophies()
	local input = io.open(fishing.file_trophies, "w")
	if input then
		input:write(minetest.serialize(fishing.trophies))
		input:close()
	else
		minetest.log("action","Open failed (mode:w) of " .. fishing.file_trophies)
	end
end

minetest.register_on_shutdown(function()
	minetest.log("action", "[fishing] Server shuts down, saving trophies table.")
	fishing.func.save_trophies()
	fishing.func.save_contest()
end)


function fishing.func.timetostr(time)
	local countdown = time
	local answer = ""
	if countdown >= 3600 then
		local hours = math.floor(countdown / 3600)
		countdown = countdown % 3600
		answer = hours .. "h"
	end
	if countdown >= 60 then
		local minutes = math.floor(countdown / 60)
		countdown = countdown % 60
		answer = answer .. minutes .. "m"
	else
		answer = answer .. "0m"
	end
	local seconds = countdown
	answer = answer .. math.floor(seconds) .. "s"
	return answer
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if fishing.contest["contest"] == true then
		minetest.chat_send_player(player_name, S("A fishing contest is in progress. (remaining time @1)", fishing.func.timetostr(fishing.contest["duration"])))
	end
end)


function fishing.func.add_to_trophies(player, fish, desc)
	local player_name = player:get_player_name()
	if not player_name then return end
	if string.find(fish, "_raw") ~= nil or fishing.prizes["true_fish"]["little"][fish] or fishing.prizes["true_fish"]["big"][fish] then
		if string.find(fish, "_raw") ~= nil then
			if fishing.trophies[fish] == nil then
				fishing.trophies[fish] = {}
			end		
			fishing.trophies[fish][player_name] = (fishing.trophies[fish][player_name] or 0) + 1
			if fishing.trophies[fish][player_name]%100 == 0 then
				minetest.chat_send_player(player_name, S("You win a new trophy, you have caught @1 @2.", fishing.trophies[fish][player_name], fish))
				local inv = player:get_inventory()
				local name = "fishing:trophy_"..fish
				if inv:room_for_item("main", {name=name, count=1, wear=0, metadata=""}) then
					inv:add_item("main", {name=name, count=1, wear=0, metadata=""})
				else
					minetest.spawn_item(player:get_pos(), {name=name, count=1, wear=0, metadata=""})
				end
			end
		end
		if fishing.contest["contest"] ~= nil and fishing.contest["contest"] == true then
			if fishing.contest["nb_fish"] == nil then
				fishing.contest["nb_fish"] = {}
			end
			fishing.contest["nb_fish"][player_name] = (fishing.contest["nb_fish"][player_name] or 0) + 1
			minetest.chat_send_all(S("Yeah, @1 caught @2.", player_name, desc))
		end
	end
end


-- Menu: fishing configuration/contest
fishing.func.on_show_admin_menu = function(player_name)
	local formspec = "size[5,5]label[1.7,0;"..S("Fishing Menu").."]"..
					"button[0.5,0.5;4,1;ranking;"..S("Contest rankings").."]"..
					"button[0.5,1.5;4,1;contest;"..S("Contests").."]"..
					"button[0.5,2.5;4,1;configuration;"..S("Configuration").."]"..
					"button[0.5,3.5;4,1;hungerinfo;"..S("Hunger info").."]"..
					"button_exit[1,4.5;3,1;close;"..S("Close").."]"
	minetest.show_formspec(player_name, "fishing:admin_conf", formspec)
end


if (minetest.get_modpath("unified_inventory")) then
	unified_inventory.register_button("menu_fishing", {
		type = "image",
		image = "fishing_perch_raw.png",
		tooltip = S("Fishing Menu Configuration"),
		action = function(player)
			local player_name = player:get_player_name()
			if not player_name then return end
			if minetest.check_player_privs(player_name, {server=true}) then
				fishing.func.on_show_admin_menu(player_name)
			else
				local formspec = fishing.func.get_stat()
				minetest.show_formspec(player_name, "fishing:ranking", formspec)
			end
		end,
	})
end


--function save settings
function fishing.func.save_contest()
	local input = io.open(fishing.file_contest, "w")
	if input then
		input:write(minetest.serialize(fishing.contest))
		input:close()
	else
		minetest.log("action","Open failed (mode:w) of " .. fishing.file_contest)
	end
end

--function load contest data from file
function fishing.func.load_contest()
	local file = io.open(fishing.file_contest, "r")
	local settings
	fishing.contest = {["contest"] = false, ["duration"] = 3600, ["bobber_nb"] = 4}
	if file then
		settings = minetest.deserialize(file:read("*all"))
		file:close()
		if settings ~= nil and type(settings) == "table" then
			if settings["contest"] ~= nil then
				fishing.contest["contest"] = settings["contest"]
			end
			if settings["duration"] ~= nil then
				fishing.contest["duration"] = settings["duration"]
			end
			if settings["bobber_nb"] ~= nil then
				fishing.contest["bobber_nb"] = settings["bobber_nb"]
			end
			if settings["nb_fish"] ~= nil then
				fishing.contest["nb_fish"] = settings["nb_fish"]
			end
		end
	end
end

function fishing.func.start_contest(duration)
	fishing.contest["contest"] = true
	fishing.contest["warning_said"] = false
	fishing.contest["duration"] = duration
	minetest.chat_send_all(S("Attention, Fishing contest start (duration @1)!!!", fishing.func.timetostr(duration)))
	minetest.sound_play("fishing_contest_start",{gain=0.8})
	fishing.func.save_contest()
	fishing.func.tick()
end

function fishing.func.end_contest()
	fishing.contest["contest"] = false
	fishing.func.save_contest()
	minetest.chat_send_all(S("End of fishing contest."))
	minetest.sound_play("fishing_contest_end",{gain=0.8})
	fishing.func.show_result()
end


--function load planned contest from file
function fishing.func.load_planned()
	local file = io.open(fishing.file_planned, "r")
	local settings = {}
	if file then
		settings = minetest.deserialize(file:read("*all"))
		file:close()
		if settings and type(settings) == "table" then
			for i, p in pairs(settings) do
				if p["wday"] ~= nil and p["hour"] ~= nil and p["min"] ~= nil and p["duration"] ~= nil then
					table.insert(fishing.planned, {["wday"]=p["wday"], ["hour"]=p["hour"], ["min"]=p["min"], ["duration"]=p["duration"]})
				end
			end
		end
	end
end

fishing.func.load_planned()

function fishing.func.save_planned()
	local input = io.open(fishing.file_planned, "w")
	if input then
		input:write(minetest.serialize(fishing.planned))
		input:close()
	else
		minetest.log("action","Open failed (mode:w) of " .. fishing.file_planned)
	end
end

minetest.register_chatcommand("contest_add", {
	params = S("Wday Hours Minutes duration(in sec) (ex: 1 15 40 3600)"),
	description = S("Add contest (admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		local wday, hour, min, duration = param:match("^(%d+)%s(%d+)%s(%d+)%s(%d+)$")
		if ((not wday or not tonumber(wday)) or (not hour or not tonumber(hour)) or (not min and not tonumber(min)) or (not duration or not tonumber(duration))) then
			return false, "Invalid usage, see /help contest_add."
		end

		wday = tonumber(wday)
		hour = tonumber(hour)
		min = tonumber(min)
		duration = tonumber(duration)

		if (wday < 0 or wday > 7) then
			return false, S("Invalid argument wday, 0-7 (0=all 1=Sunday).")
		end

		if (hour < 0 or hour > 23) then
			return false, S("Invalid argument hour, 0-23.")
		end
		if (min < 0 or min > 59) then
			return false, S("Invalid argument minutes, 0-59.")
		end

		if duration < 600 then
			duration = 600
		elseif duration > 14400 then
			duration = 14400
		end

		table.insert(fishing.planned, {["wday"]=wday, ["hour"]=hour, ["min"]=min, ["duration"]=duration})
		fishing.func.save_planned()
		return true, S("New contest registered @1 @2:@3 duration @4.", wday, hour, min, duration)
	end
})

minetest.register_chatcommand("contest_del", {
	params = S("List number(show by contest_show command)"),
	description = S("Delete planned contest(admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		local i = tonumber(param)
		if not i then
			return false, S("Invalid usage, see /help contest_del.")
		end
		if i < 1 then
			return false, S("Invalid usage, see /help contest_del.")
		end
		
		local c = fishing.planned[i]
		if not c then
			return false, S("Contest no found.")
		end
		table.remove(fishing.planned, i)
		fishing.func.save_planned()
		return true, S("Contest deleted.")
	end
})

minetest.register_chatcommand("contest_show", {
	params = "",
	description = S("Display planned contest(admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		local text = "Registered contest:\n"
		for i, plan in pairs(fishing.planned) do
			text = text ..("%d) wday:%d hour:%d min:%d duration %d.\n"):format(i, plan.wday, plan.hour, plan.min, plan.duration)
		end
		return true, text
	end
})

minetest.register_chatcommand("contest_start", {
	params = S("Duration in seconds"),
	description = S("Start a contest (admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		if fishing.contest["contest"] == true then
			return false, S("Contest already in progress.")
		end
		
		local duration = tonumber(param)
		if not duration then
			duration = 3600
		end
		fishing.contest["nb_fish"] = {}
		fishing.func.start_contest(duration)
		return true, S("Contest started, duration:@1.", fishing.func.timetostr(duration))
	end
})

minetest.register_chatcommand("contest_stop", {
	params = "",
	description = S("Stop a contest (admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		if fishing.contest["contest"] == false then
			return false, S("No contest in progress.")
		end
		fishing.func.end_contest()
		return true, S("Contest terminated.")
	end
})

function fishing.func.planned_tick()
	if fishing.contest["contest"] == nil or fishing.contest["contest"] == false then
		for i, plan in pairs(fishing.planned) do
			local wday = plan.wday
			local hour = plan.hour
			local min = plan.min
			local duration = plan.duration
			local time = os.date("*t",os.time())
			if (wday == 0 or wday == time.wday) then
				if time.hour == hour and time.min == min then
					minetest.log("action", ("Starting fishing contest at %d:%d duration %d"):format( hour, min, duration))
					fishing.contest["nb_fish"] = {}
					fishing.func.start_contest(duration)
					break
				end
			end
		end
	end
	minetest.after(50, fishing.func.planned_tick)
end

--Menu fishing configuration
fishing.func.on_show_settings_contest = function(player_name)
	if not fishing.tmp_setting then
		fishing.tmp_setting = { ["contest"] = (fishing.contest["contest"] or false),
										["duration"] = (math.floor(fishing.contest["duration"]) or 3600),
										["bobber_nb"] = (fishing.contest["bobber_nb"] or 2),
										["reset"] = false
										}
	end
	local formspec = "size[6.1,7]label[1.5,0;"..S("Fishing contest").."]"..
				--Time contest
				"label[2.2,0.5;"..S("Duration(in sec)").."]"..
				"button[0.8,1;1,1;duration;-60]"..
				"button[1.8,1;1,1;duration;-600]"..
				"label[2.7,1.2;"..tostring(fishing.tmp_setting["duration"]).."]"..
				"button[3.5,1;1,1;duration;+600]"..
				"button[4.5,1;1,1;duration;+60]"..
				--bobber nb
				"label[2,2;"..S("Bobber number limit").."]"..
				"button[1.8,2.5;1,1;bobbernb;-1]"..
				"label[2.9,2.7;"..tostring(fishing.tmp_setting["bobber_nb"]).."]"..
				"button[3.5,2.5;1,1;bobbernb;+1]"..
				--contest enable
				"label[0.8,3.8;"..S("Enable contests").."]"..
				"button[4.5,3.6;1,1;contest;"..tostring(fishing.tmp_setting["contest"]).."]"..
				--reset
				"label[0.8,5.2;"..S("Reset rankings").."]"..
				"button[4.5,5;1,1;reset;"..tostring(fishing.tmp_setting["reset"]).."]"..
				"button_exit[0.8,6.2;1.5,1;abort;"..S("Abort").."]"..
				"button_exit[4,6.2;1.5,1;save;"..S("Ok").."]"
	minetest.show_formspec(player_name, "fishing:contest", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "fishing:contest" then
		local name = player:get_player_name()
		if not name then return end
		if fields["save"] then
			if fishing.tmp_setting["reset"] == true then
				fishing.contest["nb_fish"] = {}
			end

			local progress = (fishing.contest["contest"] or false)
			fishing.contest["duration"] = fishing.tmp_setting["duration"]
			fishing.contest["contest"] = fishing.tmp_setting["contest"]
			fishing.contest["bobber_nb"] = fishing.tmp_setting["bobber_nb"]
			if progress == false and fishing.tmp_setting["contest"] == true then
				fishing.func.start_contest(fishing.contest["duration"])
			elseif progress == true and fishing.tmp_setting["contest"] == false then
				fishing.func.end_contest()
			end
			fishing.func.save_contest()
			fishing.tmp_setting = nil
			return
		elseif fields["quit"] or fields["abort"] then
			fishing.tmp_setting = nil
			return
		elseif fields["duration"] then
			fishing.tmp_setting["duration"] = inc(fishing.tmp_setting["duration"], fields["duration"], 120, 14400)
		elseif fields["contest"] then
			fishing.tmp_setting["contest"] = bool(fields["contest"])
		elseif fields["bobbernb"] then
			fishing.tmp_setting["bobber_nb"] = inc(fishing.tmp_setting["bobber_nb"], fields["bobbernb"], 1, 8)
		elseif fields["reset"] then
			fishing.tmp_setting["reset"] = bool(fields["reset"])
		else
			return
		end
		fishing.func.on_show_settings_contest(name)
	end
end)


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


function fishing.func.set_winners(list)
	local win = {}
	-- this uses an custom sorting function ordering by score descending
	for k,v in spairs(list, function(t,a,b) return t[b] < t[a] end) do
		table.insert(win, {["name"]=k, ["nb"]=v})
		if #win >= 15 then
			break
		end
	end
	return win
end


function fishing.func.get_stat()
	local winners = {}
	if fishing.contest["nb_fish"] ~= nil then
		winners = fishing.func.set_winners(fishing.contest["nb_fish"])
	end
	local formspec = {"size[8,8]label[2,0;"..S("Fishing contest rankings").."]"}
	local Y = 1.1
	table.insert(formspec, "label[0.5,0.5;" .. S("No") .."]")
	table.insert(formspec, "label[2,0.5;" .. S("Name") .."]")
	table.insert(formspec, "label[4.5,0.5;" .. S("Fish Total") .."]")
	for num,n in ipairs(winners) do
		table.insert(formspec, "label[0.5,"..Y..";"..tostring(num).."]") -- ranking
		table.insert(formspec, "label[2,"..Y..";"..n["name"].."]") -- playername
		table.insert(formspec, "label[4.6,"..Y..";"..tostring(n["nb"]).."]") -- nb fish caught
		Y = Y + 0.4
	end
	table.insert(formspec, "button_exit[1,7.5;1.2,1;close;"..S("Close").."]")
	return table.concat(formspec)
end

function fishing.func.get_hunger_info(player_name)
	local formspec = "size[6,9]label[1.9,0;" .. S("Fishing Info Center") .."]"
	local y = 0.8
	for i, a in pairs(fishing.baits) do
		if string.find(i, "fishing:") ~= nil then
			formspec = formspec .."item_image_button[1,"..tostring(y)..";1,1;"..tostring(i)..";"..tostring(i)..";]"..
				"label[2.2,"..tostring(y+0.2)..";" .. S("Chance to catch") .." :"..tostring(a["hungry"]).."%]"
			y = y+1
		end
	end
	formspec = formspec .."button_exit[2,8.5;2,1;close;"..S("Close").."]"
	minetest.show_formspec(player_name,"fishing:material_info", formspec)
end

minetest.register_chatcommand("fishing_menu", {
	params = "",
	description = S("Show fishing menu (admin only)"),
	privs = {server=true},
	func = function(player_name, param)
		if not player_name then return end
		fishing.func.on_show_admin_menu(player_name)
	end
})

minetest.register_chatcommand("fishing_ranking", {
	params = "",
	description = S("Display ranking"),
	privs = {interact=true},
	func = function(player_name, param)
		if not player_name then return end
		local formspec = fishing.func.get_stat()
		minetest.show_formspec(player_name, "fishing:ranking", formspec)
	end
})

function fishing.func.show_result()
	minetest.after(3, function()
		local formspec = fishing.func.get_stat()
		for _,player in pairs(minetest.get_connected_players()) do
			local player_name = player:get_player_name()
			if player_name ~= nil then
				minetest.show_formspec(player_name, "fishing:ranking", formspec)
			end
		end
	end)
end

local UPDATE_TIME = 1
function fishing.func.tick()
	if fishing.contest["contest"] ~= nil and fishing.contest["contest"] == true then
		fishing.contest["duration"] = fishing.contest["duration"] - UPDATE_TIME
		if fishing.contest["duration"] < 30 and fishing.contest["warning_said"] ~= true then
			minetest.chat_send_all(S("ATTENTION, the fishing contest will end in 30 seconds."))
			fishing.contest["warning_said"] = true
		end
		if fishing.contest["duration"] < 0 then
			fishing.func.end_contest()
		else
			minetest.after(UPDATE_TIME, fishing.func.tick)
		end
	end
end
