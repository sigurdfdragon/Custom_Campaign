-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"
local T = wml.tag
local my_helper = wesnoth.require "~add-ons/Custom_Campaign/lua/my_helper.lua"

local unit_selection = {}

-- returns an array of wmltables for all unit types available.
function unit_selection.get_unit_types_all()
	local r = {}
	for key,value in pairs(wesnoth.unit_types) do
		local cfg = value.__cfg
		--Those units that are normally not meant to be recruited
		if not cfg.hide_help then
			table.insert(r, cfg)
		end
	end
	table.sort(r, function(u1,u2) return tostring(u1.name) < tostring(u2.name) end)
	return r
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
					wesnoth.interface.add_chat_message("Custom Campaign", "found a unit_type with an invalid race '" .. tostring(value.race) .. "'")
				end
			end
		end
		found_races[value.race or ""] = true
	end
	table.sort(retv, function(r1,r2) return tostring(r1.plural_name) < tostring(r2.plural_name) end)
	return retv
end

function unit_selection.get_biggest_race_size(unit_types)
	local maxkey, maxvalue = my_helper.tablemax(
		my_helper.tablegroupby(unit_types, function(index, ut) return (ut.race or "unknown") end),
		function(t1,t2) return #t1 < #t2 end
	)
	return maxvalue and #maxvalue or 0
end

cc_create_unit_options = {}
-- @returns an array of unit id strings.
function unit_selection.do_selection()
	local dialogs = wesnoth.require "~add-ons/Custom_Campaign/lua/dialogs/unit_selection.lua"
	-- creating the unit options list is slow, make sure we only do it once
	-- global cc_create_unit_options initialized above
	local unit_types = {}
	if #cc_create_unit_options == 0 then
		unit_types = unit_selection.get_unit_types_all()
		cc_create_unit_options = unit_types
	else
		unit_types = cc_create_unit_options
	end

	local unit_races = unit_selection.get_unit_races(unit_types)
	local maxrace_size = unit_selection.get_biggest_race_size(unit_types)

	--a list containing integerindexes to unit_types
	local current_unit_list = {}
	local current_selected_unit_index = 0

	local set_race = function(race_number)
		race_number = race_number or wesnoth.get_dialog_value("race_list")
		local race_id = unit_races[race_number].id
		local index = 1
		current_unit_list = {}
		for index2,value in ipairs(unit_types) do
			if value.race == race_id then
				wesnoth.set_dialog_value((value.image or "") .."~RC(magenta>red)~SCALE_INTO_SHARP(72,72)", "unit_list", index, "list_image")
				wesnoth.set_dialog_value((value.name or ""), "unit_list", index, "list_name")
				wesnoth.set_dialog_value("themes/gold.png", "unit_list", index, "list_gold_icon")
				wesnoth.set_dialog_value((value.cost or ""), "unit_list", index, "list_cost")
				current_unit_list[index] = index2
				index = index + 1
			end
		end
		while index <= maxrace_size do
			wesnoth.set_dialog_value(my_helper.thex_png , "unit_list", index, "list_image")
			wesnoth.set_dialog_value(" ", "unit_list", index, "list_name")
			wesnoth.set_dialog_value(my_helper.thex_png .. "~SCALE(16,16)", "unit_list", index, "list_gold_icon")
			wesnoth.set_dialog_value(" ", "unit_list", index, "list_cost")
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

	local preshow = function()
		for index,value in ipairs(unit_races) do
			wesnoth.set_dialog_value(unit_races[index].plural_name or "a", "race_list",index, "race_name")
		end
		wesnoth.set_dialog_value(_"Select Unit", "title")
		wesnoth.set_dialog_callback(set_race, "race_list")
		wesnoth.set_dialog_callback(set_unit, "unit_list")
		set_race()
		set_unit()
	end

	local i = gui.show_dialog(dialogs.normal, preshow)
  return i, unit_types[current_selected_unit_index].id
end

return unit_selection
