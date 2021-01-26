-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

data:extend({
  --
  -- Startup settings
  --
	{
		type = "bool-setting",
		name = "shuttle-train-add-grids",
		setting_type = "startup",
		default_value = true,
	},

	--
	-- Map settings
	--
	{
		type = "string-setting",
		name = "shuttle-train-global-exit-action",
		order = "a1",
		setting_type = "runtime-global",
		default_value = "Automatic",
		allowed_values = { "Automatic", "Manual", "Depot"}, 
		allow_blank = false,
	},
	{
		type = "string-setting",
		name = "shuttle-train-global-depot",
		order = "b1",
		setting_type = "runtime-global",
		default_value = "Shuttle Train Depot",
		allow_blank = false,
	},
	{
		type = "string-setting",
		name = "shuttle-train-global-exclude",
		order = "c1",
		setting_type = "runtime-global",
		default_value = "Shuttle Train Depot",
		allow_blank = true,
	},
	{
		type = "bool-setting",
		name = "shuttle-train-global-exclude-invert",
		order = "c2",
		setting_type = "runtime-global",
		default_value = "false",
	},
	{
		type = "bool-setting",
		name = "shuttle-train-global-ignore-manual-trains",
		order = "d1",
		setting_type = "runtime-global",
		default_value = false
	},

	--
	-- Player settings
	--
	{
    type = "int-setting",
    name = "shuttle-train-gui-height",
		order = "a1",
    setting_type = "runtime-per-user",
    default_value = 15,
    minimum_value = 1,
    maximum_value = 100,
  },
	{
		type = "string-setting",
		name = "shuttle-train-dialog-default",
		order = "a2",
		setting_type = "runtime-per-user",
		default_value = "all",
		allowed_values = { "all", "history", "last"}, 
	},
	{
		type = "bool-setting",
		name = "shuttle-train-search-ignore-items",
		order = "b1",
		setting_type = "runtime-per-user",
		default_value = true
	},
	{
    type = "bool-setting",
    name = "shuttle-train-focus-search",
		order = "b2",
    setting_type = "runtime-per-user",
    default_value = false
  },
	{
    type = "bool-setting",
    name = "shuttle-train-shortcut-call-train",
		order = "c1",
    setting_type = "runtime-per-user",
    default_value = true
  },
	{
		type = "bool-setting",
		name = "shuttle-train-dot-to-go",
		order = "c2",
		setting_type = "runtime-per-user",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "shuttle-train-smart-manual-destinations",
		order = "c3",
		setting_type = "runtime-per-user",
		default_value = false
	},
	{
		type = "string-setting",
		name = "shuttle-train-exit-action",
		order = "o1",
		setting_type = "runtime-per-user",
		default_value = "",
		allowed_values = { "", "Automatic", "Manual", "Depot"}, 
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-depot",
		order = "o2",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true,
	},
	{
		type = "string-setting",
		name = "shuttle-train-exclude",
		order = "o3",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true,
	},
	{
		type = "bool-setting",
		name = "shuttle-train-exclude-invert",
		order = "o4",
		setting_type = "runtime-per-user",
		default_value = "false",
	},
})

