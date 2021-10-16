-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"
local T = wml.tag
local my_helper = wesnoth.require "~add-ons/Custom_Campaign/lua/my_helper.lua"

-- returns an array of wmltables for all unit types available.
local function get_unit_types_all()
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

local function get_unit_races(unit_types)
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

local function get_biggest_race_size(unit_types)
	local maxkey, maxvalue = my_helper.tablemax(
		my_helper.tablegroupby(unit_types, function(index, ut) return (ut.race or "unknown") end),
		function(t1,t2) return #t1 < #t2 end
	)
	return maxvalue and #maxvalue or 0
end

cc_create_unit_options = {}
-- @returns an array of unit id strings.
local function do_selection()
	-- local dialogs = wesnoth.require "~add-ons/Custom_Campaign/lua/dialogs/unit_selection.lua"
	-- creating the unit options list is slow, make sure we only do it once
	-- global cc_create_unit_options initialized above
	local unit_types = {}
	if #cc_create_unit_options == 0 then
		unit_types = get_unit_types_all()
		cc_create_unit_options = unit_types
	else
		unit_types = cc_create_unit_options
	end

	local unit_races = get_unit_races(unit_types)
	local maxrace_size = get_biggest_race_size(unit_types)

	--a list containing integerindexes to unit_types
	local current_unit_list = {}
	local current_selected_unit_index = 0


	local function GUI_FORCE_WIDGET_MINIMUM_SIZE(w,h, content)
		return T.stacked_widget {
			definition = "default",
			T.layer {
				T.row {
					T.column {
						T.spacer {
							definition = "default",
							width = w,
							height = h
						}
					}
				}
			},
			T.layer {
				T.row {
					grow_factor = 1,
					T.column {
						grow_factor = 1,
						horizontal_grow = "true",
						vertical_grow = "true",
						content
					}
				}
			}
		}
	end


	local unit_list = T.listbox {
		id = "unit_list",
		vertical_scrollbar_mode = "always",
		T.list_definition {
			T.row {
				T.column {
					grow_factor = 1,
					horizontal_grow = true,
					vertical_grow = true,
					T.toggle_panel {
						return_value_id = "ok",
						T.grid {
							T.row {
								grow_factor = 1,
								T.column {
									border = "all",
									border_size = 5,
									horizontal_alignment = "left",
									T.image {
										id = "list_image",
										linked_group = "cc_image"
									}
								},
								T.column {
									grow_factor = 1,
									horizontal_grow = true,
									T.grid {
										T.row {
											T.column {
												border = "all",
												border_size = 5,
												horizontal_alignment = "left",
												GUI_FORCE_WIDGET_MINIMUM_SIZE(175,5,
												T.label {
													id = "list_name",
													linked_group = "cc_lg_name"
												}
												)
											}
										},
										T.row {
											T.column {
												horizontal_alignment = "left",
												T.grid {
													T.row {
														grow_factor = 0,
														T.column {
															border = "left,bottom",
															border_size = 5,
															horizontal_alignment = "left",
															T.image {
																id = "list_gold_icon"
															}
														},
														T.column {
															border = "left,bottom,right",
															border_size = 5,
															horizontal_alignment = "left",
															GUI_FORCE_WIDGET_MINIMUM_SIZE(70,5,
															T.label {
																id = "list_cost"
															}
															)
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}


	local race_list = T.listbox {
		id = "race_list",
		T.list_definition {
			T.row {
				T.column {
					grow_factor = 1,
					horizontal_grow = true,
					vertical_grow = true,
					T.toggle_panel {
						T.grid {
							T.row {
								grow_factor = 1,
								T.column {
									border = "all",
									border_size = 5,
									horizontal_alignment = "left",
									T.label {
										id = "race_name",
										linked_group = "cc_lg_race_name"
									}
								}
							}
						}
					}
				}
			}
		}
	}


	local details_panel_pages =   T.grid {
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_grow = true,
				vertical_grow = true,
				T.unit_preview_pane {
					definition = "default",
					id = "unit_preview"
				}
			}
		},
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_alignment = "left",
				vertical_alignment = "bottom",
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							horizontal_alignment = "left",
							vertical_alignment = "bottom",
							T.button {
								id = "ok",
								label = _"Select"
							},
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_alignment = "left",
							vertical_alignment = "bottom",
							T.button {
								id = "cancel",
								label = _"Cancel"
							},
						},
					},
				}
			}
		}
	}


	local dialog = {
		maximum_height = 700,
		maximum_width = 900,

		T.helptip { id = "tooltip" }, -- mandatory field
		T.tooltip { id = "tooltip" }, -- mandatory field

		T.linked_group { id = "cc_image", fixed_width = true },
		T.linked_group { id = "cc_lg_name", fixed_width = true },
		T.linked_group { id = "cc_lg_race_name", fixed_width = true },

		T.grid {
			T.row {
				grow_factor = 1,
				T.column {
					border = "all",
					border_size = 5,
					horizontal_alignment = "left",
					T.label {
						definition = "title",
						label = _"Select Unit",
						id = "title"
					}
				}
			},
			T.row {
				grow_factor = 1,
				T.column {
					horizontal_grow = true,
					vertical_grow = true,
					T.grid {
						T.row {
							T.column {
								border = "all",
								border_size = 5,
								horizontal_grow = true,
								vertical_grow = true,
								race_list
							},
							T.column {
								border = "all",
								border_size = 5,
								horizontal_grow = true,
								vertical_grow = true,
								unit_list
							},
							T.column {
								horizontal_grow = true,
								vertical_grow = true,
								details_panel_pages
							},
						}
					}
				}
			}
		}
	}


	local function preshow (dialog)
		for index,value in ipairs(unit_races) do
			local widget = dialog:find("race_list", index, "race_name")
			widget.label = unit_races[index].plural_name or "a"
		end

		local set_race = function()
			local race_number = dialog.race_list.selected_index
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
			dialog.unit_preview.unit = wesnoth.unit_types[unit_types[current_selected_unit_index].id]
		end

		local set_unit = function()
			local unit_number = dialog.unit_list.selected_index
			if current_unit_list[unit_number] == nil then return end
			current_selected_unit_index = current_unit_list[unit_number]
			update_unit()
		end

		dialog.race_list.on_modified = set_race
		dialog.unit_list.on_modified = set_unit
		set_race()
		set_unit()
	end

	local i = gui.show_dialog(dialog, preshow)
  return i, unit_types[current_selected_unit_index].id
end

local result, utype = do_selection()
return result, utype
