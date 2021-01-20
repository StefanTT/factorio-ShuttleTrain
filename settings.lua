-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

data:extend({
	{
		type = "bool-setting",
		name = "shuttle-train-add-grids",
		setting_type = "startup",
		default_value = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-global-exit-action",
		setting_type = "runtime-global",
		default_value = "Automatic",
		allowed_values = { "Automatic", "Manual", "Depot"}, 
		allow_blank = false,
	},
	{
		type = "bool-setting",
		name = "shuttle-train-global-ignore-manual-trains",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "string-setting",
		name = "shuttle-train-exit-action",
		setting_type = "runtime-per-user",
		default_value = "",
		allowed_values = { "", "Automatic", "Manual", "Depot"}, 
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-global-depot",
		setting_type = "runtime-global",
		default_value = "Shuttle Train Depot",
		allow_blank = false,
	},
	{
		type = "string-setting",
		name = "shuttle-train-depot",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-global-exclude",
		setting_type = "runtime-global",
		default_value = "",
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-exclude",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true,
	},
	{
    type = "int-setting",
    name = "shuttle-train-gui-height",
    setting_type = "runtime-per-user",
    default_value = 15,
    minimum_value = 1,
    maximum_value = 100,
  },
	{
    type = "bool-setting",
    name = "shuttle-train-shortcut-call-train",
    setting_type = "runtime-per-user",
    default_value = true
  },
	{
    type = "bool-setting",
    name = "shuttle-train-focus-search",
    setting_type = "runtime-per-user",
    default_value = false
  },
	{
		type = "string-setting",
		name = "shuttle-train-dialog-default",
		setting_type = "runtime-per-user",
		default_value = "all",
		allowed_values = { "all", "history", "last"}, 
	},
})

