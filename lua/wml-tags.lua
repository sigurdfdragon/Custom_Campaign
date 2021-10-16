-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"

-- to make code shorter
local wml_actions = wesnoth.wml_actions
local wml_conditionals = wesnoth.wml_conditionals

function wml_conditionals.cc_current_scenario_is ( cfg )
	-- [cc_current_scenario_is]
			-- scenario=required
	-- [/cc_current_scenario_is]
	local bool = false
	if cfg.scenario == wesnoth.scenario.id then
		bool = true
	end
	return bool
end

-- to check if a specific mod is active
function wml_conditionals.cc_modification_is_active ( cfg )
	-- [cc_modification_is_active]
			-- modification=required
	-- [/cc_modification_is_active]
	local bool = false
	for i = 1, #wesnoth.scenario.modifications do
		if wesnoth.scenario.modifications[i].id == cfg.modification then
			bool = true
			break
		end
	end
	return bool
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_conditionals.cc_unit_has_gender_choice ( cfg )
	-- [cc_unit_has_gender_choice]
			-- x,y=required
	-- [/cc_unit_has_gender_choice]
	local gender_options = false
	local u = wesnoth.units.get(cfg.x, cfg.y)
	if wesnoth.unit_types[u.type].__cfg.gender == "male,female" then
		gender_options = true
	end
	return gender_options
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_conditionals.cc_unit_has_random_names ( cfg )
	-- [cc_unit_has_random_names]
			-- x,y=required
	-- [/cc_unit_has_random_names]
	local random_names = false
	local u = wesnoth.units.get(cfg.x, cfg.y)
	local race = wesnoth.races[u.__cfg.race].__cfg
	local generate_name = wesnoth.unit_types[u.type].__cfg.generate_name
	if race.male_names or race.female_names then
		if not (generate_name == false) then -- To cover cases like the Direwolf
			random_names = true
		end
	end
	return random_names
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_conditionals.cc_unit_has_variations ( cfg )
	-- [cc_unit_has_variations]
			-- x,y=required
	-- [/cc_unit_has_variations]
	local u = wesnoth.units.get(cfg.x, cfg.y)
	local unit_wml = wesnoth.unit_types[u.type].__cfg
	return wml.get_child(unit_wml, "variation")
end

function wml_conditionals.cc_unit_type_is_valid ( cfg )
	-- [cc_unit_type_is_valid]
			-- type=required, the unit type to check
	-- [/cc_unit_type_is_valid]
	return wesnoth.unit_types[cfg.type]
end

function wml_actions.cc_store_race ( cfg )
	-- [cc_store_race]
			-- race=(required) the defined ID of the race to store
			-- variable=the name of the variable into which to store the race information. default 'race'
	-- [/cc_store_race]
	wml.variables[cfg.variable or "race"] = wesnoth.races[cfg.race].__cfg
end

function wml_actions.cc_store_time ( cfg )
	-- [cc_store_time]
			-- variable=the name of the variable into which to store the current system time. default 'time'
	-- [/cc_store_time]
	wml.variables[cfg.variable or "time"] = os.date()
end

function wml_actions.cc_sort_array ( cfg )
	-- [cc_sort_array]
			-- name=name of the array
			-- first_key=to sort by
			-- second_key=to sort by if first key is equal
	-- [/cc_sort_array]
	local tArray = wml.array_access.get(cfg.name)
	local function top_down_left_right(uFirstElem, uSecElem)
		if uFirstElem[cfg.first_key] == uSecElem[cfg.first_key] then
			return uFirstElem[cfg.second_key] < uSecElem[cfg.second_key]
		end
		return uFirstElem[cfg.first_key] < uSecElem[cfg.first_key]
	end
	table.sort(tArray, top_down_left_right)
	wml.array_access.set(cfg.name, tArray)
end

function wml_actions.cc_special_unit_sort ( cfg )
	-- [cc_special_unit_sort]
			-- name=name of an array containing units
	-- [/cc_special_unit_sort]

-- Sort the units to be in order by cc_role: commander,lieutenant,reserve,hero,loyal,none
-- so they will receive an underlying_id in order when they are unpacked
-- leader of side with lowest underlying_id is pictured in various places, 
-- like the status table and loading a saved game.
-- Also, when the Unit List is first opened the units are shown in order of underlying_id

	local tArray = wml.array_access.get(cfg.name)

	local function top_down_left_right(u1, u2)
		-- assign a value from 1-6 based on unit attributes
		-- compare value of first element to second element
		-- in case of tie use language_name of unit to break a tie
		local function assign_rank ( u )
			local v = wml.get_child(u, "variables") or {}
			if v.cc_role == nil or v.cc_role == ""  then
				return 6 -- unit is nothing special
			elseif v.cc_role == "loyal" then
				return 5
			elseif v.cc_role == "hero" then
				return 4
			elseif v.cc_role == "reserve" then
				return 3
			elseif v.cc_role == "lieutenant" then
			return 2
			elseif v.cc_role == "commander" then
				return 1
			else
				return 0 -- error, nothing should end up here
			end
		end
		local first,second = 0,0
		first,second = assign_rank( u1 ), assign_rank( u2 )
		if first == second then
			return u1.language_name < u2.language_name
		end
		return first < second
	end

	table.sort(tArray, top_down_left_right)
	wml.array_access.set(cfg.name, tArray)
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_actions.cc_create_unit ( cfg )
	-- [cc_create_unit]
			-- x,y=required, where to create the new unit
			-- plain_unit=optional, prevents unit name, traits, & random gender
	-- [/cc_create_unit]
	-- unit selection code modified from Pick Your Recruits No Preparation Turn Modification by gfgtdf
	local i, selected_unit = wesnoth.dofile "~add-ons/Custom_Campaign/lua/unit_selection.lua"
	if i == -1 then
		local unit = {}
		unit.type = selected_unit
		if cfg.plain_unit == true then
			unit.generate_name = false
			unit.random_gender = false
			unit.random_traits = false
		else
			unit.random_gender = true
		end
		wesnoth.units.to_map(unit, cfg.x, cfg.y, true)
	end
end

function wml_actions.cc_scale_unit_experience ( cfg )
	-- [cc_scale_unit_experience]
			-- name=name of variable containing unit wml
	-- [/cc_scale_unit_experience]
	-- in mp, the player may change the experience modifier from one
	-- scenario to the next. this tag scales the unit's max_experience
	-- to match the change and adjusts experience to maintain the
	-- same ratio of experience to max_experience
	local unit_wml = wml.variables[cfg.name]
	local xp_ratio = unit_wml.experience / unit_wml.max_experience
-- find correct max_experience by deleting old value and creating 
-- a dummy copy of unit to remake the key for the current scenario
	unit_wml.max_experience = nil
	local u = wesnoth.units.create ( unit_wml )
	local adjusted_xp = mathx.round( u.max_experience * xp_ratio )
	-- prevent leveling due to rounding
	if adjusted_xp == u.max_experience then
		adjusted_xp = adjusted_xp - 1
	end
	-- set unit_wml to the correct values
	unit_wml.experience = adjusted_xp
	unit_wml.max_experience = u.max_experience
	wml.variables[cfg.name] = unit_wml
end
