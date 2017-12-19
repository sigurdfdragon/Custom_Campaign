-- #textdomain wesnoth-Custom_Campaign
local _ = wesnoth.textdomain "wesnoth-Custom_Campaign"
local helper = wesnoth.require("lua/helper.lua")
local T = helper.set_wml_tag_metatable {}

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
								border = "all",
								border_size = 5,
								horizontal_alignment = "left",
								GUI_FORCE_WIDGET_MINIMUM_SIZE(150,5,
									T.label {
										id = "list_name",
										linked_group = "cc_lg_name"
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


local main_window = {
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

return {
	normal = main_window;
}
