-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Toggle the dialog for a player.
--
-- @param player The player to toggle the dialog for
-- 
function toggleDialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]
  local visible = nil

  if not dialog then
    dialog = openDialog(player)
  elseif dialog.visible then
    dialog.visible = false
  else
    openDialog(player)
  end
end


--
-- Close the dialog for a player.
--
-- @param player The player to close the dialog for
-- 
function closeDialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]

  if dialog then
    dialog.visible = false

    if player.opened == dialog then
      player.opened = nil
    end
  end

end


--
-- Add a titlebar to the dialog
--
-- @param dialog The LuaGuiElement to add the titlebar to
--
local function addTitlebar(dialog)
  local titlebar = dialog.add{type = "flow", name = "flow_titlebar", direction = "horizontal"}
  titlebar.drag_target = dialog
  
  local title = titlebar.add{type = "label", style = "caption_label", caption = {"dialog.caption"}}
  title.drag_target = dialog

  local handle = titlebar.add{type = "empty-widget", style = "draggable_space"}
  handle.drag_target = dialog
  handle.style.horizontally_stretchable = true
  handle.style.top_margin = 2
  handle.style.height = 24
  handle.style.width = 260

  local flow_buttonbar = titlebar.add{type = "flow", direction = "horizontal"}
  flow_buttonbar.style.top_margin = 4

  local closeButton = flow_buttonbar.add{type = "sprite-button", name = DIALOG_CLOSE_NAME,
    style = "frame_action_button", sprite = "utility/close_white", mouse_button_filter = {"left"}}
  closeButton.style.left_margin = 2
  closeButton.style.top_margin = 0
end


--
-- Open the station selection dialog for a player.
--
-- @param player The LuaPlayer to open the dialog for
--
function openDialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]

  if false and dialog then
    dialog.destroy()
    dialog = nil
  end

  local searchField

  if not dialog then
    dialog = player.gui.screen.add{type = "frame", name = DIALOG_NAME, direction = "vertical", auto_center = true}
    dialog.location = {200, 100}
    dialog.style.minimal_height = 200;
    addTitlebar(dialog)

    local flow = dialog.add{type = "flow", name ="flowSearch", direction = "horizontal"}
    flow.add{type = "label", caption = {"dialog.search"}}
    searchField = flow.add{type = "textfield", name = DIALOG_SEARCH}

    local pane = dialog.add{type = "scroll-pane", name = "stationsPane", horizontal_scroll_policy = "never",
                            vertical_scroll_policy = "auto-and-reserve-space" }
    pane.style.horizontally_stretchable = true
  else
    searchField = dialog.flowSearch[DIALOG_SEARCH]
  end

  local guiHeight = settings.get_player_settings(player)["shuttle-train-gui-height"].value
  dialog.style.maximal_height = 90 + guiHeight * 32;

  dialog.visible = true
  player.opened = dialog

  if settings.get_player_settings(player)["shuttle-train-focus-search"].value then
    searchField.focus()
  end
  searchField.text = ""

  local defaultCategorySetting = settings.get_player_settings(player)["shuttle-train-dialog-default"].value
  if defaultCategorySetting == "history" then
    global.selectedCategory[player.index] = DIALOG_CATEGORY_HISTORY
  elseif defaultCategorySetting == "all" then
    global.selectedCategory[player.index] = nil
  end

  updateStationsDialog(player)
end


local function createCategoryButton(parent, idx, category, selected)
  local style = "shuttle_train_tool_button"
  if selected then style = "shuttle_train_highlighted_tool_button" end

  local btn
  if category == DIALOG_CATEGORY_HISTORY then
    btn = parent.add{type = "sprite-button", style = style, name = DIALOG_CATEGORY_PREFIX..idx, caption = category,
                     sprite = "utility/clock", tooltip = {"tooltip.categoryHistory"}}
  elseif category == DIALOG_CATEGORY_ALL then
    btn = parent.add{type = "button", style = style, name = DIALOG_CATEGORY_PREFIX..idx, caption = category,
                     tooltip = {"tooltip.categoryAll"}}
  elseif category then
    btn = parent.add{type = "button", style = style, name = DIALOG_CATEGORY_PREFIX..idx, caption = category,
                     tooltip = {"tooltip.category"}}
  else
    btn = parent.add{type = "label", name = DIALOG_CATEGORY_PREFIX..idx, caption = " "}
  end
  btn.style.minimal_width = 48
  btn.style.maximal_width = 48
  return btn
end


--
-- Update the list of stations in the dialog.
--
-- @param player The LuaPlayer to update for
--
function updateStationsDialog(player)
  local dialog = player.gui.screen[DIALOG_NAME]
  if not dialog or not dialog.visible then return end

  dialog.stationsPane.scroll_to_top()

  local search = dialog.flowSearch[DIALOG_SEARCH].text:lower()
  if dialog.stationsPane.stationsTable then dialog.stationsPane.stationsTable.destroy() end

  local stationsTable = dialog.stationsPane.add{type = "table", name = "stationsTable", column_count = 2, vertical_centering = false }
  local stationFilterFunc = createStationExcludeFilter(player)

  local stations = player.surface.find_entities_filtered({type = "train-stop", force = player.force})
  local comp = function(a,b)
    return stations[a].backer_name:lower() < stations[b].backer_name:lower()
  end

  local stationNames = {}
  local lastName
  for _,station in sortedPairs(stations, comp) do
    local name = station.backer_name:lower()
    if name ~= lastName and not stationFilterFunc(name) then
      table.insert(stationNames, station.backer_name)
      lastName = name
    end
  end

  local selectedCategory = global.selectedCategory[player.index] or DIALOG_CATEGORY_ALL
  local filterCategory = selectedCategory
  if selectedCategory == DIALOG_CATEGORY_ALL then filterCategory = nil end

  local categories = { DIALOG_CATEGORY_ALL, DIALOG_CATEGORY_HISTORY }
  local idx = #categories
  local categoriesMap = {}
  for _,name in pairs(stationNames) do
    local category = string.gsub(name, "^%s*(%[[^%]]+%]).*$", "%1")
    if category ~= name and not categoriesMap[category] then
      categoriesMap[category] = true
      categories[idx + 1] = category
      idx = idx + 1
    end
  end

  if search ~= "" then
    selectedCategory = DIALOG_CATEGORY_ALL
  elseif selectedCategory == DIALOG_CATEGORY_HISTORY then
    stationNames = global.history[player.index] or {}
    filterCategory = nil
  end

  local searchFilterFunc = createSearchFilter(player, search)

  idx = 1
  local btn
  for _,name in pairs(stationNames) do
    if (search ~= "" and searchFilterFunc(name)) or
       (search == "" and (not filterCategory or string.find(name, filterCategory, 1, true) == 1)) then

      createCategoryButton(stationsTable, idx, categories[idx], categories[idx] == selectedCategory)

      btn = stationsTable.add{type = "button", name = DIALOG_STATION_PREFIX..idx, caption = name}
      btn.style.horizontally_stretchable = true
      btn.style.horizontal_align = "left"
      idx = idx + 1
    end
  end

  while idx <= #categories do
    createCategoryButton(stationsTable, idx, categories[idx], categories[idx] == selectedCategory)
    stationsTable.add{type = "label", name = DIALOG_STATION_PREFIX..idx, caption = " "}
    idx = idx + 1
  end
end


--
--  Get the name of the first station in the station list.
--
--  @param player The LuaPlayer to get the station for
--  @return The name of the topmost station, nil if none
--
function getTopDialogStation(player)
  local dialog = player.gui.screen[DIALOG_NAME]
  if not dialog or not dialog.visible then return nil end

  local stationsTable = dialog.stationsPane.stationsTable
  if not stationsTable then return nil end

  local station = stationsTable[DIALOG_STATION_PREFIX.."1"]
  if station then return station.caption end
  
  return nil
end

