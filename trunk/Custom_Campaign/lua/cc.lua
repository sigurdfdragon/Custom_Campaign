-- #textdomain wesnoth-Custom_Campaign

-- global so the wesnoth. part is not needed, improves readability
wml_actions = wesnoth.wml_actions

local cc = {}

-- Leaving in Khalifate, they will be considered core if player has the add-on.
cc["core_list"] = "Ancient Lich,Ancient Wose,Arch Mage,Arif,Armageddon Drake,Assassin,Bandit,Banebow,Batal,Blood Bat,Boat,Bone Shooter,Bowman,Cavalier,Cavalryman,Chocobone,Cuttle Fish,Dark Adept,Dark Sorcerer,Death Knight,Deathblade,Direwolf,Direwolf Rider,Dragoon,Drake Arbiter,Drake Blademaster,Drake Burner,Drake Clasher,Drake Enforcer,Drake Fighter,Drake Flameheart,Drake Flare,Drake Glider,Drake Thrasher,Drake Warden,Drake Warrior,Draug,Dread Bat,Duelist,Dwarvish Arcanister,Dwarvish Berserker,Dwarvish Dragonguard,Dwarvish Explorer,Dwarvish Fighter,Dwarvish Guardsman,Dwarvish Lord,Dwarvish Pathfinder,Dwarvish Runemaster,Dwarvish Runesmith,Dwarvish Scout,Dwarvish Sentinel,Dwarvish Stalwart,Dwarvish Steelclad,Dwarvish Thunderer,Dwarvish Thunderguard,Dwarvish Ulfserker,Elder Falcon,Elder Mage,Elder Wose,Elvish Archer,Elvish Avenger,Elvish Captain,Elvish Champion,Elvish Druid,Elvish Enchantress,Elvish Fighter,Elvish Hero,Elvish High Lord,Elvish Lady,Elvish Lord,Elvish Marksman,Elvish Marshal,Elvish Outrider,Elvish Ranger,Elvish Rider,Elvish Scout,Elvish Shaman,Elvish Sharpshooter,Elvish Shyde,Elvish Sorceress,Elvish Sylph,Falcon,Faris,Fencer,Fire Dragon,Fire Drake,Fire Guardian,Fog Clearer,Footpad,Fugitive,Galleon,General,Ghast,Ghazi,Ghost,Ghoul,Giant Mudcrawler,Giant Rat,Giant Scorpion,Giant Spider,Goblin Impaler,Goblin Knight,Goblin Pillager,Goblin Rouser,Goblin Spearman,Grand Knight,Grand Marshal,Great Mage,Great Troll,Great Wolf,Gryphon,Gryphon Master,Gryphon Rider,Hadaf,Hakim,Halberdier,Heavy Infantryman,Highwayman,Horseman,Huntsman,Hurricane Drake,Inferno Drake,Iron Mauler,Javelineer,Jawal,Jundi,Khaiyal,Khalid,Knight,Lancer,Lich,Lieutenant,Longbowman,Mage,Mage of Light,Master at Arms,Master Bowman,Mermaid Diviner,Mermaid Enchantress,Mermaid Initiate,Mermaid Priestess,Mermaid Siren,Merman Entangler,Merman Fighter,Merman Hoplite,Merman Hunter,Merman Javelineer,Merman Netcaster,Merman Spearman,Merman Triton,Merman Warrior,Mighwar,Monawish,Mudafi,Mudcrawler,Mufariq,Muharib,Naffat,Naga Fighter,Naga Myrmidon,Naga Warrior,Necromancer,Necrophage,Nightgaunt,Ogre,Orcish Archer,Orcish Assassin,Orcish Crossbowman,Orcish Grunt,Orcish Leader,Orcish Ruler,Orcish Slayer,Orcish Slurbow,Orcish Sovereign,Orcish Warlord,Orcish Warrior,Outlaw,Paladin,Peasant,Pikeman,Pirate Galleon,Poacher,Qanas,Qatif-al-nar,Rami,Ranger,Rasikh,Red Mage,Revenant,Rogue,Royal Guard,Royal Warrior,Ruffian,Saree,Saurian Ambusher,Saurian Augur,Saurian Flanker,Saurian Oracle,Saurian Skirmisher,Saurian Soothsayer,Sea Serpent,Sergeant,Shadow,Shock Trooper,Shuja,Silver Mage,Skeletal Dragon,Skeleton,Skeleton Archer,Sky Drake,Soulless,Spearman,Spectre,Swordsman,Tabib,Tentacle of the Deep,Thief,Thug,Tineen,Transport Galleon,Trapper,Troll,Troll Hero,Troll Rocklobber,Troll Shaman,Troll Warrior,Troll Whelp,Vampire Bat,Walking Corpse,Water Serpent,White Mage,Wolf,Wolf Rider,Woodsman,Wose,Wraith,Yeti,Young Ogre"

---------------- UTILS GENERAL USE ---------------------------------

function cc.deep_copy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function cc.split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find( str, delimiter, from  )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from  )
    end
    table.insert( result, string.sub( str, from  ) )
    return result
end

--! Displays a WML text input message box with attributes from table @attr
--! with optional table @options containing optional label, max_length, and text key/value pairs.
--! @returns the entered text.
function cc.get_text_input(attr, options)
	options = options or {}
	local msg = {}
	for k,v in pairs(attr) do
		msg[k] = attr[k]
	end
	local ti = {}
	for k,v in pairs(options) do
		ti[k] = options[k]
	end
	ti["variable"]="LUA_text_input"
	table.insert(msg, { "text_input", ti })
	wml_actions.message(msg)
	local result = wesnoth.get_variable("LUA_text_input")
	wesnoth.set_variable("LUA_text_input")
	return result
end

function cc.get_user_choice(attr, options, start_count)
	-- start count is so that items can be appended before an array (ie, -1, 0)
	local sc = start_count or 1
	local result = 0
	function wesnoth.__user_choice_helper(i)
		result = i
	end
	local msg = {}
	for k,v in pairs(attr) do
		msg[k] = attr[k]
	end
	for k = sc, #options do
		table.insert(msg, { "option", { message = options[k],
			{ "command", { { "lua", {
				code = string.format("wesnoth.__user_choice_helper(%d)", k)
			}}}}}})
	end
	wml_actions.message(msg)
	wesnoth.__user_choice_helper = nil
	return result
end

function cc.get_global_array(namespace, from_global, side)
	wml_actions.get_global_variable({ namespace=namespace, from_global=from_global, 
		to_local="LUA_persistent_array", side=side })
	local t = helper.get_variable_array("LUA_persistent_array")
	wesnoth.set_variable("LUA_persistent_array")
	return t
end

function cc.get_global_variable(namespace, from_global, side)
	wml_actions.get_global_variable({ namespace=namespace, from_global=from_global, 
		to_local="LUA_persistent_variable", side=side })
	local variable = wesnoth.get_variable("LUA_persistent_variable")
	wesnoth.set_variable("LUA_persistent_variable")
	return variable
end

function cc.set_global_array(namespace, t, to_global, side, bool)
	helper.set_variable_array("LUA_persistent_array", t)
	wml_actions.set_global_variable({ namespace=namespace, from_local="LUA_persistent_array", 
		to_global=to_global, side=side, immediate=bool })
	wesnoth.set_variable("LUA_persistent_array")
end

function cc.set_global_variable(namespace, variable, to_global, side, bool)
	wesnoth.set_variable("LUA_persistent_variable", variable)
	wml_actions.set_global_variable({ namespace=namespace, from_local="LUA_persistent_variable", 
		to_global=to_global, side=side, immediate=bool })
	wesnoth.set_variable("LUA_persistent_variable")
end

function cc.get_unit_type_ids()
	local unit_types = wesnoth.get_unit_type_ids()
	-- remove unit_types not intended to be listed	
	for t = #unit_types, 1, -1 do
        if wesnoth.unit_types[unit_types[t]].__cfg.do_not_list ~= nil then
            table.remove(unit_types, t)
        elseif wesnoth.unit_types[unit_types[t]].__cfg.hide_help ~= nil then
            table.remove(unit_types, t)
		end
	end
	return unit_types
end

------------------- UTILS SPECIFIC USE -------------------------------

function cc.store_starting_sides()
	-- store starting sides so they can be used to make a faction or army
	side = {} -- makes a global side table
	for i = 1, 9 do
		-- get the leader for the side
		local loc = wesnoth.get_starting_location(i)
		local u = wesnoth.get_unit(loc[1], loc[2])
		wesnoth.extract_unit(u)
		
		-- get recruit & recruitment_pattern
		local s = wesnoth.sides[i].__cfg
		local ai = helper.get_child(s, "ai")
		local a = helper.get_child(ai, "aspect", "recruitment_pattern")
		local f = helper.get_child(a, "facet")
		local r, rp
		-- some don't have facet, account for this
		if f == nil then
			rp = ""
		else
			rp = f.value
		end
		local r = ""
		if s.recruit == nil then
			r = ""
		else
			r = s.recruit
		end
		-- make the entry in the side table
		side[i] = { leader = u.__cfg.type, gender = u.__cfg.gender, image = u.__cfg.image,
			recruit = r, recruitment_pattern = rp }
	end
	
	-- Remove sides that are Custom
	for i = #side, 1, -1 do
		if side[i].leader == "Custom Campaign Unit" then
			table.remove(side, i)
		end
	end
end

function cc.load_globals()
	army = cc.get_global_array("SigurdFireDragon_Custom_Campaign", "army", 1)
	faction = cc.get_global_array("SigurdFireDragon_Custom_Campaign", "faction", 1)
	id_counter = cc.get_global_variable("SigurdFireDragon_Custom_Campaign", "id_counter", 1)
	if id_counter == nil or id_counter == "" then
		id_counter = 0
	end -- nil or "" causes errors in incrementing the counter
end

function cc.save_globals()
	cc.set_global_array("SigurdFireDragon_Custom_Campaign", army, "army", 1, false)
	cc.set_global_array("SigurdFireDragon_Custom_Campaign", faction, "faction", 1, false)
	cc.set_global_variable("SigurdFireDragon_Custom_Campaign", id_counter, "id_counter", 1, false)
end

function cc.endlevel()
	wml_actions.endlevel({ result="victory", carryover_report="no",
		carryover_percentage=0, carryover_add="no", bonus="no",
		linger_mode="no", save="no", replay_save="no" })
end

function cc.name_sort(e1, e2)
	return e1.name < e2.name
end

function cc.clear_ids(u_wml)
	-- Recieves a unit wml table and clears id fields
	-- to prevent underlying_id collisions when units get placed on the recall list.
	-- Main Leader does not have id cleared, only underlying_id.
	if u_wml.id == "Main Leader" then
		u_wml.underlying_id = nil -- only clear this
	else -- clear both id's
		u_wml.underlying_id = nil; u_wml.id = nil;
	end
end

function cc.clear_menu_items()
	for i = 1, 7 do
		wml_actions.set_menu_item({ id=i, description="Null",
			{ "show_if", { { "variable", { name="This_will_hide", equals="_this_menu_item" } } } },
			{ "command", { { "lua", { code="" } } } }
		})
	end
end

function cc.unpack_entry(entry, side, name)
	-- recieves a table describing the entry to unpack, and the side to unpack it to.
	-- optional name for leader (used for displaying faction & side in scenario)
	
	-- army stuff, entry.leader will be nil for army
	if entry.leader == nil then
		-- unpack army to recall list
		for u in helper.child_range(entry, "troop_list") do
			cc.clear_ids(u)
			u.side = side
			if wesnoth.unit_types[u.type] then
				wesnoth.put_recall_unit(u)
			end
		end
		
		local loc = wesnoth.get_starting_location(side)
		
		-- place Main Leader on keep
		wml_actions.recall({ x=loc[1], y=loc[2], id="Main Leader", show="no", fire_event="no" })
		
		-- recall any important leaders, expendable leaders, and heroes
		local recall_list = wesnoth.get_recall_units({ side=side })
		for u = 1, #recall_list do
			if recall_list[u].canrecruit == true or recall_list[u].role == "Hero" then
				local id = recall_list[u].id
				wml_actions.recall({ x=loc[1], y=loc[2], id=id, show="no", fire_event="no" })
			end
		end

		-- additional recalls
		if entry.starting_recall == -1 then
			-- recall all loyal troops
			local recall_list = wesnoth.get_recall_units({ side=side })
			for i = 1, #recall_list do
				wml_actions.recall({ x=loc[1], y=loc[2], { "filter_wml", { upkeep="loyal" }}, show="no", fire_event="no" })
			end
		elseif entry.starting_recall > 0 then
			-- sort troops by value and recall the specified number
			-- sort order: loyal, level, least XP to levelup
			local recall_list = wesnoth.get_recall_units({ side=side })
			local function unit_value_sort(u1, u2)				
				if u1.__cfg.upkeep == u2.__cfg.upkeep then
					if u1.__cfg.level == u2.__cfg.level then
						return u1.max_experience - u1.experience < u2.max_experience - u2.experiencu
					else
						return u1.__cfg.level > u2.__cfg.level
					end
				else
					return u1.__cfg.upkeep > u2.__cfg.upkeep
				end
			end
			table.sort(recall_list, unit_value_sort)
			for u = 1, entry.starting_recall do
				local id = recall_list[u].id
				wml_actions.recall({ x=loc[1], y=loc[2], id=id, show="no", fire_event="no" })
			end
		end
	else -- faction and side stuff
		local loc = wesnoth.get_starting_location(side)
		-- check for missing unit
		if wesnoth.unit_types[entry.leader] == nil then
			wesnoth.put_unit(loc[1], loc[2], { side=side, type="Custom Campaign Unit", canrecruit=true, facing="se" })
		else
			wesnoth.put_unit(loc[1], loc[2], { side=side, type=entry.leader, name=name, gender=entry.gender, canrecruit=true })
		end
	end
	-- things common to all unpacking: set recruit & recruitment_pattern

	local recruit = cc.remove_missing_recruits(entry.recruit)
	
	wml_actions.set_recruit({ side=side, recruit=recruit })
	wml_actions.modify_side({ side=side, { "ai", { recruitment_pattern=entry.recruitment_pattern } } } )
end

function cc.recruit_translate(rl)
	if rl ~= nil and rl ~= "" then
		local t = cc.split(rl, ",")
		for i,v in ipairs(t) do
			if wesnoth.unit_types[v] ~= nil then
				t[i] = tostring(wesnoth.unit_types[v].name)
			else
				t[i] = "----------"
			end
		end
		table.sort(t)
		return table.concat(t, ",")
	else -- list is empty
		return ""
	end
end

function cc.race_translate(rl)
	if rl ~= nil and rl ~= "" then
		local t = cc.split(rl, ",")
		for i,v in ipairs(t) do
			if wesnoth.races[v] ~= nil then
				t[i] = tostring(wesnoth.races[v].plural_name)
			else
				t[i] = "----------"
			end
		end
		table.sort(t)
		return table.concat(t, ",")
	else -- list is empty
		return ""
	end
end
		
function cc.remove_missing_recruits(recruit)
	-- recieves a recruit list, returns a recruit list
	if recruit ~= nil and recruit ~= "" then
		local recruit_list = cc.split(recruit, ",")
		for i = #recruit_list, 1, -1 do
			if wesnoth.unit_types[recruit_list[i]] == nil then
				table.remove(recruit_list, i)
			end
		end
		if next(recruit_list) ~= nil then
			recruit = table.concat(recruit_list, ",")
		else
			recruit = ""
		end
	end
	return recruit
end

function cc.back_button()
	return "&back_small.png=" .. _"Back"
end

function cc.add_button()
	return "&plus_small.png=" .. _"Add New Entry"
end

function cc.end_button()
	return "&stop_small.png=" .. _"End"
end

function cc.faction_display_list()
	local t = {}
	
	for i = 1, #faction do
		local d = {}
		if wesnoth.unit_types[faction[i].leader] == nil then
			d.image = "units/unknown-unit.png"
			d.leader = "----------"
		else
			d.image = faction[i].image
			-- get gender correct name
			local u = wesnoth.create_unit({ type=faction[i].leader, gender=faction[i].gender })
			d.leader = u.__cfg.language_name
		end
		d.name = faction[i].name
		d.recruit = cc.recruit_translate(faction[i].recruit)
		d.recruitment_pattern = faction[i].recruitment_pattern
		
		-- assemble the [message] entry
		t[i] = "&" .. d.image .. "~RC(magenta>red)=" .. d.name ..
		 "\n<small><small>" .. _"Leader: " .. d.leader .. 
		 "\n" .. _"Recruit: " .. d.recruit .. 
		 "\n" .. _"Recruitment pattern: " .. d.recruitment_pattern .. "</small></small>="
	end
	return t
end

function cc.side_display_list()
	local t = {}
	
	for i = 1, #side do
		local d = {}
		-- get gender correct unit name
		local u = wesnoth.create_unit({ type=side[i].leader, gender=side[i].gender })
		d.leader = u.__cfg.language_name
		d.image = side[i].image
		d.recruit = cc.recruit_translate(side[i].recruit)
		d.recruitment_pattern = side[i].recruitment_pattern

		-- assemble the [message] entry
		t[i] = "&" .. d.image .. "~RC(magenta>red)=" ..
		 "<small><small>" .. _"Leader: " .. d.leader .. 
		 "\n" .. _"Recruit: " .. d.recruit .. 
		 "\n" .. _"Recruitment pattern: " .. d.recruitment_pattern .. "</small></small>="
	end
	return t
end
	
function cc.army_display_list()
	-- copies data from @army and places it into an array for displaying in [message]
	-- no nill values should be in the army array	
	local t = {}

	for i = 1, #army do
		
		local d = {}
		-- get leader info
		local u = helper.get_child(army[i], "troop_list", "Main Leader")
		if wesnoth.unit_types[u.type] ~= nil then
			d.image = u.image
			d.language_name = u.language_name
			d.leader_name = u.name
		else
			d.image = "units/unknown-unit.png"
			d.language_name = "----------"
			d.leader_name = u.name
		end


		d.name = army[i].name
		d.troops = #army[i] - 1 -- subtract for primary leader
		d.last_victory = army[i].last_victory
		d.recruit = cc.recruit_translate(army[i].recruit)
		d.recruitment_pattern = army[i].recruitment_pattern
		if army[i].starting_recall == -1 then
			d.starting_recall = _"Loyal"
		else
			d.starting_recall = army[i].starting_recall
		end
		d.victories = army[i].victories
		
		-- assemble the [message] entry
		t[i] = "&" .. d.image .. "~RC(magenta>red)=" .. d.name ..
		 "\n<small><small>" .. _"Main Leader: " .. d.leader_name .. ", " .. d.language_name .. 
		 "\n" .. _"Troops: " .. d.troops .. _"  Starting Recall: " .. d.starting_recall .. _"  Victories: " .. d.victories .. _"  Last Victory: " .. d.last_victory .. 
		 "\n" .. _"Recruit: " .. d.recruit .. 
		 "\n" .. _"Recruitment Pattern: " .. d.recruitment_pattern .. "</small></small>="
	end
	
	return t
end

function cc.leader_display_list(index)
	-- Recieves an index in the army array
	-- Returns a table to display the leaders for army[index]
	local t = {}
	local function leader_sort(u1, u2)
		if     u1[2].id == "Main Leader" then return true
		elseif u2[2].id == "Main Leader" then return false
		elseif u1[2].role == "Leader" then return true
		elseif u2[2].role == "Leader" then return false
		elseif u1[2].role == "Expendable Leader" then return true
		elseif u2[2].role == "Expendable Leader" then return false
		else return false
		end
	end
	table.sort(army[index], leader_sort)
	
	local i = 0
	for u in helper.child_range(army[index], "troop_list") do
		local d = {}
		if u.canrecruit == true then
			if wesnoth.unit_types[u.type] ~= nil then
				d.image = u.image
				d.language_name = u.language_name
			else
				d.image = "units/unknown-unit.png"
				d.language_name = "----------"
			end
			d.leader_name = u.name
			d.extra_recruit = cc.recruit_translate(u.extra_recruit)
			if u.role == "Leader" then
				d.role = _"Leader"
			elseif u.role == "Expendable Leader" then
				d.role = _"Expendable Leader"
			end
			
			for i = 1, #u do
				if u[i][1] == "filter_recall" then
					if u[i][2].type then
						d.filter_recall = cc.recruit_translate(u[i][2].type)
					elseif u[i][2].race then
						d.filter_recall = cc.race_translate(u[i][2].race)
					else
						d.filter_recall = _"All units"
					end
				end
			end
			
			i = i + 1
			-- assemble the [message] entry
			t[i] = "&" .. d.image .. "~RC(magenta>red)=" .. d.leader_name .. ", " .. d.language_name ..
			 "\n<small><small>" .. d.role ..
			 "\n" .. _"Extra Recruit: " .. d.extra_recruit ..
			 "\n" .. _"Filter Recall: " .. d.filter_recall .. "</small></small>="
		else
			break -- we are out of leaders
		end
	end
	return t
end

----------------- SCENARIO PRESTART -----------------

function cc.scenario_prestart()
	 -- Prepare the map for running the main_menu
	 -- Override lobby fog & shroud settings, Clear objectives, Disable other sides
	 -- TODO: Override chosen color to red when ability is added to modify_side
	 -- TODO: If possible, replace warning about launching map with code that
		   -- will make the player in control of side 1
	wesnoth.set_variable("=this_will_prevent_loading", "_this_map_from_a_save")
	-- This is checked for in cc.era_prestart()
	wesnoth.set_variable("cc_scenario", true)

	if wesnoth.sides[1].controller ~= "human" then
		wml_actions.message({ speaker="narrator", message=_"This map must be launched with a human controller for side 1" })
		return cc.endlevel()
	end

	cc.load_globals()
	cc.store_starting_sides()
	cc.reset_unit_filters()
	cc.clear_menu_items()
	wml_actions.modify_side({ side="1", gold="1000", income="-2" })
	wml_actions.set_recruit({ side="1", recruit="" })
	wml_actions.modify_side({ side="1", controller="human", fog="no", shroud="no" })
	wml_actions.objectives({ silent="yes" })
	
	for i = 2, 9 do
		wml_actions.modify_side({ side=i, controller="null" })
	end
	
	-- create the turn refresh event
	-- prevent turn from advancing so save list isn't cluttered & gold kept constant
	-- done this way instead of [disable_end_turn] because we need the player to be
	-- able to move the leaders & units around and use end_turn to refresh move count.
	wml_actions.event({ name="turn refresh", first_time_only="no",
		{ "lua", { code=[[
							wml_actions.modify_turns({ current="1" })
							wml_actions.modify_side({ side="1", gold="1000" })
						]] } } })
end

------------------ ERA PRESTART --------------------

-- look through all sides on map
-- let player choose an army for a human controlled side (player may want to play as a side other than 1)
-- display warning if player launched the map with more than 1 human controlled side and quit
-- let player select factions for AI sides.
function cc.era_prestart()
	-- Not used, but could be checked for by scenarios
	wesnoth.set_variable("cc_era", true)
	
	-- disable era functionality if launched with Custom Campaign Map
	if wesnoth.get_variable("cc_scenario") == true then
		return
	end
	
	-- disable era if human sides > 1
	local humans = 0
	local sides = wesnoth.get_sides()
	for i,v in ipairs(sides) do
		if v.controller == "human" then
			humans = humans + 1
		end
	end
	if humans > 1 then
		wml_actions.message({ speaker="narrator", message=_"You must have no more that one human controlled side to play Custom Campagin." })
		return cc.endlevel()	
	elseif humans == 0 then
		-- player is just watching computer play itself
	end
	sides = nil
	
	-- disable era if player hasn't made any armies
	cc.load_globals()
	if next(army) == nil then
		wml_actions.message({ speaker="narrator", message=_"You need at least one army to play. Create it at the Custom Campaign Map." })
		return cc.endlevel()
	end
		
	-- Show faction menu for each computer side,
	-- army menu for player side, and skip null sides
	-- check based on side.controller
	local sides = wesnoth.get_sides({ {"has_unit", { type="Custom Campaign Unit" }} })
	wml_actions.kill({ type="Custom Campaign Unit", animate="no", fire_event="no" })
	for i,v in ipairs(sides) do
		if v.controller == "human" then
			-- give choice between army or faction
			local choice = cc.get_user_choice({ speaker="narrator", message=_"Would you like to play an Army (saved on victory) or a Faction (not saved) for side " .. v.side .."?" }, { _"Army", _"Faction" })
			if choice == 1 then
				local list = cc.army_display_list()
				local index = cc.get_user_choice({ speaker="narrator", message=_"Select your army for side " .. v.side }, list)
				cc.unpack_entry(army[index], v.side)
				
				-- make copy to place into wml_var
				local chosen_army = cc.deep_copy(army[index])
				chosen_army.side = v.side
				-- clear troop list
				for i = 1, #chosen_army do
					chosen_army[i] = nil
				end
				-- place into wml_var so it can be saved and used in victory event
				wesnoth.set_variable("cc_chosen_army", chosen_army)
				
				-- set objectives
				local objectives = { side=v.side }
				local c = 1
				objectives[c] = { "objective", { condition="win", description=_"Defeat enemy leader(s)" } }
				c = c + 1
				for u in helper.child_range(army[index], "troop_list") do
					if u.id == "Main Leader" and u.role == "Leader" then
						objectives[c] = { "objective", { condition="lose", description=_"Death of " .. u.name } }
						c = c + 1
					end
				end
				for u in helper.child_range(army[index], "troop_list") do
					if u.role == "Leader" and u.id ~= "Main Leader" then
						objectives[c] = { "objective", { condition="lose", description=_"Death of " .. u.name } }
						c = c + 1
					end
				end
				if c == 2 then -- All leaders are expendable, therefore use this objective
					objectives[c] = { "objective", { condition="lose", description=_"Death of your leader(s)" } }
					c = c + 1
				end
				for u in helper.child_range(army[index], "troop_list") do
					if  u.role == "Hero" then
						objectives[c] = { "objective", { condition="lose", description=_"Death of " .. u.name } }
						c = c + 1
					end
				end
				objectives[c] = { "objective", { condition="lose", show_turn_counter="yes", description=_"Turns runs out (if applicable)" } }
				wml_actions.objectives(objectives)
			elseif choice == 2 then
				local list = cc.faction_display_list()
				local index = cc.get_user_choice({ speaker="narrator", message=_"Choose your faction for side " .. v.side }, list)
				cc.unpack_entry(faction[index], v.side)
			end
		elseif v.controller == "ai" then
			local list = cc.faction_display_list()
			local index = cc.get_user_choice({ speaker="narrator", message=_"Choose a faction for side " .. v.side .. " (" .. v.gold .. " Gold, " .. v.base_income .. " Income)" }, list)
			cc.unpack_entry(faction[index], v.side)
		end
	end

	-- clear global vars in lua
	army, faction, id = nil, nil, nil
end

------------------ ERA VICTORY --------------------

function cc.era_victory()
	-- retrieve the chosen_army wml_var
	local chosen_army = wesnoth.get_variable("cc_chosen_army")
	
	if chosen_army == nil then
		return
	end
			
	-- Take all units and dump their wml into an array
	local units = {}
	for i,u in ipairs(wesnoth.get_recall_units({ side=chosen_army.side })) do
		table.insert(units, u.__cfg)
	end
	for i,u in ipairs(wesnoth.get_units({ side=chosen_army.side })) do
		table.insert(units, u.__cfg)
	end
	
	-- Heal, Clear Status, Reset attacks and move, set side to 1
	-- This (hopefully) replicates everything that is done to restore a unit
	-- upon victory. Must do it this way, as storing units occurs before
	-- the victory restoring of all the players units.
	for u = 1, #units do
		cc.clear_ids(units[u])
		units[u].hitpoints = units[u].max_hitpoints
		units[u].moves = units[u].max_moves
		units[u].attacks_left = units[u].max_attacks
		units[u].goto_x = 0; units[u].goto_y = 0
		units[u].side = 1
		for tag = #units[u], 1, -1 do
			-- do it this way so it'll get recreated when it is unpacked again,
			-- thus handling any custom status from add-ons
			if units[u][tag][1] == "status" then
				table.remove(units[u], tag)
			end
		end
	end
	
	chosen_army.side = nil

	-- add the unit list to the chosen_army table
	for u = 1, #units do
		chosen_army[u] = { "troop_list", units[u] }
	end

	chosen_army.victories = chosen_army.victories + 1
	chosen_army.last_victory = os.date()
	
	cc.load_globals()
	local index
	-- Find the proper index from the unique id
	for i, v in ipairs(army) do
		if v.id == chosen_army.id then
			index = i; break
		end
	end
	-- if index is still nil, that means player is necroing a deleted army,
	-- so add it at the end of the army array
	if index then
		army[index] = chosen_army
	else
		table.insert(army, chosen_army)
	end
	table.sort(army, cc.name_sort)
	cc.save_globals()
end

----------------- ERA DIE -------------------

function cc.era_die()
	-- disable era functionality if launched with Custom Campaign Map
	if wesnoth.get_variable("cc_scenario") == true then
		return
	end
	-- 1. Check if a Leader or Hero has died. If so, end the level in defeat.
	   -- a. Filter for role="Leader,Hero"
	   -- b. End the level.
	local u = wesnoth.get_variable("unit")
	if u.role == "Leader" or u.role == "Hero" then
		wml_actions.endlevel({ result="defeat" })
	end
	-- 2. If an Expendable Leader that is the Main Leader has died, try to reassign Main Leader status to
	   -- first to another Expendable Leader, second to a Leader. (just get the first one that matches the filter
	   -- in either case, and give that one id="Main Leader".) Assume that since the player made the
	   -- Main Leader an Expendable one, he'd like to reassign Main Leader status to another Expendable Leader if possible.
	   -- a. check if id="Main Leader" and role="Expendable Leader"
	   -- b. Filter for role="Expendable Leader" then for role="Leader"
	if u.id == "Main Leader" and u.role == "Expendable Leader" then
		local leaders = wesnoth.get_units({ side=u.side, canrecruit=true, { "not", { id="Main Leader" }} })
		if next(leaders) then
			table.sort(leaders, function (u1,u2) return (u1.role < u2.role) end)
			local new_main = leaders[1].__cfg
			new_main.id = "Main Leader"
			wesnoth.extract_unit(leaders[1])
			wesnoth.put_unit(new_main)
		end
	end
end

----------------- ERA START ------------------

function cc.era_start()
	-- disable era functionality if launched with Custom Campaign Map
	if wesnoth.get_variable("cc_scenario") == true then
		return
	end
	wml_actions.message({ id="Main Leader", message=_"To arms!" })
end

----------------- ERA ENEMIES DEFEATED -------

function cc.era_enemies_defeated()
	-- disable era functionality if launched with Custom Campaign Map
	if wesnoth.get_variable("cc_scenario") == true then
		return
	end
	wml_actions.message({ id="Main Leader", message=_"Victory!" })
end

----------------- MAIN MENU -----------------

function cc.main_menu()
	local answer = cc.get_user_choice({ speaker="narrator", message=_"Custom Campaign - Main Menu" },
		{ _"Army List", _"Faction List", _"Side List", _"Instructions", _"Revert to Save",
		  _"Save and Quit", _"Quit, No Save" })

	if     answer == 1 then return cc.army_list()
	elseif answer == 2 then return cc.faction_list()
	elseif answer == 3 then return cc.side_list()
	elseif answer == 4 then return cc.instructions()
	elseif answer == 5 then return cc.revert_to_save()
	elseif answer == 6 then return cc.save_and_quit()
	elseif answer == 7 then return cc.quit_no_save()
	end
end

---------------- MENU FIRST LEVEL ------------------

-- allows the player to do things with the army list
function cc.army_list()
	table.sort(army, cc.name_sort)

	local choices = cc.army_display_list()
	choices[-1] = cc.back_button()
	choices[0] = cc.add_button()
	
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select a command or an Army to work with." }, choices, -1 )
	
	if     index == -1 then return cc.main_menu()
	elseif index ==  0 then return cc.add_army()
	elseif index >=  1 then return cc.army_options(index)
	end
end

function cc.faction_list()
	table.sort(faction, cc.name_sort)
	
	local choices = cc.faction_display_list()
	choices[-1] = cc.back_button()
	choices[0] = cc.add_button()
	
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select a command or a Faction to work with." }, choices, -1 )
	
	if     index == -1 then return cc.main_menu()
	elseif index ==  0 then return cc.add_faction()
	elseif index >=  1 then return cc.faction_options(index)
	end
end

function cc.side_list()
	local choices = cc.side_display_list()
	choices[0] = cc.back_button()
	
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select a Side to view." }, choices ,0)
	
	if     index == 0 then return cc.main_menu()
	elseif index >= 1 then return cc.view_entry(side[index], "side", index)
	end
end

function cc.instructions()
	wml_actions.message({ speaker="narrator", message=_"This menu lets you manage all aspects of creating persistent armies and factions." ..
	"\n	\n" ..
	"\n" .. _"Important note!" ..
	"\n" .. _"When you create an army, the Leader's required XP to level up is altered by whatever the experience modifier was when you launched this map. " ..
	_"Any units you recruit during a scenario will have their experience modifier set to whatever it was when the scenario was launched. " ..
	_"Changing the experience modifier between scenarios could result in odd things happening, such as units with identical types and traits requiring different XP to level. Be aware." ..
    "\n	\n" .. _"If you have an Army or Faction with units from an add-on, and you delete the add-on (or if the unit_types otherwise become invalid) the entries will show the unknown-unit icon and list '----------' as appropriate." ..
    "\n	\n" .. _"For quicker MP style play, leave the experience modifier at 70% and Village Gold at 2." ..
	"\n" .. _"For campaign style play, set experience modifier to 100% and Village Gold to 1." ..
    "\n	\n" .. _"Any changes to the Army or Faction Lists are only made permanent and saved to the file when you chose 'Save Changes and Quit'." ..
	"\n	\n" .. _"Please visit http://forums.wesnoth.org/ and leave any feedback or bug reports in the Custom Campaign thread in the Scenario and Campaign Development forum." ..
    "\n	\n" .. _"Terms:" ..
	"\n" .. _"Side - The faction and leader set for a player in the Game Lobby, before launching this map." ..
    "\n" .. _"Faction - A leader,recruit list, and recruitment pattern stored in the Faction List." ..
    "\n" .. _"Army - A leader, recall list, recruit list, and recruitment pattern stored in the Army List." })

	return cc.main_menu()
end

function cc.revert_to_save()
	cc.load_globals()
	return cc.main_menu()
end

function cc.save_and_quit()
	cc.save_globals()
	return cc.endlevel()
end

function cc.quit_no_save()
	return cc.endlevel()
end

------------------------------ MENU SECOND LEVEL ------------------------------

function cc.add_army()
	-- loop allows disabling of some commands if the corresponding array is empty
	while true do
		local answer = cc.get_user_choice({ speaker="narrator", message=_"How would you like to add a new Army?" },
			{ cc.back_button(), _"Custom", _"From Side", _"From Faction", _"Copy Army" })
		if     answer == 1 then return cc.army_list()
		elseif answer == 2 then return cc.create_custom_army()
		elseif answer == 3 and next(side) then return cc.create_army_from_entry(side)
		elseif answer == 4 and next(faction) then return cc.create_army_from_entry(faction)
		elseif answer == 5 and next(army) then return cc.copy_army()
		end
	end
end

function cc.add_faction()
	-- loop allows disabling of some commands if the corresponding array is empty
	while true do
		local answer = cc.get_user_choice({ speaker="narrator", message=_"How would you like to add a new Faction?" },
			{ cc.back_button(), _"Custom", _"From Side", _"From Army", _"Copy Faction" })
		if     answer == 1 then return cc.faction_list()
		elseif answer == 2 then return cc.create_custom_faction()
		elseif answer == 3 and next(side) then return cc.create_faction_from_side()
		elseif answer == 4 and next(army) then return cc.create_faction_from_army()
		elseif answer == 5 and next(faction) then return cc.copy_faction()
		end
	end
end

function cc.army_options(index)
	-- Displays the selected army with options for editing it.
	-- index is the location of the choosen army in the army array
	local msg = cc.army_display_list()
	local answer = 0
	repeat
		answer = cc.get_user_choice({ speaker="narrator", message="" },
			{ [0]=msg[index], cc.back_button(), _"View Army", _"Rename Army", _"Change Main Leader", _"Edit Troops",
			_"Edit Starting Recall", _"Edit Recruit", _"Edit Recruitment Pattern", _"Edit Leader Recruit & Recall", _"Information", _"Delete Army" }, 0)
	until  answer ~= 0
	if     answer == 1 then return cc.army_list()
	elseif answer == 2 then return cc.view_entry(army[index], "army", index)
	elseif answer == 3 then return cc.rename_entry("edit_army", index, army[index])
	elseif answer == 4 then return cc.change_main_leader(index)
	elseif answer == 5 then return cc.edit_troops(index)
	elseif answer == 6 then return cc.edit_starting_recall(index)
	elseif answer == 7 then return cc.edit_recruit("edit_army", index, army[index])
	elseif answer == 8 then return cc.edit_recruitment_pattern("edit_army", index, army[index])
	elseif answer == 9 then return cc.edit_leader_recruit("unused_param", index, army[index])
	elseif answer == 10 then return cc.army_info(index)
	elseif answer == 11 then return cc.delete_entry("edit_army", index)
	end
end

function cc.faction_options(index)
	-- Displays the selected faction with options for editing it.
	-- index is the location of the choosen faction in the faction arra
	local msg = cc.faction_display_list()
	local answer = 0
	repeat
		answer = cc.get_user_choice({ speaker="narrator", message="" },
			{ [0]=msg[index], cc.back_button(), _"View Faction", _"Rename Faction", _"Change Leader",
			_"Edit Recruit", _"Edit Recruitment Pattern", _"Delete Faction" }, 0)
	until  answer ~= 0
	if     answer == 1 then return cc.faction_list()
	elseif answer == 2 then return cc.view_entry(faction[index], "faction", index)
	elseif answer == 3 then return cc.rename_entry("edit_faction", index, faction[index])
	elseif answer == 4 then return cc.edit_leader("edit_faction", index)
	elseif answer == 5 then return cc.edit_recruit("edit_faction", index, faction[index])
	elseif answer == 6 then return cc.edit_recruitment_pattern("edit_faction", index, faction[index])
	elseif answer == 7 then return cc.delete_entry("edit_faction", index)
	end
end

----------------------------- MENU THIRD LEVEL -- ADD NEW ENTRY --------------------------------

function cc.create_custom_army()
	id_counter = id_counter + 1
	custom = { id = id_counter, name = "", recruit = "", recruitment_pattern = "", starting_recall = 0, victories = 0, last_victory = ""}
	-- launch a chain of functions: edit_leader(), edit_recruit(), edit_recruitment_pattern(), rename_entry()
	return cc.edit_leader("custom_army")
end

function cc.create_army_from_entry(t)
	-- probably is a better way to determine what was sent
	local list = ""
	if t[1].name ~= nil then
		list = cc.faction_display_list()
	else
		list = cc.side_display_list()
	end
	local choice = cc.get_user_choice({ speaker = "narrator", message = _"Select an entry to make an Army from:" },
		list )
	
	local temp_name = t[choice].name
	local new = {}
	
	local u = wesnoth.create_unit({ type=t[choice].leader, gender=t[choice].gender })
	u = cc.customize_unit(u, true)
	
	-- put unit in [recall_list]
	new[1] = { "troop_list", u.__cfg }
	
	new.name = cc.get_text_input({ speaker = "narrator", message = _"Enter a name for your Army:" }, { text = temp_name })
	
	id_counter = id_counter + 1
	new.id = id_counter
	new.recruit = t[choice].recruit or ""
	new.recruitment_pattern = t[choice].recruitment_pattern or ""
	new.starting_recall = 0
	new.victories = 0
	new.last_victory = ""
	
	table.insert(army, new)
	table.sort(army, cc.name_sort)
	return cc.army_list()
end

function cc.copy_army()
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to copy" },
		cc.army_display_list() )
	local new_army = cc.deep_copy(army[index])
	id_counter = id_counter + 1
	new_army.id = id_counter
	table.insert(army, new_army)
	table.sort(army, cc.name_sort)
	return cc.army_list()
end

function cc.create_custom_faction()
	custom = { gender = "", image = "", leader = "", name = "", recruit = "", recruitment_pattern = "" }
	-- launch a chain of functions: edit_leader(), edit_recruit(), edit_recruitment_pattern(), rename_entry()
	return cc.edit_leader("custom_faction")
end

function cc.create_faction_from_side()
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use" },
		cc.side_display_list() )
	local new_faction = cc.deep_copy(side[index])
	new_faction.name = cc.get_text_input({ speaker = "narrator", message = _"Enter a name for your Faction:" })
	table.insert(faction, new_faction)
	table.sort(faction, cc.name_sort)
	return cc.faction_list()
end

function cc.create_faction_from_army()
	-- need to scan army for leader and extract attributes
	-- then, just copy name, recruit, & recruitment_pattern
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use" },
		cc.army_display_list() )
	local new_faction = {}
	
	for rl in helper.child_range(army[index], "troop_list") do
		if rl.canrecruit == true then
			new_faction.leader = rl.type
			new_faction.image = rl.image
			new_faction.gender = rl.gender
			break
		end
	end
	new_faction.recruit = army[index].recruit
	new_faction.recruitment_pattern = army[index].recruitment_pattern
	new_faction.name = cc.get_text_input({ speaker="narrator", message=_"Enter a name for your Faction:" })
	table.insert(faction, new_faction)
	table.sort(faction, cc.name_sort)
	return cc.faction_list()
end

function cc.copy_faction()
	local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to copy" },
		cc.faction_display_list() )
	local new_faction = cc.deep_copy(faction[index])
	table.insert(faction, new_faction)
	table.sort(faction, cc.name_sort)
	return cc.faction_list()
end

-------------------------- MENU THRID LEVEL -- OPTIONS ------------------------

------------ VIEW ----------------------------

function cc.view_entry(entry, caller, index)
	-- right-click back returns to caller
	wml_actions.set_menu_item({ id=1, description=_"Back",
		{ "show_if", { } }, -- empty is true
		{ "command", { { "lua", { code='cc.view_entry_end("' .. caller .. '", ' .. index .. ')' } } } } })
	
	-- prerecruit event - prevent recruit and gold change
	wml_actions.event({ name="prerecruit", id="recruit", first_time_only="no",
		{ "lua", { code = [[ local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
							 local u = wesnoth.get_unit(x,y)
							 wesnoth.extract_unit(u)
							 wml_actions.gold({ side=1, amount=u.__cfg.cost }) ]] } } })
	-- prerecall event - prevent recall and gold change
	wml_actions.event({ name="prerecall", id="recall", first_time_only="no",
		{ "lua", { code = [[ local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
							 wesnoth.put_recall_unit(wesnoth.get_unit(x,y))
							 wml_actions.gold({ side="1", amount=wesnoth.game_config.recall_cost }) ]] } } })
	
	-- unpack army, faction, or side
	return cc.unpack_entry(entry, 1, "Leader")
end

function cc.view_entry_end(caller, index)
	wml_actions.kill({ animate="no", fire_event="no" })
	cc.clear_menu_items()
	wml_actions.event({ id="recruit", remove=true })
	wml_actions.event({ id="recall", remove=true })
	
	if     caller == "army" then
		return cc.army_options(index)
	elseif caller == "faction" then
		return cc.faction_options(index)
	elseif caller == "side" then
		return cc.side_list()
	end
end

--------------- RENAME ---------------------------

function cc.rename_entry(caller, index, entry)
	local result = cc.get_text_input({ speaker="narrator", message=_"Enter a name for this entry." },
		{ text=entry.name })
	entry.name = result
	if     caller == "edit_army" then
		return cc.army_options(index)
	elseif caller == "edit_faction" then
		return cc.faction_options(index)
	elseif caller == "custom_army" then
		table.insert(army, entry)
		table.sort(army, cc.name_sort)
		return cc.army_list()
	elseif caller == "custom_faction" then
		table.insert(faction, entry)
		table.sort(faction, cc.name_sort)
		return cc.faction_list()
	end
end

--------------- EDIT LEADER -----------------

function cc.edit_leader(caller, index)
	index = index or 0
	-- create right-clicks
	wml_actions.set_menu_item({ id=1, description=_"Back",
		{ "show_if", { } },
		{ "command", { { "lua", { code = "cc.edit_leader_cancel('" .. caller .. "', " .. index .. ")" } } } } })
	wml_actions.set_menu_item({ id=2, description=_"Leader Instructions",
		{ "show_if", { } },
		{ "command", { { "message", { speaker="narrator", message=_"Use the Recruit command to 'Recruit' a leader. Use the Unit Filters to adjust what appears on the Recruit list."  } } } } })
	wml_actions.set_menu_item({ id=3, description=_"Unit Filters",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.unit_filters()" } } } } })
		
	-- create recruit event
	wml_actions.event({ name="prerecruit", id="recruit", first_time_only="no",
		{ "lua", { code = "cc.edit_leader_end('" .. caller .. "', " .. index .. ")" } } })
		
	-- initilize recruit list to contain all possible units
	local unit_types = cc.get_unit_type_ids()
	local unit_list = table.concat(unit_types, ",")
	wml_actions.set_recruit({ side=1, recruit=unit_list })
	
	cc.reset_unit_filters()
	
	-- make placeholder leader
	local loc = wesnoth.get_starting_location(1)
	wesnoth.put_unit(loc[1], loc[2], { type="Custom Campaign Unit", canrecruit=true,  facing="se" })
end

function cc.edit_leader_cancel(caller, index)
	-- cleanup
	cc.clear_menu_items()
	wml_actions.event({ id="recruit", remove=true })
	wml_actions.kill({ animate="no", fire_event="no" })
	
	-- end
	if     caller == "edit_army" then
		return cc.army_options(index)
	elseif caller == "edit_faction" then
		return cc.faction_options(index)
	elseif caller == "custom_army" then
		return cc.add_army()
	elseif caller == "custom_faction" then
		return cc.add_faction()
	end
end

function cc.edit_leader_end(caller, index)
	local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
	local u = wesnoth.get_unit(x,y)
	wesnoth.extract_unit(u)
	wml_actions.gold({ side=1, amount=u.__cfg.cost })
	
	local n = ""
	if caller == "edit_army" or caller == "custom_army" then
		u = cc.customize_unit(u, true)		
	else
		g = cc.get_gender_choice(u.type)
		u = wesnoth.create_unit({ type=u.type, gender=g })
	end
	
	if caller == "edit_army" then
		for u = 1, #army[index] do
			if army[index][u][2].id == "Main Leader" then
				army[index][u][2] = u.__cfg
				break
			end
		end
	elseif caller == "edit_faction" then
		-- replace current leader with new one
		faction[index].leader = u.type
		faction[index].gender = u.__cfg.gender
		faction[index].image = u.__cfg.image
	elseif caller == "custom_army" then
		-- add to custom_entry
		custom[1] = { "troop_list", u.__cfg }
	elseif caller == "custom_faction" then
		-- add to custom_entry
		custom.leader = u.type
		custom.gender = u.__cfg.gender
		custom.image = u.__cfg.image
	end
	
	-- cleanup
	cc.clear_menu_items()
	wml_actions.event({ id="recruit", remove=true })
	wml_actions.kill({ animate="no", fire_event="no" })
	
	-- end
	if     caller == "edit_army" then
		return cc.army_options(index)
	elseif caller == "edit_faction" then
		return cc.faction_options(index)
	elseif caller == "custom_army" or "custom_faction" then
		return cc.edit_recruit(caller, index, custom)
	end
end

------------------- EDIT RECRUIT -------------------

function cc.edit_recruit_event_recruit()
	local x1, y1 = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
	local u = wesnoth.get_unit(x1, y1)
	wesnoth.extract_unit(u)
	u = wesnoth.create_unit({ type=u.type, generate_name="no", random_gender="no", random_traits="no" })
	wml_actions.gold({ side=1, amount=u.__cfg.cost })

	--check if unit is already on recall list
	local list = wesnoth.get_recall_units({ side=1 })
	local unit_already_chosen = false
	for i,v in ipairs(list) do
		if v.type == u.type then
			unit_already_chosen = true
			break
		end
	end
	if unit_already_chosen == false then	
		wesnoth.put_recall_unit(u)
	end
end

function cc.edit_recruit(caller, index, entry)
	wml_actions.set_menu_item({ id=1, description=_"End Edit Recruit",
		{ "show_if", { } },
		{ "command", { { "lua", { code = "cc.edit_recruit_end('" .. caller .. "', " .. index .. ")" } } } } })
	wml_actions.set_menu_item({ id=2, description=_"Edit Recruit Instructions",
		{ "show_if", { } },
		{ "command", { { "message", { speaker="narrator", message=_"Use the Recruit command to select units for the Recruit list. Selected units will appear on the Recall list. Use Dismiss unit to remove a unit. Use the Unit Filters to adjust what appears on the Recruit list."  } } } } })
	wml_actions.set_menu_item({ id=3, description=_"Unit Filters",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.unit_filters()" } } } } })
	wml_actions.set_menu_item({ id=4, description=_"Add Recruits From Entry",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.edit_recruit_add_from_entry()" } } } } })
	wml_actions.set_menu_item({ id=5, description=_"Clear Selected Recruits",
		{ "show_if", { } },
		{ "command", { { "lua", { code=[[wml_actions.kill({ x="recall", y="recall" }) ]] } } } } })
	
	-- prerecruit event - prevent recruit and gold change, put recruit on recall
	wml_actions.event({ name="prerecruit", id="recruit", first_time_only="no",
		{ "lua", { code = "cc.edit_recruit_event_recruit()" } } })
	-- prerecall event - prevent recall and gold change
	wml_actions.event({ name="prerecall", id="recall", first_time_only="no",
		{ "lua", { code = [[
							local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
							wesnoth.put_recall_unit(wesnoth.get_unit(x,y))
							wml_actions.gold({ side="1", amount=wesnoth.game_config.recall_cost })
						  ]] } } })
		
	-- initilize recruit list to contain all possible units
	local unit_types = cc.get_unit_type_ids()
	local unit_list = table.concat(unit_types, ",")
	wml_actions.set_recruit({ side=1, recruit=unit_list })
	
	cc.reset_unit_filters()
	
	-- unpack leader to keep
	local loc = wesnoth.get_starting_location(1)
	if entry.leader ~= nil then
		-- faction leader - check for missing unit
		if wesnoth.unit_types[entry.leader] ~= nil then
			wesnoth.put_unit(loc[1], loc[2], { type=entry.leader, gender=entry.gender, canrecruit=true })
		else
			wesnoth.put_unit(loc[1], loc[2], { type="Custom Campaign Unit", canrecruit=true, facing="se" })
		end
	else
		-- army leader - check for missing unit as well
		local u = helper.get_child(entry, "troop_list", "Main Leader")
		if wesnoth.unit_types[u.type] then
			wesnoth.put_unit(loc[1], loc[2], u)
		else
			wesnoth.put_unit(loc[1], loc[2], { type="Custom Campaign Unit", canrecruit=true, facing="se" })
		end
	end
	
	if entry.recruit ~= "" then
		-- unpack recruit list to recall list
		local recruits = cc.split(entry.recruit, ",")
		
		for i,v in ipairs(recruits) do
			-- ---------- check, if false do not add
			if wesnoth.unit_types[v] then
				local u = wesnoth.create_unit({ type=v, generate_name="no", random_gender="no", random_traits="no" })
				wesnoth.put_recall_unit(u)
			end
		end
	end
end

function cc.edit_recruit_add_from_entry()
	local choice, recruit, recruit_list
	repeat
		choice = cc.get_user_choice({ speaker="narrator", message=_"Select a list to pick an entry from:"}, { [0]=cc.back_button(), _"Army", _"Faction", _"Side" }, 0)
		if     choice == 1 and next(army) then
			local list = cc.army_display_list()
			local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
			recruit = army[index].recruit
		elseif choice == 2 and next(faction) then
			local list = cc.faction_display_list()
			local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
			recruit = faction[index].recruit
		elseif choice == 3 and next(side) then
			local list = cc.side_display_list()
			local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
			recruit = side[index].recruit
		end
	until recruit or choice == 0
	-- unpack recruit to the recall list
	if recruit then
		recruit_list = cc.split(recruit, ",")
		for j = 1, #recruit_list do
			--check if unit is already on recall list
			local list = wesnoth.get_recall_units({ side=1 })
			local unit_already_chosen = false
			for i,v in ipairs(list) do
				if v.type == recruit_list[j] then
					unit_already_chosen = true
					break
				end
			end
			if unit_already_chosen == false then
				-- ---------- check, if false do not add
				if wesnoth.unit_types[recruit_list[j]] then
					local u = wesnoth.create_unit({ type=recruit_list[j], generate_name="no", random_gender="no", random_traits="no" })
					wesnoth.put_recall_unit(u)
				end
			end
		end
	end
end

function cc.edit_recruit_end(caller, index)
	local choice = cc.get_user_choice({ speaker="narrator", message=_"Choose option:"},
		{ _"End and accept edits", _"End and discard edits", _"Continue editing" })
	
	if choice == 1 then
		-- take recall list and make a recruit list
		local units = wesnoth.get_recall_units({ side=1 })
		local list = {}
		for i,v in ipairs(units) do
			list[i] = v.type
		end
		table.sort(list)
		local recruit = table.concat(list, ",")

		-- cleanup
		cc.clear_menu_items()
		wml_actions.event({ id="recruit", remove=true })
		wml_actions.event({ id="recall", remove=true })
		wml_actions.kill({ animate="no", fire_event="no" })
		
		-- end
		if     caller == "edit_army" then
			army[index].recruit = recruit
			return cc.army_options(index)
		elseif caller == "edit_faction" then
			faction[index].recruit = recruit
			return cc.faction_options(index)
		elseif caller == "custom_army" or caller == "custom_faction" then
			custom.recruit = recruit
			return cc.edit_recruitment_pattern(caller, index, custom)
		end
	elseif choice == 2 then
		-- cleanup
		cc.clear_menu_items()
		wml_actions.event({ id="recruit", remove=true })
		wml_actions.event({ id="recall", remove=true })
		wml_actions.kill({ animate="no", fire_event="no" })
		
		-- end
		if     caller == "edit_army"      then return cc.army_options(index)
		elseif caller == "edit_faction"   then return cc.faction_options(index)
		elseif caller == "custom_army"    then return cc.add_army()
		elseif caller == "custom_faction" then return cc.add_faction()
		end
	elseif choice == 3 then
		-- Fall out of function back to player control
	end
end

----------------- EDIT LEADER RECRUIT ----------------------------

function cc.edit_leader_recruit(caller, index, entry)
	-- first, let the player choose which leader's recruit to edit
	local options = cc.leader_display_list(index); options[0] = cc.back_button()
	local leader_index = cc.get_user_choice({ speaker="narrator", message=_"Select a leader to edit their extra recruit list." }, options, 0)
	if leader_index == 0 then
		return cc.army_options(index)
	end

	wml_actions.set_menu_item({ id=1, description=_"End Edit Leader Recruit",
		{ "show_if", { } },
		{ "command", { { "lua", { code = "cc.edit_leader_recruit_end(" .. leader_index .. ", " .. index .. ")" } } } } })
	wml_actions.set_menu_item({ id=2, description=_"Edit Leader Recruit Instructions",
		{ "show_if", { } },
		{ "command", { { "message", { speaker="narrator", message=_"Use the Recruit command to select units for the Leader Recruit list. Selected units will appear on the Recall list. Use Dismiss unit to remove a unit. Use the Unit Filters to adjust what appears on the Recruit list."  } } } } })
	wml_actions.set_menu_item({ id=3, description=_"Unit Filters",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.unit_filters()" } } } } })
	wml_actions.set_menu_item({ id=4, description=_"Add Recruits From Entry",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.edit_recruit_add_from_entry()" } } } } })
	wml_actions.set_menu_item({ id=5, description=_"Clear Selected Recruits",
		{ "show_if", { } },
		{ "command", { { "lua", { code=[[wml_actions.kill({ x="recall", y="recall" }) ]] } } } } })
	
	-- prerecruit event - prevent recruit and gold change, put recruit on recall
	wml_actions.event({ name="prerecruit", id="recruit", first_time_only="no",
		{ "lua", { code = "cc.edit_recruit_event_recruit()" } } })
	-- prerecall event - prevent recall and gold change
	wml_actions.event({ name="prerecall", id="recall", first_time_only="no",
		{ "lua", { code = [[
							local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
							wesnoth.put_recall_unit(wesnoth.get_unit(x,y))
							wml_actions.gold({ side="1", amount=wesnoth.game_config.recall_cost })
						  ]] } } })
		
	-- initilize recruit list to contain all possible units
	local unit_types = cc.get_unit_type_ids()
	local unit_list = table.concat(unit_types, ",")
	wml_actions.set_recruit({ side=1, recruit=unit_list })
	
	cc.reset_unit_filters()
	
	-- unpack leader to keep
	local loc = wesnoth.get_starting_location(1)

	-- unpack selected leader - check for missing unit as well
	local u = army[index][leader_index][2]
	-- clear filter recall
	for i = 1, #u do
		if u[i][1] == "filter_recall" then
			u[i][2] = {}
		end
	end
	if wesnoth.unit_types[u.type] then
		wesnoth.put_unit(loc[1], loc[2], u)
	else
		wesnoth.put_unit(loc[1], loc[2], { type="Custom Campaign Unit", canrecruit=true, facing="se" })
	end
	
	-- get proxy for leader put on map
	u = wesnoth.get_unit(loc[1], loc[2])
	
	if next(u.extra_recruit) then -- ~= "" then
		-- unpack recruit list to recall list
		-- local recruits = cc.split(u.extra_recruit, ",")
		local recruits = u.extra_recruit
		
		for i,v in ipairs(recruits) do
			-- ---------- check, if false do not add
			if wesnoth.unit_types[v] then
				local u = wesnoth.create_unit({ type=v, generate_name="no", random_gender="no", random_traits="no" })
				wesnoth.put_recall_unit(u)
			end
		end
		-- clear extra_recruit from leader on map so it doesn't clutter the recruit list
		u.extra_recruit = {}
	end
end

function cc.edit_leader_recruit_end(leader_index, index)
	local choice = cc.get_user_choice({ speaker="narrator", message=_"Choose option:"},
		{ _"End and accept edits", _"End and discard edits", _"Continue editing" })
	
	if choice == 1 then
		-- take recall list and make a recruit list
		local units = wesnoth.get_recall_units({ side=1 })
		local list = {}
		for i,v in ipairs(units) do
			list[i] = v.type
		end
		table.sort(list)
		local recruit = table.concat(list, ",")

		-- cleanup
		cc.clear_menu_items()
		wml_actions.event({ id="recruit", remove=true })
		wml_actions.event({ id="recall", remove=true })
		wml_actions.kill({ animate="no", fire_event="no" })
		
		-- end
		army[index][leader_index][2].extra_recruit = recruit
		cc.edit_leader_filter_recall(leader_index, index, recruit)
		return cc.army_options(index)
	elseif choice == 2 then
		-- cleanup
		cc.clear_menu_items()
		wml_actions.event({ id="recruit", remove=true })
		wml_actions.event({ id="recall", remove=true })
		wml_actions.kill({ animate="no", fire_event="no" })
		
		-- end
		return cc.army_options(index)
	elseif choice == 3 then
		-- Fall out of function back to player control
	end
end

function cc.edit_leader_filter_recall(leader_index, index, recruit)
	local filter_recall = {}
	
	local choice = cc.get_user_choice({ speaker="narrator", message=_"What units would you like this leader to be able to recall?" },
		{ _"Based on leader recruit", _"Selected races", _"All units" })
	if     choice == 1 then
		-- Scan each recruit for advaces_to key and add any not present in the recruit list
		-- to the end of the list
		if recruit ~= "" then
			units = cc.split(recruit, ",")
			local u = 1
			while units[u] do
				if wesnoth.unit_types[units[u]].__cfg.advances_to ~= "null" and wesnoth.unit_types[units[u]].__cfg.advances_to then
					local advances = cc.split(wesnoth.unit_types[units[u]].__cfg.advances_to, ",")
					local a = 1
					while advances[a] do
						local is_present = false
						for i = 1, #units do
							if advances[a] == units[i] then
								is_present = true; break
							end
						end
						if is_present == false then
							table.insert(units, advances[a])
						end
						a = a + 1
					end
				end
				u = u + 1
			end
		end
		table.sort(units)
		local recallable_units = table.concat(units, ",")
		filter_recall = { type = recallable_units }
	elseif choice == 2 then
		-- present a list of races to the player
		local race_list = cc.find_races()
		local race_display = { [0] = cc.end_button() }
		for i,v in ipairs(race_list) do
			race_display[i] = v.name .. "=" .. "(id: " .. v.id .. ")"
		end
		local c = 0; local choices = {}
		repeat
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Select a race that you would like this leader to be able to recall." }, race_display, 0)
			if answer ~= 0 then
				c = c + 1
				choices[c] = race_list[answer].id
				table.remove(race_list, answer)
				table.remove(race_display, answer)
			end
		until answer == 0
		if next(choices) then
			-- toplevel race= has full list for conveniet translation
			-- each element is in an "or" subtag
			-- this is a workaround because SUF race doesn't take a comma seperated list.
			table.sort(choices)
			local races = table.concat(choices, ",")
			filter_recall = { race = races }
			for i = 1, #choices do
				filter_recall[i] = { "or", { race = choices[i] }}
			end
		end
	elseif choice == 3 then
		filter_recall = {}
	end
	
	for i = 1, #army[index][leader_index][2] do
		if army[index][leader_index][2][i][1] == "filter_recall" then
			army[index][leader_index][2][i][2] = filter_recall
		end
	end
end

---------------------- EDIT RECRUITMENT PATTERN -----------------

function cc.edit_recruitment_pattern(caller, index, entry)
	-- this is horrible sloppy, needs rewritten
	local recruit = cc.remove_missing_recruits(entry.recruit)
	local crp
	if recruit ~= nil and recruit ~= "" then
		
		local recruit_list = cc.split(recruit, ",")
		local list = cc.find_usage(recruit)
		local rpl = {}
		-- Start of alternative way of listing units with usage, kinda complex, so I'm lazy about doing it this way
		-- for each usage, make ie, archer: Banebow,Bone Shooter,Bowman
		-- for i = 1, #list do
			-- make array of all recruits that match current usage
			-- for j = 1, #recruit_list do
				-- if list[i] == wesnoth.unit_types[recruit_list[j]].__cfg.usage then
					-- rpl[i] = rpl[i] .. tostring(wesnoth.unit_types[recruit_list[j]].name) .. ","
				-- end
		for i = 1, #recruit_list do
			rpl[i] = wesnoth.unit_types[recruit_list[i]].__cfg.usage .. " - " .. tostring(wesnoth.unit_types[recruit_list[i]].name) .. "\n"
		end
		table.sort(rpl)
		local rptxt = table.concat(rpl)
		
		list[-3] = cc.end_button()
		list[-2] = cc.back_button()
		list[-1] = _ "Clear Recruitment Pattern"
		list[0] = _ "Copy a Recruitment Pattern"
		local chosen_pattern = {}
		if entry.recruitment_pattern ~= nil and entry.recruitment_pattern ~= "" then
			chosen_pattern = cc.split(entry.recruitment_pattern, ",")
		end
		local rp = nil
		local count = 1
		if next(chosen_pattern) ~= nil then
			count =  #chosen_pattern + 1
		end
		repeat
			if next(chosen_pattern) ~= nil then
				rp = table.concat(chosen_pattern, ",")
			else
				rp = ""
			end
			-- TODO: Convert this to using "" and .. and \n
			local msg = _[[Create the recruitment pattern. This is used to tune AI performance in playing factions. These options are taken from the recruits you have selected. Leave it blank if you don't know what to put, and all will have an equal chance of being picked.
If you do fill this out, make sure to select at least one of each, otherwise units with ommitted patterns won't be recruited by the AI.
Choose an entry more than once to increase that group's chance of being recruited compared to other groups. Choose 'End' when you are done. Here is a list of patterns for each recruit you picked:<span foreground= 'green'>
]] .. rptxt .. [[</span>
    
    You have selected:<span foreground='yellow'>
]] .. rp .. "</span>"
			local choice = cc.get_user_choice({ speaker="narrator", message=msg }, list, -3)
			if    choice == -2 then
				if count > 1 then
					count = count - 1
				end
				chosen_pattern[count] = nil
			elseif choice == -1 then
				count = 1
				rp = nil
				chosen_pattern = {}
			elseif choice == 0 then
				repeat
					local answer = cc.get_user_choice({ speaker="narrator", message=_"Select a list to pick an entry from:"}, { [0]=cc.back_button(), _"Army", _"Faction", _"Side" }, 0)
					if     answer == 1 and next(army) then
						local list = cc.army_display_list()
						local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
						crp = army[index].recruitment_pattern
						chosen_pattern = {}
					elseif answer == 2 and next(faction) then
						local list = cc.faction_display_list()
						local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
						crp = faction[index].recruitment_pattern
						chosen_pattern = {}
					elseif answer == 3 and next(side) then
						local list = cc.side_display_list()
						local index = cc.get_user_choice({ speaker="narrator", message=_"Select an entry to use:" }, list )
						crp = side[index].recruitment_pattern
						chosen_pattern = {}
					end
				until crp or answer == 0
			elseif choice ~= -3 then
				chosen_pattern[count] = list[choice]
				count = count + 1
			end
		until choice == -3 or crp
		if next(chosen_pattern) ~= nil then
			rp = table.concat(chosen_pattern, ",")
		else
			rp = ""
		end
		-- end
		entry.recruitment_pattern = rp
		if crp then
			entry.recruitment_pattern = crp
		end
	else
		entry.recruitment_pattern = ""
	end
	
	if     caller == "edit_army" then
		return cc.army_options(index)
	elseif caller == "edit_faction" then
		return cc.faction_options(index)
	elseif caller == "custom_army" then
		return cc.rename_entry(caller, index, entry)
	elseif caller == "custom_faction" then
		return cc.rename_entry(caller, index, entry)
	end
end

---------------------- EDIT TROOPS ----------------------

function cc.edit_troops(index)
	wml_actions.set_menu_item({ id=1, description=_"End Edit Troops",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.edit_troops_end(" .. index .. ")" } } } } })
	wml_actions.set_menu_item({ id=2, description=_"Edit Troops Instructions",
		{ "show_if", { } },
		{ "command", { { "message", { speaker="narrator", message=_"Use Recruit to add a unit to the Recall list. Dismiss a unit from the Recall list to remove it. Recall a unit to edit things like name. Right-Click a unit on the map, and you can select a command to delete it." } } } } })
	wml_actions.set_menu_item({ id=3, description=_"Unit Filters",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.unit_filters()" } } } } })
	wml_actions.set_menu_item({ id=4, description=_"Return Units to Recall List",
		{ "show_if", { } },
		{ "command", { { "lua", { code="cc.edit_troops_return_units()" } } } } })
	wml_actions.set_menu_item({ id=5, description=_"Set Recruit to Army Recruit",
		{ "show_if", { } },
		{ "command", { { "lua", { code="wml_actions.set_recruit({ side=1, recruit=army[" .. index .. "].recruit })" } } } } })
	wml_actions.set_menu_item({ id=6, description=_"Delete Unit",
		{ "show_if", { { "have_unit", { x="$x1", y="$y1", { "not", { id="Main Leader" } } } } } },
		{ "command", { { "lua", { code=[[wml_actions.kill({ x="$x1", y="$y1", animate="no", fire_event="no" })]] } } } } })
		
	-- create recruit event
	wml_actions.event({ name="prerecruit", id="recruit", first_time_only="no",
		{ "lua", { code = "cc.add_unit_to_recall_list()" } } })
	-- create recall event
	wml_actions.event({ name="prerecall", id="recall", first_time_only="no",
		{ "lua", { code = 'wml_actions.gold({ side=1, amount=wesnoth.game_config.recall_cost })' } } })

	return cc.unpack_entry(army[index], 1)
end

function cc.edit_troops_return_units()
	local units = {}
	for i,u in ipairs(wesnoth.get_recall_units({ side=1 })) do
		wesnoth.extract_unit(u)
		table.insert(units, u.__cfg)
	end
	for i,u in ipairs(wesnoth.get_units({ canrecruit="no" })) do
		wesnoth.extract_unit(u)
		table.insert(units, u.__cfg)
	end
	for i = 1, #units do
		cc.clear_ids(units[i])
		units[i].moves = units[i].max_moves
		wesnoth.put_recall_unit(units[i])
	end
end

function cc.edit_troops_end(index)
	-- save changes back into recall list
	-- get the __cfg for all units and place into troop_list field in appropriate army
	local choice = cc.get_user_choice({ speaker="narrator", message=_"Choose option:"},
		{ _"End and accept edits", _"End and discard edits", _"Continue editing" })
	
	if choice == 1 then
		local units = {}
		for i,u in ipairs(wesnoth.get_recall_units({ side=1 })) do
			wesnoth.extract_unit(u)
			table.insert(units, u.__cfg)
		end
		for i,u in ipairs(wesnoth.get_units({ side=1 })) do
			wesnoth.extract_unit(u)
			table.insert(units, u.__cfg)
		end
		for u = 1, #units do
			cc.clear_ids(units[u])
			units[u].hitpoints = units[u].max_hitpoints
			units[u].moves = units[u].max_moves
			units[u].attacks_left = units[u].max_attacks
			units[u].goto_x = 0; units[u].goto_y = 0
			units[u].side = 1
			for tag = #units[u], 1, -1 do
				-- do it this way so it'll get recreated when it is unpacked again,
				-- thus handling any custom status from add-ons
				if units[u][tag][1] == "status" then
					table.remove(units[u], tag)
				end
			end
		end
		-- erase previously stored units
		for u = 1, #army[index] do
			army[index][u] = nil
		end
		-- add the edited unit list
		for u = 1, #units do
			army[index][u] = { "troop_list", units[u] }
		end
	end
	
	if choice ~= 3 then
		-- cleanup:
		cc.clear_menu_items()
		wml_actions.kill({ animate="no", fire_event="no" })
		wml_actions.event({ id="recruit", remove=true })
		wml_actions.event({ id="recall", remove=true })
		return cc.army_options(index)
	end
end

----------------- CHANGE MAIN LEADER ---------------------------

function cc.change_main_leader(index)
	local options = cc.leader_display_list(index)
	-- calling leader display sorts the units so the leaders are on top, with main leader first
	-- thus we can use the integer from player's choice to make the needed change
	-- clear current designation of Main Leader
	army[index][1][2].id = nil
	local choice = cc.get_user_choice({ speaker="narrator", message=_"Select a leader to be the Main Leader." }, options)
	army[index][choice][2].id = "Main Leader"
	return cc.army_options(index)
end


----------------- EDIT STARTING RECALL --------------------------

function cc.edit_starting_recall(index)
	local list = { [-1]=_"All Loyal", [0]=0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	local choice = cc.get_user_choice({ speaker="narrator", message=_"How many troops would you like to have automatically recalled at the start of a battle?"}, list, -1)
	army[index].starting_recall = choice
	return cc.army_options(index)
end

----------------- ARMY INFORMATION ----------------------

function cc.army_info(index)
	wml_actions.message({ speaker="narrator", message=_"Information about Armies" ..
		"\n \n" .. _"Each army has a Main Leader. This is the leader whose picture appears for the army entry. " ..
		"\n \n" .. _"Under Edit Troops, you can add Heroes, Leaders, and Expendable Leaders. " ..
		_"If you lose a Hero or Leader, you are defeated. " ..
		_"If your Main Leader is an Expendable Leader and dies, Main Leader status will be reassigned to another Expendable Leader if possible, or a Leader. " ..
		_"If you have no more leaders left, your are defeated." ..
		"\n \n" .. _"When you play a scenario, the objectives will list the names of the units whose deaths will cause a loss." ..
		"\n \n" .. _"Starting Recall lets you set how many troops are recalled at the start of the battle. " ..
		_"If you pick a number, the troops are prioritized by loyal, then level, then least XP toward level-up. " ..
		_"Heroes, Leaders and Expendable Leaders are always automatically recalled for free."
	})
	return cc.army_options(index)
end

----------------- DELETE ENTRY -----------------------------------

function cc.delete_entry(caller, index)
	local choice = cc.get_user_choice({ speaker="narrator", message=_"Delete this entry?" }, { _"No", _"Yes" })
	if caller == "edit_army" then
		if choice == 2 then
			table.remove(army, index)
			return cc.army_list()
		else
			return cc.army_options(index)
		end
	elseif caller == "edit_faction" then
		if choice == 2 then
			table.remove(faction, index)
			return cc.faction_list()
		else
			return cc.faction_options(index)
		end
	end
end

--------------- END OF MENU FUNCTIONS ----------------------------------------

--------------- TRAIT, CUSTOMIZE, ADD_TO_RECALL, OTHERS ---------------------------
function cc.global_trait_array()
	-- place the gloabl traits into an array
	local trait_array = {}
	local trait_t = wesnoth.get_traits()
	local i = 1
	for k,v in pairs(trait_t) do
		trait_array[i] = v
		i = i + 1
	end
	return trait_array
end

--sort trait table by language name	sorting function
function cc.trait_sort(t1, t2)
	-- possibilties for male_name
	if tostring(t1.male_name) ~= nil and tostring(t2.male_name) ~= nil then
		return tostring(t1.male_name) < tostring(t2.male_name)
	elseif tostring(t1.male_name) ~= nil and tostring(t2.male_name) == nil then
		if tostring(t2.female_name) ~= nil then
			return tostring(t1.male_name) < tostring(t2.female_name)
		else
			return tostring(t1.male_name) < tostring(t2.name)
		end
	elseif tostring(t1.male_name) == nil and tostring(t2.male_name) ~= nil then
		if tostring(t1.female_name) ~= nil then
			return tostring(t1.female_name) < tostring(t2.male_name)
		else
			return tostring(t1.name) < tostring(t2.male_name)
		end
	-- possibilties for female_name
	elseif tostring(t1.female_name) ~= nil and tostring(t2.female_name) ~= nil then
		return tostring(t1.female_name) < tostring(t2.female_name)
	elseif tostring(t1.female_name) ~= nil and tostring(t2.female_name) == nil then
		return tostring(t1.female_name) < tostring(t2.name)
	elseif tostring(t1.female_name) == nil and tostring(t2.female_name) ~= nil then
		return tostring(t1.name) < tostring(t2.female_name)
	-- if they don't have male or female name, they must (should) have name
	elseif tostring(t1.name) ~= nil and tostring(t2.name) ~= nil then
		return tostring(t1.name) < tostring(t2.name)
	end
end

function cc.trait_list()
	-- returns a list of all traits known to the engine
	
	-- start with making a table containing the global traits
	local all_traits_t = cc.global_trait_array()
	
	-- add aged, feral, & loyal as none of the races in core cover them
	-- #textdomain wesnoth-help
	local _ = wesnoth.textdomain "wesnoth-help"
	local trait_aged = { id="aged", male_name=_"aged", female_name=_"female^aged",
		{ "effect", { apply_to="hitpoints", increase_total=-8 } }, 
		{ "effect", { apply_to="movement", increase=-1 } }, 
		{ "effect", { apply_to="attack", range="melee", increase_damage=-1 } } }
	-- musthave is unnecessary for feral here
	local trait_feral = { id="feral", male_name=_"feral", female_name=_"female^feral", 
		description=_"Receive only 50% defense in land-based villages", 
		{ "effect", { apply_to="defense", replace="true", { "defense", { village=-50 } } } } }
	local trait_loyal= { id="loyal", male_name=_"loyal", female_name=_"female^loyal",
		description=_"Zero upkeep", { "effect", { apply_to="loyal" } } }
	_ = nil
	table.insert(all_traits_t, trait_aged)
	table.insert(all_traits_t, trait_feral)
	table.insert(all_traits_t, trait_loyal)
	
	-- #textdomain wesnoth-Custom_Campaign
	
	-- traverse through all the races and add traits by id that are not already present
	for k,v in pairs(wesnoth.races) do
		for temp_trait in helper.child_range(wesnoth.races[k].__cfg, "trait") do
			local trait_is_present = false
			for i = 1, #all_traits_t do
				if temp_trait.id == all_traits_t[i].id then
					trait_is_present = true; break
				end
			end
			if trait_is_present == false then
				table.insert(all_traits_t, temp_trait)
			end
		end
	end
	
	table.sort(all_traits_t, cc.trait_sort)
	return all_traits_t
end

function cc.get_gender_choice(unit_type)
	-- Recieves a unit_type, Returns a gender
	local gender = wesnoth.unit_types[unit_type].__cfg.gender or "male"
	if gender == "male,female" or gender == "female,male" then
		local answer = cc.get_user_choice({ speaker="narrator", message=_"Chose a gender for the unit" }, { _"Male", _"Female" })
		if     answer == 1 then
			gender = "male"
		elseif answer == 2 then
			gender = "female"
		end
	end
	return gender
end

function cc_get_name_choice(unit_type, gender)
	-- Recieves unit_type & gender; Returns a name
	local name, names, choice
	local race = wesnoth.unit_types[unit_type].__cfg.race
	
	-- fetch gender names from races table
	if gender == "male" then
		names = wesnoth.races[race].__cfg.male_names
	elseif gender == "female" then
		names = wesnoth.races[race].__cfg.female_names
	end
	
	-- check if there are any, if so present name list + enter custom option
	if names then
		names = tostring(names)
		local name_choices = cc.split(names, ","); name_choices[0] = _"Custom / Random"
		choice = cc.get_user_choice({ speaker="narrator", message=_"Choose a name for the unit." }, name_choices, 0)
		name = name_choices[choice]
	end
	
	-- if there are none, or player wants custom / random, get player input.
	if not names or choice == 0 then
		name = cc.get_text_input({ speaker="narrator", message=_"Enter a name for the unit. (Leave blank for random, if applicable)" })
	end
	
	return name
end
	
function cc.get_trait_choice(unit_type)
	-- recieves a unit_type; returns an array of the chosen traits
	-- let player pick traits for the unit_type, from what unit could get randomly
	-- if unit doesn't get random traits, don't show
	
	local traits = {}
	local chosen_traits = {}
	local unit_race = wesnoth.unit_types[unit_type].__cfg.race
	local unit_num_traits = wesnoth.races[unit_race].num_traits
	-- this is adjusted by counting all the "musthave" traits
	-- if this number is greater than 0, user gets to pick traits for unit
	-- this provides a way to account for units like Falcon & Vampire Bat
	
	if wesnoth.unit_types[unit_type].__cfg.ignore_race_traits == true then
		-- first, check if unit ignore_race_traits=yes
		-- if yes, get possible traits from unit and add to trait table and we're done
		-- Naffat & Dark Adept end up here
		for t in helper.child_range(wesnoth.unit_types[unit_type].__cfg, "trait") do
			if t.availability ~= "musthave" then
				table.insert(traits, t)
			end
		end
	elseif wesnoth.races[unit_race].ignore_global_traits == true then
		-- second, check race if ignore_global_traits=yes
		-- if yes, compare num_traits to traits listed in race
		-- if num_traits is equal to the number of traits listed, unit gets no additional traits and we're done
		-- if num_traits is less than number of traits listed, make table of traits
		for t in helper.child_range(wesnoth.races[unit_race].__cfg, "trait") do
			table.insert(traits, t)
		end
		if wesnoth.races[unit_race].num_traits == #traits then
			-- don't need to do anything for this unit_type
			-- clear the table as the unit will automaticall get all traits allowed.
			-- Skeleton & Boat end up here
			traits = {}
		else -- there are more traits avaible than allowed
			-- present choice to user
			-- Goblins & Trolls are unit_types that end up here
		end
	elseif wesnoth.races[unit_race].num_traits == 0 then
		-- third, check if num_traits=0; if yes, we're done.
		-- Woses are an example here. Do nothing.
	else
		-- if ignore_global_traits ~= yes then
		-- extract traits from race and add global traits to make trait table.
		-- all other cases end up here
		for t in helper.child_range(wesnoth.races[unit_race].__cfg, "trait") do
			table.insert(traits, t)
		end
		local gta = cc.global_trait_array()
		for i = 1, #gta do
			table.insert(traits, gta[i])
		end
	end
	
	-- adjustment to account for things like Falcon and Vampire Bat
	-- which appear in race to get 2 random traits, but only get one,
	-- because of {FERAL_MUSTHAVE} in the unit_type
	if unit_num_traits > 0 then
		local unit_traits = {}
		for t in helper.child_range(wesnoth.unit_types[unit_type].__cfg, "trait") do
			table.insert(unit_traits, t)
		end
		if next(unit_traits) ~= nil then
			-- there are traits to check for musthave
			for i = 1, #unit_traits do
				if unit_traits[i].availability == "musthave" then
					unit_num_traits = unit_num_traits - 1
				end
			end
		end
	end
	
	-- present choices to user if there are any traits to choose from
	if  next(traits) ~= nil and unit_num_traits > 0 then
		-- first sort traits alphabetically by language name
		table.sort(traits, cc.trait_sort)
		
		-- make a list formatted for cc.get_user_choice()
		local trait_choices = {}
		for i = 1, #traits do
			-- use male_name,female_name, and name in that order
			if traits[i].male_name ~= nil then
				trait_choices[i] = traits[i].male_name
			elseif traits[i].female_name ~= nil then
				trait_choices[i] = traits[i].female_name
			else
				trait_choices[i] = traits[i].name
			end
		end
		
		while unit_num_traits > 0 do
		-- user must pick up to unit_num_traits, (i.e. can't get out of picking traits for goblins here)
			local answer = cc.get_user_choice({ speaker="narrator", message="Select a trait:" }, trait_choices)
			-- add chosen_traits and remove traits already chosen to prevent duplicates
			local selected_trait = table.remove(traits, answer)
			table.insert(chosen_traits, selected_trait)
			table.remove(trait_choices, answer)
			unit_num_traits = unit_num_traits - 1
		end
	else
		chosen_traits = traits
	end
	
	chosen_traits = cc.format_and_sort_unit_traits(chosen_traits, unit_type)
	return chosen_traits
end

function cc.get_full_trait_choice(unit_type)
	-- Recieves a unit_type; Returns a sorted array of chosen traits
	local traits = cc.trait_list()
	local chosen_traits = {}
	
	-- remove musthave_traits that the unit already has
	local u = wesnoth.create_unit({ type=unit_type, random_traits="no" })
	local modifications = helper.get_child(u.__cfg, "modifications")
	for t in helper.child_range(modifications, "trait") do		
		for i = #traits, 1, -1 do
			if t.availability == "musthave" and t.id == traits[i].id then
				table.remove(traits, i)
			end
		end
	end
	
	-- make a list formatted for cc.get_user_choice
	local trait_choices = {}
	for i = 1, #traits do
		-- use male_name,female_name, and name in that order
		if traits[i].male_name ~= nil then
			trait_choices[i] = traits[i].male_name
		elseif traits[i].female_name ~= nil then
			trait_choices[i] = traits[i].female_name
		else
			trait_choices[i] = traits[i].name
		end
	end

	-- let the player pick up to 5 times
	trait_choices[0] = cc.end_button()
	local count = 0
	repeat
		local answer = cc.get_user_choice({ speaker="narrator", message="Select up to 5 traits for this unit. Choose End when you are done." }, trait_choices, 0)
		if answer ~= 0 then
			-- add selected trait to chosen_traits, remove trait already chosen to prevent duplicates
			local selected_trait = table.remove(traits, answer)
			table.insert(chosen_traits, selected_trait )
			table.remove(trait_choices, answer)
			count = count + 1
		end
	until answer == 0 or count >= 5 or next(traits) == nil
	chosen_traits = cc.format_and_sort_unit_traits(chosen_traits, unit_type)
	return chosen_traits
end

function cc.format_and_sort_unit_traits(chosen_traits, unit_type)
	-- recieves an array of chosen_traits
	-- adds musthaves that are included with the unit's race or the unit
	-- sorts traits in a specific order for display purposes
	-- returns a wml_table of traits for using with wesnoth.create_unit
	
	-- format the chosen_traits for easy use in wesnoth.create_unit
	local formatted_traits = {}
	if next(chosen_traits) ~= nil then
		for i,v in ipairs(chosen_traits) do
			formatted_traits[i] = { "trait", chosen_traits[i] }
		end
	end
	
	-- spawning the unit adds in any musthaves if present, so they can be included in the sort
	local u = wesnoth.create_unit({ type=unit_type, random_traits="no", { "modifications", formatted_traits } })
	
	-- sort the traits
	-- sorted so that musthaves are first, so that vampire bat has feral,quick; not quick,feral
	-- loyal are second, in keeping with unit-utils.cfgf LOYAL_UNDEAD_UNIT trait order
	-- check for musthaves on first pass, loyal on second, and all others on the third.
	local mods = helper.get_child(u.__cfg, "modifications")
	local sorted_traits = {}
	
	local i = 1
	-- first pass - copy musthaves
	for t in helper.child_range(mods, "trait") do
		if t.availability == "musthave" then
			sorted_traits[i] = { "trait", t }
			i = i + 1
		end
	end
	-- second pass - copy loyal
	for t in helper.child_range(mods, "trait") do
		if t.id == "loyal" then
			sorted_traits[i] = { "trait", t }
			i = i + 1
			break -- end early, only one loyal
		end
	end
	-- third pass - copy all others
	for t in helper.child_range(mods, "trait") do
		if t.id ~= "loyal" and t.availability ~= "musthave" then
			sorted_traits[i] = { "trait", t }
			i = i + 1
		end
	end

	return sorted_traits
end

function cc.get_variation_choice(unit_type)
	-- Recieves a unit_type; Returns a variation
	-- most units will return variation="none"
	-- WC's & Souless will present a menu to select a variation
	local variation = "none"
	local v_choice = {}
	local i = 1
	for v in helper.child_range(wesnoth.unit_types[unit_type].__cfg, "variation") do
		v_choice[i] = v.variation_name
		i = i + 1
	end
	
	if next(v_choice) ~= nil then
		-- sort variation_choices, and present to player
		table.sort(v_choice)
		table.insert(v_choice, 1, "none")
		local answer = cc.get_user_choice({ speaker="narrator", message=_"Select a unit variation:" }, v_choice)
		variation = v_choice[answer]
	end
	
	return variation
end

function cc.customize_unit(u, leader)
	-- Recieves a proxy unit & optional leader statuts; Returns a proxy unit
	local ut = u.type
	-- use default type & image
	local uln = wesnoth.unit_types[ut].name
	local img = wesnoth.unit_types[ut].__cfg.image
	
	-- if making a primary leader, force player to option 3 for full customization
	local answer
	if not leader then
		answer = cc.get_user_choice({ speaker="narrator", image=img, message=_"You have chosen " .. uln .. ", how would you like to add it?" },
			{ _"Regular Random Recruit", _"With chosen gender and traits unit could normally get (if applicable)", _"Loyal, random gender, and no other traits", _"Fully Customize Unit" })
	end
	
	if answer == 1 and not leader then
		u = wesnoth.create_unit({ type=ut, canrecruit=leader })
	elseif answer == 2  and not leader then
		-- menu for chosen gender and traits
		local ug = cc.get_gender_choice(ut)
		local t = cc.get_trait_choice(ut)
		u = wesnoth.create_unit({ type=ut, canrecruit=leader, name=n, gender=g, random_traits=false, { "modifications", t } })
	elseif answer == 3 and not leader then
		-- done this way so the musthaves appear first
		u = wesnoth.create_unit({ type=ut, random_traits=false, overlays = "misc/loyal-icon.png" })
		local traits = cc.trait_list()
		for t = 1, #traits do
			if traits[t].id == "loyal" then
				wesnoth.add_modification(u, "trait", traits[t]); break
			end
		end
	elseif answer == 4 or leader then
		-- menu for chosen gender, variation, and up to any 5 traits.
		local id -- kept nil unless making a Main Leader
		local role -- kept nil, unless making a Leader, Expendable Leader, or Hero
		local g = cc.get_gender_choice(ut)
		local v = cc.get_variation_choice(ut)
		local t = cc.get_full_trait_choice(ut)
		local n = cc_get_name_choice(ut, g)
		-- check if loyal was chosen, if so, add loyal icon
		local loyal = helper.get_child(t, "trait", "loyal")
		local overlay
		if loyal then
			overlay = "misc/loyal-icon.png"
		end
		
		if leader then
			id = "Main Leader"
			role = "Leader"
		else
			local choice = cc.get_user_choice({ speaker="narrator", message=_"Would you like to make this unit special?" },
				{ _"No", _"Hero", _"Leader", _"Expendable Leader" })
			if choice == 2 then
				overlay = "misc/hero-icon.png"
				role = "Hero"
			elseif choice == 3 then
				leader = true
				role = "Leader"
			elseif choice == 4 then
				leader = true
				overlay = "misc/leader-expendable.png"
				role = "Expendable Leader"
			end
		end
		u = wesnoth.create_unit({ type=ut, id=id, canrecruit=leader, name=n, gender=g, random_traits="no", variation=v, overlays=overlay, role=role, { "modifications", t } })
	end
	return u
end

function cc.add_unit_to_recall_list()				
	local x,y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
	local u = wesnoth.get_unit(x,y)
	wesnoth.extract_unit(u)
	wml_actions.gold({ side=1, amount=u.__cfg.cost })
	
	u = cc.customize_unit(u)
	wesnoth.put_recall_unit(u)
	
	-- if a Hero, Leader or Expendable Leader was made, put him back on the map
	if u.__cfg.canrecruit == true or u.role == "Hero" then
		local loc = wesnoth.get_starting_location(1)
		wml_actions.recall({ x=loc[1], y=loc[2], id=u.id, show="no", fire_event="no" })
	end
end

------------------------- FILTERS -----------------------

function cc.reset_unit_filters()
	filter = {}
	filter.alignment = {}; filter.level = {}
	filter.move = {}; filter.race = {} ; filter.set = {}
	filter.alignment.id = "all"; filter.alignment.name = _"All"
	filter.level.id = "all"; filter.level.name = _"All"
	filter.move.id = "all"; filter.move.name = _"All"
	filter.race.id = "all"; filter.race.name = _"All"
	filter.set.id = "all"; filter.set.name = _"All"
end

function cc.unit_filters()
	-- Present a menu to the player chooses what units to filter for
	-- don't call anything when done, just fall back to player's turn
	repeat
		local choice = cc.get_user_choice({ speaker="narrator", message=_"Click a filter to adjust it." },
			{ cc.back_button(), _"Alignment: " .. filter.alignment.name, _"Level: " .. filter.level.name,
			_"Move: " .. filter.move.name, _"Race: " .. filter.race.name .. _"  (id: " .. filter.race.id .. ")",
			_"Set: " .. filter.set.name, _"Reset Filters" })

		if choice == 1 then
			-- run filters and fall out of menu
		elseif choice == 2 then -- Alignment
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Choose an alignment to filter for:" },
				{ _"All", _"Lawful", _"Neutral", _"Chaotic", _"Liminal" })
			if     answer == 1 then
				filter.alignment.id = "all"; filter.alignment.name = _"All"
			elseif answer == 2 then
				filter.alignment.id = "lawful"; filter.alignment.name = _"Lawful"
			elseif answer == 3 then
				filter.alignment.id = "neutral"; filter.alignment.name = _"Neutral"
			elseif answer == 4 then
				filter.alignment.id = "chaotic"; filter.alignment.name = _"Chaotic"
			elseif answer == 5 then
				filter.alignment.id = "liminal"; filter.alignment.name = _"Liminal"
			end
		elseif choice == 3 then -- Level
			local unit_types = cc.get_unit_type_ids()
			local list = cc.find_levels(unit_types)
			list[0] = _"All"
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Choose a level number to filter for:" }, list, 0)
			if answer == 0 then
				filter.level.id = "all"; filter.level.name = _"All"
			else
				filter.level.id = list[answer]; filter.level.name = list[answer]
			end
		elseif choice == 4 then -- Move
			local unit_types = cc.get_unit_type_ids()
			local list = cc.find_moves(unit_types)
			list[0] = _"All"
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Choose a move number to filter for:" }, list, 0)
			if answer == 0 then
				filter.move.id = "all"; filter.move.name = _"All"
			else
				filter.move.id = list[answer]; filter.move.name = list[answer]
			end
		elseif choice == 5 then -- Race
			local race_t = cc.find_races()
			local list = { [0] = _"All" }
			for i,v in ipairs(race_t) do
				list[i] = v.name .. "=" .. "(id: " .. v.id .. ")"
			end
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Choose a race to filter for:" }, list, 0)
			if answer == 0 then
				filter.race.id = "all"; filter.race.name = _"All"
			else
				filter.race.id = race_t[answer].id; filter.race.name = race_t[answer].name
			end
		elseif choice == 6 then -- Set
			local answer = cc.get_user_choice({ speaker="narrator", message=_"Choose a set to filter for:" },
				{ _"All", _"Core", _"Add-On" })
			if     answer == 1 then
				filter.set.id = "all"; filter.set.name = _"All"
			elseif answer == 2 then
				filter.set.id = "core"; filter.set.name = _"Core"
			elseif answer == 3 then
				filter.set.id = "add-on"; filter.set.name = _"Add-On"
			end
		elseif choice == 7 then -- Reset Filters
			cc.reset_unit_filters()
		end
	until choice == 1
	
	-- run filters
	local unit_types = cc.get_unit_type_ids()
	cc.run_filters(unit_types)
	local unit_list = table.concat(unit_types, ",")
	wml_actions.set_recruit({ side=1, recruit=unit_list })
end

function cc.run_filters(unit_types)
	-- Recieves an array of unit_types
    -- Run filters on the unit_types list
    -- Remove units that do not match the filters
    
    -- Retreive filter settings
    local alignment = filter.alignment.id
    local move = filter.move.id
    local level = filter.level.id
    local set = filter.set.id
    local race = filter.race.id
    
    -- Alignment Filter
    if alignment ~= "all" then
		for i = #unit_types, 1, -1 do
            if wesnoth.unit_types[unit_types[i]].__cfg.alignment ~= alignment then
                table.remove(unit_types, i)
			end
		end
    end
	
    -- Move Filter
    if move ~= "all" then
		for i = #unit_types, 1, -1 do
            if wesnoth.unit_types[unit_types[i]].max_moves ~= move then
                table.remove(unit_types, i)
			end
		end
    end
	
    -- Level Filter
    if level ~= "all" then
		for i = #unit_types, 1, -1 do
            if wesnoth.unit_types[unit_types[i]].__cfg.level ~= level then
                table.remove(unit_types, i)
			end
		end
    end
	
    -- Unit Set Filter
    if set ~= "all" then
        local core_units = cc.split(cc.core_list, ",")
        if set == "core" then			
			for i = #unit_types, 1, -1 do
				local is_core = false
				for j = 1, #core_units do
                    if wesnoth.unit_types[unit_types[i]].id == core_units[j] then
                        is_core = true; break
                    end
				end
				if is_core == false then
					table.remove(unit_types, i)
				end
			end
        elseif set == "add-on" then
			for i = #unit_types, 1, -1 do
				local is_core = false
				for j = 1, #core_units do
                    if wesnoth.unit_types[unit_types[i]].id == core_units[j] then
                        is_core = true; break
                    end
				end
				if is_core == true then
                    table.remove(unit_types, i)
                end
			end
        end
    end
	
    -- Race Filter
    if race ~= "all" then
		for i = #unit_types, 1, -1 do
			if wesnoth.unit_types[unit_types[i]].__cfg.race ~= race then
                table.remove(unit_types, i)
			end
		end
    end
end

function cc.find_levels(unit_types)
    -- Recieves an array of unit_types; Returns an array of levels
    local level_list = {}
	for i = 1, #unit_types do
        local unit_level = wesnoth.get_unit_type(unit_types[i]).__cfg.level
        local level_is_present = false
		for j = 1, #level_list do
            if unit_level == level_list[j]  then
                level_is_present = true; break
            end
        end
        if level_is_present == false then
            table.insert(level_list, unit_level)
        end
    end
    table.sort(level_list)
    return level_list
end

function cc.find_moves(unit_types)
	-- Recieves an array of unit_types; Returns an array of levels
    local move_list = {}
	for i = 1, #unit_types do
        local unit_move = wesnoth.get_unit_type(unit_types[i]).__cfg.movement
        local move_is_present = false
		for i = 1, #move_list do
            if unit_move == move_list[i]  then
                move_is_present = true; break
            end
        end
        if move_is_present == false then
            table.insert(move_list, unit_move)
        end
    end
    table.sort(move_list)
    return move_list
end

function cc.find_races()
	-- Returns an array of races with name and id
	-- sorted by name
	local races = {}
	local i = 1
	for k,v in pairs(wesnoth.races) do
		races[i] = { ["name"]=v.plural_name, ["id"]=v.id }
		i = i + 1
	end
	local function race_sort(uFirstElem, uSecElem)
	  if tostring(uFirstElem.name) == tostring(uSecElem.name) then return uFirstElem.id < uSecElem.id end
	  return tostring(uFirstElem.name) < tostring(uSecElem.name)
	end
	table.sort(races, race_sort)
	return races
end

function cc.find_usage(recruit)
	-- Recieves a recruit list; Returns an array of usage in alphabetical order
	-- calling this with an empty recruit will cause errors
    -- Compile a list of usage from all the units recruited
	local recruit_types = cc.split(recruit, ",")
    local usage_list = {}
	for i = 1, #recruit_types do
		local unit_usage = wesnoth.unit_types[recruit_types[i]].__cfg.usage
        local usage_is_present = false
		for j = 1, #usage_list do
            if unit_usage == usage_list[j] then
                usage_is_present = true; break
            end
        end
        if usage_is_present == false then
            table.insert(usage_list, unit_usage)
        end
    end
    table.sort(usage_list)
    return usage_list
end

--------------------------- END OF FILE RETURN -------------------------
return cc