-- Copyright (c) the original shuttle train mod authors
-- See LICENSE.md in the project directory for license information.

local data = _G.data
if settings.startup["shuttle-train-add-grids"].value == true then
	for _, loc in pairs(data.raw.locomotive) do
		if not loc.equipment_grid then
			loc.equipment_grid = "shuttle-train"
		end
	end
end

local checked = {}
local function ensureCategory(name)
	if checked[name] then return end
	checked[name] = true

	local grid = data.raw["equipment-grid"][name]
	if type(grid) ~= "table" then return end
	if type(grid.equipment_categories) ~= "table" then grid.equipment_categories = {} end
	local found = false
	for _, cat in next, grid.equipment_categories do
		if cat == "shuttle-train" then
			found = true
			break
		end
	end
	if not found then
		table.insert(grid.equipment_categories, "shuttle-train")
	end
end

for _, loc in pairs(data.raw.locomotive) do
	if loc.equipment_grid then
		ensureCategory(loc.equipment_grid)
	end
end

-- Increase FARL grid to 4x2 to fit both modules
-- thanks nexela
local farlGrid = data.raw["equipment-grid"]["farl-equipment-grid"]
if farlGrid then
	farlGrid.width = 4
	farlGrid.height = 2
end

