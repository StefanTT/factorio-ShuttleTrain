-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

local eq = table.deepcopy(data.raw["solar-panel-equipment"]["solar-panel-equipment"])
eq.name = "shuttle-train"
eq.take_result = "shuttle-train"
eq.sprite.filename = "__ShuttleTrainRefresh__/graphics/icon.png"
eq.sprite.hr_version = nil
eq.shape.width = 2
eq.shape.height = 2
eq.power = "100W"
eq.categories = {"shuttle-train"}

data:extend({
  {
		type = "equipment-category",
		name = "shuttle-train"
	},
	{
		type = "equipment-grid",
		name = "shuttle-train",
		width = 2,
		height = 2,
		equipment_categories = { "shuttle-train" },
	},
  {
		type = "recipe",
		name = "shuttle-train",
		enabled = false,
		energy_required = 10,
		ingredients = {
			{"electronic-circuit", 10},
			{"iron-gear-wheel", 40},
			{"steel-plate", 20},
		},
		result = "shuttle-train"
	},
  {
		type = "item",
		name = "shuttle-train",
		icon = "__ShuttleTrainRefresh__/graphics/icon.png",
		icon_size = 32,
		placed_as_equipment_result = "shuttle-train",
		subgroup = "equipment",
		order = "f[shuttle]-a[shuttle-train]",
		stack_size = 10,
	},
	eq,
  {
		type = "technology",
		name = "shuttle-train",
		icon = "__ShuttleTrainRefresh__/graphics/tech.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "shuttle-train"
			}
		},
		prerequisites = {"automated-rail-transportation"},
		unit =
		{
			count = 70,
			ingredients =
			{
				{"automation-science-pack", 2},
				{"logistic-science-pack", 1},
			},
			time = 20
		},
		order = "c-g-b-a"
	},
  {
    type = "custom-input",
    name = "call-shuttle-train",
    key_sequence = "CONTROL + J",
    consuming = "game-only",
    order = "a"
  },
  {
    type = "custom-input",
    name = "send-shuttle-train-to-depot",
    key_sequence = "CONTROL + SHIFT + J",
    consuming = "game-only",
    order = "b"
  },
  {
    type = "shortcut",
    action = "lua",
    name = "shuttle-train-shortcut",
    order = "m[shuttle-train]",
    toggleable = false,
    icon = {
      filename = "__ShuttleTrainRefresh__/graphics/tool-button.png",
      flags = {"icon"},
      priority = "extra-high-no-scale",
      scale = 1,
      size = 32
    },
    small_icon = {
      filename = "__ShuttleTrainRefresh__/graphics/tool-button.png",
      flags = {"icon"},
      priority = "extra-high-no-scale",
      scale = 1,
      size = 24
    },
    disabled_small_icon = {
      filename = "__ShuttleTrainRefresh__/graphics/tool-button.png",
      flags = {"icon"},
      priority = "extra-high-no-scale",
      scale = 1,
      size = 24
    },
  },
})

