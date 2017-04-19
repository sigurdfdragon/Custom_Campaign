-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"

local helper = wesnoth.require "lua/helper.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions
local wml_conditionals = wesnoth.wml_conditionals

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_conditionals.cc_unit_has_gender_choice ( cfg )
	-- [cc_unit_has_gender_choice]
			-- x,y=required
	-- [/cc_unit_has_gender_choice]
	local gender_options = false
	local u = wesnoth.get_unit(cfg.x, cfg.y)
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
	local u = wesnoth.get_unit(cfg.x, cfg.y)
	local race = wesnoth.races[u.__cfg.race].__cfg
	if race.male_names or race.female_names then
		random_names = true
	end
	return random_names
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_conditionals.cc_unit_has_variations ( cfg )
	-- [cc_unit_has_variations]
			-- x,y=required
	-- [/cc_unit_has_variations]
	local u = wesnoth.get_unit(cfg.x, cfg.y)
	local unit_wml = wesnoth.unit_types[u.type].__cfg
	return helper.get_child(unit_wml, "variation")
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
	wesnoth.set_variable(cfg.variable or "race", wesnoth.races[cfg.race].__cfg)
end

function wml_actions.cc_store_time ( cfg )
	-- [cc_store_time]
			-- variable=the name of the variable into which to store the current system time. default 'time'
	-- [/cc_store_time]
	wesnoth.set_variable(cfg.variable or "time", os.date())
end

function wml_actions.cc_sort_array ( cfg )
	-- [cc_sort_array]
			-- name=name of the array
			-- first_key=to sort by
			-- second_key=to sort by if first key is equal
	-- [/cc_sort_array]
	local tArray = helper.get_variable_array(cfg.name)
	local function top_down_left_right(uFirstElem, uSecElem)
		if uFirstElem[cfg.first_key] == uSecElem[cfg.first_key] then
			return uFirstElem[cfg.second_key] < uSecElem[cfg.second_key]
		end
		return uFirstElem[cfg.first_key] < uSecElem[cfg.first_key]
	end
	table.sort(tArray, top_down_left_right)
	helper.set_variable_array(cfg.name, tArray)
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

	local tArray = helper.get_variable_array(cfg.name)

	local function top_down_left_right(u1, u2)
		-- assign a value from 1-6 based on unit attributes
		-- compare value of first element to second element
		-- in case of tie use language_name of unit to break a tie
		local function assign_rank ( u )
			local v = helper.get_child(u, "variables") or {}
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
	helper.set_variable_array(cfg.name, tArray)
end

-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_actions.cc_create_unit ( cfg )
	-- [cc_create_unit]
			-- x,y=required, where to create the new unit
			-- plain_unit=optional, prevents unit name, traits, & random gender
	-- [/cc_create_unit]
	local function top_down_left_right(uFirstElem, uSecElem)
		if uFirstElem.label == uSecElem.label then
			return uFirstElem.unit_type < uSecElem.unit_type
		end
		return uFirstElem.label < uSecElem.label
	end

	-- creating the options list is slow, make sure we only do it once
	-- global cc_create_unit_options initialized in {CC_CREATE_UNIT}
	if #cc_create_unit_options == 0 then
		for key,value in pairs(wesnoth.unit_types) do
			if not value.__cfg.do_not_list then
				local option = { image = value.__cfg.image, label = value.name, unit_type = key }
				table.insert(cc_create_unit_options, option)
			end
		end
		table.sort(cc_create_unit_options, top_down_left_right)
	end

	-- present message
	local i = wesnoth.show_message_dialog({
		message = "Select unit type:",
		}, cc_create_unit_options
	)

	-- make unit
	local unit = {}
	unit.type = cc_create_unit_options[i].unit_type
	unit.x = cfg.x
	unit.y = cfg.y
	if cfg.plain_unit == true then
		unit.generate_name = false
		unit.random_gender = false
		unit.random_traits = false
	end
	wesnoth.put_unit(unit)
end

function wml_actions.cc_scale_unit_experience ( cfg )
	-- [cc_scale_unit_experience]
			-- name=name of variable containing unit wml
	-- [/cc_scale_unit_experience]
	-- in mp, the player may change the experience modifier from one
	-- scenario to the next. this tag scales the unit's max_experience
	-- to match the change and adjusts experience to maintain the
	-- same ratio of experience to max_experience
	local unit_wml = wesnoth.get_variable(cfg.name)
	local xp_ratio = unit_wml.experience / unit_wml.max_experience
-- find correct max_experience by deleting old value and creating 
-- a dummy copy of unit to remake the key for the current scenario
	unit_wml.max_experience = nil
	local u = wesnoth.create_unit ( unit_wml )
	local adjusted_xp = helper.round( u.max_experience * xp_ratio )
	-- prevent leveling due to rounding
	if adjusted_xp == u.max_experience then
		adjusted_xp = adjusted_xp - 1
	end
	-- set unit_wml to the correct values
	unit_wml.experience = adjusted_xp
	unit_wml.max_experience = u.max_experience
	wesnoth.set_variable(cfg.name, unit_wml)
end
