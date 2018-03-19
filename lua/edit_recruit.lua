-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"
local helper = wesnoth.require("lua/helper.lua")
local T = helper.set_wml_tag_metatable {}
local cc_helper = wesnoth.require "~add-ons/Custom_Campaign/lua/my_helper.lua"

local unit_selection = {}

function unit_selection.max_selectalbe_units()
	return 50
end

-- @ret1 boolean
-- @ret2 a string with the message if invalid othewrwise nil
function unit_selection.is_valid_recuitlist(unitidlist)
	for k,v in pairs(unitidlist) do
		if(wesnoth.unit_types[v] == nil) then
			---wesnoh.message("found invalid unit id:" .. tostring(v))
			return false, "found invalid unit id:" .. tostring(v)
		end
	end
	if #unitidlist > unit_selection.max_selectalbe_units() then
		--wesnoth.message("found too many units in recruitlist")
		return false, "found too many units in recruitlist"
	end
	if pyr_npt_helper.tablereduce(unitidlist, function(a,b) return a + wesnoth.unit_types[b].cost end, 0) > unit_selection.max_selectalbe_units_gold_limit() then
		--wesnoth.message("found too expensive units in recruitlist")
		return false, "found too expensive units in recruitlist"
	end
		
	return true
end
-- all units that exist in data/core/units except 'fog clearer'
local mainline_units = {"Blood Bat", "Dread Bat", "Vampire Bat", "Boat", "Galleon", "Pirate Galleon", "Transport Galleon", "Drake Arbiter", "Armageddon Drake", "Drake Blademaster", "Drake Burner", "Drake Clasher", "Drake Enforcer", "Drake Fighter", "Fire Drake", "Drake Flameheart", "Drake Flare", "Drake Glider", "Hurricane Drake", "Inferno Drake", "Sky Drake", "Drake Thrasher", "Drake Warden", "Drake Warrior", "Dwarvish Arcanister", "Dwarvish Berserker", "Dwarvish Dragonguard", "Dwarvish Explorer", "Dwarvish Fighter", "Dwarvish Guardsman", "Dwarvish Lord", "Dwarvish Pathfinder", "Dwarvish Runemaster", "Dwarvish Runesmith", "Dwarvish Scout", "Dwarvish Sentinel", "Dwarvish Stalwart", "Dwarvish Steelclad", "Dwarvish Thunderer", "Dwarvish Thunderguard", "Dwarvish Ulfserker", "Elvish Archer", "Elvish Avenger", "Elvish Captain", "Elvish Champion", "Elvish Druid", "Elvish Enchantress", "Elvish Fighter", "Elvish Hero", "Elvish High Lord", "Elvish Lady", "Elvish Lord", "Elvish Marksman", "Elvish Marshal", "Elvish Outrider", "Elvish Ranger", "Elvish Rider", "Elvish Scout", "Elvish Shaman", "Elvish Sharpshooter", "Elvish Shyde", "Elvish Sorceress", "Elvish Sylph", "Direwolf Rider", "Goblin Impaler", "Goblin Knight", "Goblin Pillager", "Goblin Rouser", "Goblin Spearman", "Wolf Rider", "Gryphon", "Gryphon Master", "Gryphon Rider", "Horseman", "Grand Knight", "Knight", "Lancer", "Paladin", "Bowman", "Cavalier", "Cavalryman", "Dragoon", "Duelist", "Fencer", "General", "Grand Marshal", "Halberdier", "Heavy Infantryman", "Iron Mauler", "Javelineer", "Lieutenant", "Longbowman", "Master at Arms", "Master Bowman", "Pikeman", "Royal Guard", "Sergeant", "Shock Trooper", "Spearman", "Swordsman", "Mage", "Arch Mage", "Elder Mage", "Great Mage", "Mage of Light", "Red Mage", "Silver Mage", "White Mage", "Outlaw", "Assassin", "Bandit", "Footpad", "Fugitive", "Highwayman", "Rogue", "Ruffian", "Thief", "Thug", "Peasant", "Royal Warrior", "Woodsman", "Huntsman", "Poacher", "Ranger", "Trapper", "Arif", "Batal", "Elder Falcon", "Falcon", "Faris", "Ghazi", "Hadaf", "Hakim", "Jawal", "Jundi", "Khaiyal", "Khalid", "Mighwar", "Monawish", "Mudafi", "Mufariq", "Muharib", "Naffat", "Qanas", "Qatif_al_nar", "Rami", "Rasikh", "Saree", "Shuja", "Tabib", "Tineen", "Mermaid Diviner", "Mermaid Enchantress", "Merman Entangler", "Merman Fighter", "Merman Hoplite", "Merman Hunter", "Mermaid Initiate", "Merman Javelineer", "Merman Netcaster", "Mermaid Priestess", "Mermaid Siren", "Merman Spearman", "Merman Triton", "Merman Warrior", "Cuttle Fish", "Fire Dragon", "Fire Guardian", "Giant Mudcrawler", "Giant Rat", "Giant Scorpion", "Giant Spider", "Mudcrawler", "Sea Serpent", "Skeletal Dragon", "Tentacle of the Deep", "Water Serpent", "Wolf", "Direwolf", "Great Wolf", "Yeti", "Naga Fighter", "Naga Myrmidon", "Naga Warrior", "Ogre", "Young Ogre", "Orcish Archer", "Orcish Assassin", "Orcish Crossbowman", "Orcish Grunt", "Orcish Leader", "Orcish Ruler", "Orcish Slayer", "Orcish Slurbow", "Orcish Sovereign", "Orcish Warlord", "Orcish Warrior", "Saurian Ambusher", "Saurian Augur", "Saurian Flanker", "Saurian Oracle", "Saurian Skirmisher", "Saurian Soothsayer", "Great Troll", "Troll Hero", "Troll Rocklobber", "Troll", "Troll Shaman", "Troll Warrior", "Troll Whelp", "Ghast", "Ghoul", "Necrophage", "Soulless", "Walking Corpse", "Necromancer", "Ancient Lich", "Dark Adept", "Dark Sorcerer", "Lich", "Skeleton", "Skeleton Archer", "Banebow", "Bone Shooter", "Chocobone", "Deathblade", "Death Knight", "Draug", "Revenant", "Ghost", "Nightgaunt", "Shadow", "Spectre", "Wraith", "Ancient Wose", "Elder Wose", "Wose"}

function unit_selection.get_unit_types_current_era_ids(leaders)
	local era = wesnoth.game_config.era
	era = era or {
		T.multiplayer_side {
			recruit = table.concat(mainline_units, ",")
		}
	}
	local units = {}
	for multiplayer_side in helper.child_range(era, "multiplayer_side") do
		if multiplayer_side.recruit ~= nil then
			for word in string.gmatch(multiplayer_side.recruit, '([^,]+)') do
				units[pyr_npt_helper.trim(word)] = true
			end
		end
		if multiplayer_side.leader ~= nil and leaders then
			for word in string.gmatch(multiplayer_side.leader, '([^,]+)') do
				units[pyr_npt_helper.trim(word)] = true
			end
		end
	end
	return units
end

-- returns a list containg get_unit_types_current_era and all units that those units can advance to
function unit_selection.get_unit_types_current_era_and_advancemts()
	local units_to_do = unit_selection.get_unit_types_current_era_ids(true)
	local r = {}
	local known_units = pyr_npt_helper.deepcopy(units_to_do)
	-- while there are units to do
	while next(units_to_do) ~= nil do
		local next_units_to_do = {}
		for k,v in pairs(units_to_do) do
			local cfg = (wesnoth.unit_types[k] or {}).__cfg
			if cfg ~= nil then
				table.insert(r, cfg)
				for word in string.gmatch(cfg.advances_to or "", '([^,]+)') do
					local unitid = pyr_npt_helper.trim(word)
					if known_units[unitid] == nil then
						known_units[unitid] = true
						next_units_to_do[unitid] = true
					end
				end
			else
				--wesnoth.wml_actions.wml_message { message = "Found unknown unittype: " .. k, logger = "err", to_chat = false}
			end
		end
		units_to_do = next_units_to_do
	end
	table.sort(r, function(u1,u2) return tostring(u1.name) < tostring(u2.name) end)
	
	return r
end

-- returns a list containg every unit that is recruitable by any side.
function unit_selection.get_unit_types_current_era()

	local units = unit_selection.get_unit_types_current_era_ids()
	local r = {}
	for key,value in pairs(units) do
		if not wesnoth.unit_types[key] then
		else
			table.insert(r, wesnoth.unit_types[key].__cfg)
		end
	end
	-- In case the era didn't specify any recruits or contained only invlid recruits use the mainline units.
	if #r == 0 then
		for k,v in ipairs(mainline_units) do
			if not wesnoth.unit_types[v] then
				wesnoth.message("Pyr npt Mod", "Cound not find mainline unit '" .. v .. "'")
			else
				table.insert(r, wesnoth.unit_types[v].__cfg)
			end
		end
	end
	table.sort(r, function(u1,u2) return tostring(u1.name) < tostring(u2.name) end)
	return r
end

function unit_selection.get_unit_types_all()
	local r = {}
	for key,value in pairs(wesnoth.unit_types) do
		local cfg = value.__cfg
		--Those unit are normaly not meant to be recruited
		if not cfg.hide_help then
			table.insert(r, cfg)
		end
	end
	table.sort(r, function(u1,u2) return tostring(u1.name) < tostring(u2.name) end)
	return r
end

function unit_selection.get_unit_types_original(side)
	local r = {}
	for k,v in pairs(wesnoth.sides[side].recruit) do
		if not wesnoth.unit_types[v] then
			wesnoth.message("Pyr npt Mod", "Cound not find unit type '" .. v .. "'")
		else
			table.insert(r, wesnoth.unit_types[v].__cfg)
		end
	end
	table.sort(r, function(u1,u2) return tostring(u1.name) < tostring(u2.name) end)
	return r
end

--returns an array of wmltables for all unit types available.
function unit_selection.get_unit_types(side)
	local pool_type = tostring(V.pyr_npt_unit_pool_type or "recruitable")
	if pool_type == "recruitable" then
		return unit_selection.get_unit_types_current_era()
	elseif pool_type == "advanceable" then
		return unit_selection.get_unit_types_current_era_and_advancemts()
	elseif pool_type == "all" then
		return unit_selection.get_unit_types_all()
	elseif pool_type == "original" then
		return unit_selection.get_unit_types_original(side)
	else
		return {
			-- some default value i used for testing.
			wesnoth.unit_types["Ancient Lich"].__cfg, 
			wesnoth.unit_types["Elvish Champion"].__cfg,
			wesnoth.unit_types["Orcish Slayer"].__cfg,
		}
	end
end

function unit_selection.get_unit_races(unit_types)
	local found_races = {}
	local retv = {}
	for key,value in pairs(unit_types) do
		if found_races[value.race or "unknown"] ~= true then
			if value.race == nil then
				table.insert(retv, {plural_name = "Unknown", id = "unknown"})
			else
				local race = wesnoth.races[value.race or ""]
				if race then
					table.insert(retv, wesnoth.races[value.race or ""].__cfg)
				else
					wesnoth.message("Pyr npt Mod", "found a unittype with an invalid race '" .. tostring(value.race) .. "'")
				end
			end
		end
		found_races[value.race or ""] = true
	end
	table.sort(retv, function(r1,r2) return tostring(r1.plural_name) < tostring(r2.plural_name) end)
	return retv
end

function unit_selection.get_biggest_race_size(unit_types)
	
	local maxkey, maxvalue = pyr_npt_helper.tablemax(
		pyr_npt_helper.tablegroupby(unit_types, function(index, ut) return (ut.race or "unknown") end),
		function(t1,t2) return #t1 < #t2 end
	)
	return maxvalue and #maxvalue or 0
end

-- used for ai sides and for 'fill randomly'
function unit_selection.random_choice(unittypes, max_gold, max_count)
	--choose random types.
	local r = {}
	local units_left = max_count
	local gold_left = max_gold
	while units_left > 0 do
		
		local max_cost = pyr_npt_helper.min(gold_left, (1.7 * gold_left / units_left))
		local prefered_units = {}
		local acceptable_units = {}
		for index, unit in ipairs(unittypes) do
			if unit.cost <= max_cost then
				table.insert(prefered_units, {index = index, unit = unit})
			end
			if unit.cost <= gold_left then
				table.insert(acceptable_units, {index = index, unit = unit})
			end
		end
		if #prefered_units ~= 0 then
			acceptable_units = prefered_units
		end
		
		if #acceptable_units > 0 then
			local i = math.random(#acceptable_units)
			table.insert(r, acceptable_units[i].unit)
			table.remove(unittypes, acceptable_units[i].index)
			units_left = units_left - 1
			gold_left = gold_left - acceptable_units[i].unit.cost
		else
			return r
		end
		
	end
	return r
end

function unit_selection.fill_random(chosen_units, all_unittypes, max_gold, max_count)
	local gold_left = max_gold
	local count_left = max_count
	local available_units = {}
	for k, u in pairs(all_unittypes) do
		if not pyr_npt_helper.tablecontains(chosen_units, k) then
			table.insert (available_units, {cost = u.cost, id = u.id, index = k})
		else
			count_left = count_left - 1
			gold_left = gold_left - u.cost
		end
	end
	local ids = unit_selection.random_choice(available_units, gold_left, count_left)
	for k, u in pairs(ids) do
		table.insert(chosen_units, u.index)
	end
end

-- @a side: the number of the side to select recruits for
-- @returns an array of unit id strings.
function unit_selection.do_selection(side)
	local pyr_npt_helper = pyr_npt_helper
	local dialogs = pyr_npt_unit_selection_dialogs
	local unit_types = unit_selection.get_unit_types(side)
	local unit_races = unit_selection.get_unit_races(unit_types)
	local maxrace_size = unit_selection.get_biggest_race_size(unit_types)
	local max_selectalbe_units_l = unit_selection.max_selectalbe_units()
	
	--a list containing integerindexes to unit_types
	local current_unit_list = {}
	--a list containing integerindexes to unit_types
	local chosen_units = {}
	local current_selected_unit_index = 0
	
	
	
	local get_chosen_unit_ids = function()
		return pyr_npt_helper.tablemap(chosen_units, function(index) return unit_types[index].id end)
	end
	
	local set_race = function(race_number)
		race_number = race_number or wesnoth.get_dialog_value("race_list")
		local race_id = unit_races[race_number].id
		local index = 1
		current_unit_list = {}
		for index2,value in ipairs(unit_types) do
			if value.race == race_id then
				wesnoth.set_dialog_value((value.image or "") .."~SCALE(72,72)", "unit_list", index, "list_image")
				wesnoth.set_dialog_value((value.name or "") .. "\n" .. (value.cost or "") .. _"Gold", "unit_list", index, "list_name")
				current_unit_list[index] = index2
				index = index + 1
			end
		end
		while index <= maxrace_size do
			wesnoth.set_dialog_value(pyr_npt_helper.thex_png , "unit_list", index, "list_image")
			wesnoth.set_dialog_value(" \n ", "unit_list", index, "list_name")
			index = index + 1
			
		end
	end
	
	local update_unit = function()
		wesnoth.set_dialog_value(wesnoth.unit_types[unit_types[current_selected_unit_index].id], "unit_preview")
	end
	
	local set_unit = function()
		local unit_number = wesnoth.get_dialog_value("unit_list")
		if current_unit_list[unit_number] == nil then return end
		current_selected_unit_index = current_unit_list[unit_number]
		update_unit()
	end
	
	local set_unit_chosen = function()
		local unit_number = wesnoth.get_dialog_value("chosen_unit_list")
		if chosen_units[unit_number] == nil then return end
		current_selected_unit_index = chosen_units[unit_number]
		update_unit()
	end
	
	local update_chosen_units = function()
		local index = 1
		for index2,value in ipairs(chosen_units) do
			wesnoth.set_dialog_value((unit_types[value].image or "") .."~SCALE(72,72)", "chosen_unit_list", index2, "list_image2")
			index = index2 + 1
		end
		while index <= max_selectalbe_units_l do
			wesnoth.set_dialog_value(pyr_npt_helper.thex_png , "chosen_unit_list", index, "list_image2")
			index = index + 1
		end
		local costs = pyr_npt_helper.tablereduce(chosen_units, function(a,b) return a + unit_types[b].cost end, 0)
		local maxcost = unit_selection.max_selectalbe_units_gold_limit()
		local countdig = math.floor(math.log10(math.max(#chosen_units, 1)))
		local spaces_to_add = string.rep(' ',3*(5-countdig))
		local costdig = math.floor(math.log10(math.max(costs, 1)))
		local cost_spaces_to_add = string.rep(' ',3*(5-costdig))
		
		wesnoth.set_dialog_value(_"Count:" ..  tostring(#chosen_units) .. spaces_to_add, "pyr_total_count")
		if(maxcost == 1000000000) then
			wesnoth.set_dialog_value(_"Cost:" ..  tostring(costs) .. cost_spaces_to_add, "pyr_total_cost")
		else
			wesnoth.set_dialog_value(_"Cost:" ..  tostring(costs) .. "/"..  tostring(maxcost) .. cost_spaces_to_add, "pyr_total_cost")
		end
	end
	
	local on_add_button = function()
		if pyr_npt_helper.tablecontains(chosen_units, current_selected_unit_index) then return end
		table.insert(chosen_units, current_selected_unit_index)
		if unit_selection.is_valid_recuitlist(get_chosen_unit_ids()) and #chosen_units <= max_selectalbe_units_l then
			update_chosen_units()
			update_chosen_units()
		else
			pyr_npt_helper.tableremovevalue(chosen_units, current_selected_unit_index)
		end
	end
	
	local on_remove_button = function()
		if not pyr_npt_helper.tablecontains(chosen_units, current_selected_unit_index) then return end
		pyr_npt_helper.tableremovevalue(chosen_units, current_selected_unit_index)
		if unit_selection.is_valid_recuitlist(get_chosen_unit_ids()) then
			update_chosen_units()
		else
			table.insert(chosen_units, current_selected_unit_index)
		end
	end
	
	local on_remove_all_button = function()
		chosen_units = {}
		update_chosen_units()
	end
	
	local on_random_button = function()
		local max_gold = unit_selection.max_selectalbe_units_gold_limit()
		local max_count = max_selectalbe_units_l
		unit_selection.fill_random(chosen_units, unit_types, max_gold, max_count)
		update_chosen_units()
	end

	local preshow = function()
		for index,value in ipairs(unit_races) do
			wesnoth.set_dialog_value(unit_races[index].plural_name or "a", "race_list",index, "race_name")
		end
		wesnoth.set_dialog_value(_"Unit selction for side " .. tostring(side or 1), "title")
		wesnoth.set_dialog_callback(set_race, "race_list")
		wesnoth.set_dialog_callback(set_unit, "unit_list")
		wesnoth.set_dialog_callback(set_unit_chosen, "chosen_unit_list")
		wesnoth.set_dialog_callback(on_add_button, "add_button")
		wesnoth.set_dialog_callback(on_remove_button, "remove_button")
		wesnoth.set_dialog_callback(on_remove_all_button, "remove_all_button")
		wesnoth.set_dialog_callback(on_random_button, "random_choice_button")
		set_race()
		set_unit()
		update_chosen_units()
	end

	wesnoth.show_dialog(dialogs.normal, preshow)
	return get_chosen_unit_ids()
end

return unit_selection
-->>
