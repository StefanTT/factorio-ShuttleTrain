-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

local ignoredStates = {
  [defines.train_state.on_the_path] = true,
  [defines.train_state.arrive_signal] = true,
  [defines.train_state.wait_signal] = true,
  [defines.train_state.arrive_station] = true,
}

--
-- Called when the player's driving state has changed, this means a player has either entered or left a vehicle.
--
-- @param event The event containing
--        player_index :: uint
--        entity :: LuaEntity (optional): The vehicle (if any)
--
local function onPlayerDrivingChangedState(event)
  if not event.entity or not event.entity.valid then return end

  local player = game.players[event.player_index]
  if not player then return end

  if player.vehicle then
    if controlsShuttleTrain(player) then
      log("player "..player.name.." entered shuttle train "..player.vehicle.train.front_stock.backer_name)
      openDialog(player)
    end
  else
    if event.entity.train and isShuttleTrain(event.entity.train) then
      log("player "..player.name.." exited shuttle train "..event.entity.train.front_stock.backer_name)
      closeDialog(player)
      if #event.entity.train.passengers == 0 then
        log("shuttle train finished transportation")
        untrackTrain(event.entity.train)
      end
    end
  end
end


--
-- Called when a train changes status (started to stopped and vice versa)
--
-- @param event The event containing
--        train :: LuaTrain
--        old_state :: defines.train_state
--
local function onTrainChangedStatus(event)
  local train = event.train
  if global.trackedTrains[train.id] and not ignoredStates[train.state] then
    onTrackedTrainChangedStatus(train)
  end
end


--
-- Call a shuttle train to a nearby station.
--
-- @param event The event containing
--        player_index :: uint
--
local function onCallShuttleTrain(event)
  local player = game.players[event.player_index]
  if not player then return end
  if controlsShuttleTrain(player) then
    toggleDialog(player)
  else
    callShuttleTrain(player)
  end
end


--
-- Handle a shortcut event.
--
-- @param event The shortcut event containing
--        player_index :: uint
--        prototype_name :: string: Shortcut prototype name of the shortcut that was clicked
--
local function onShortcut(event)
  if event.prototype_name == "shuttle-train-shortcut" then
    local player = game.players[event.player_index]
    if not player then return end
    if controlsShuttleTrain(player) then
      toggleDialog(player)
    elseif not player.vehicle or not player.vehicle.train then
      if settings.get_player_settings(player)["shuttle-train-shortcut-call-train"].value then
        onCallShuttleTrain(event)
      else
        openDialog(player)
      end
    end
  end
end


--
-- Send the shuttle train next to the player to the depot.
--
-- @param event The event
--
local function onSendShuttleTrainToDepot(event)
  local player = game.players[event.player_index]
  if not player then return end

  local train = findNearbyShuttleTrain(player)
  if not train then
    player.print{"error.noTrainNearby"}
    return
  end

  if #train.passengers > 1 or (#train.passengers == 1 and train.passengers[1] ~= player) then
    player.print{"error.trainNotEmpty"}
  end

  sendTrainToDepot(train, player)
end


--
-- A GUI element was clicked.
--
-- @param event The event containing
--        element :: LuaGuiElement: The clicked element
--        player_index :: uint: The player who did the clicking
--        button :: defines.mouse_button_type: The mouse button used if any
--        alt :: boolean: If alt was pressed
--        control :: boolean: If control was pressed
--        shift :: boolean: If shift was pressed
--
function onGuiClick(event)
  local name = event.element.name
  if name == DIALOG_CLOSE_NAME then
    closeDialog(game.players[event.player_index])
  elseif string.match(name, "^"..DIALOG_STATION_PREFIX) then
    playerClickedStation(game.players[event.player_index], event.element.caption)
  elseif string.match(name, "^"..DIALOG_CATEGORY_PREFIX) then
    global.selectedCategory[event.player_index] = event.element.caption
    updateStationsDialog(game.players[event.player_index])
  end
end


--
-- Called when LuaGuiElement text is changed by the player.
--
-- @param event The event containing
--        element :: LuaGuiElement: The edited element
--        player_index :: uint: The player who did the edit
--        text :: string: The new text in the element
--
function onGuiTextChanged(event)
  if event.element.name == DIALOG_SEARCH then
    updateStationsDialog(game.players[event.player_index])
  end
end


--
-- Register the event callbacks.
--
function registerEvents()
  log("registering events")
  script.on_event(defines.events.on_player_driving_changed_state, onPlayerDrivingChangedState)
  script.on_event(defines.events.on_train_changed_state, onTrainChangedStatus)
  script.on_event(defines.events.on_lua_shortcut, onShortcut)
  script.on_event("call-shuttle-train", onCallShuttleTrain)
  script.on_event("send-shuttle-train-to-depot", onSendShuttleTrainToDepot)
  script.on_event(defines.events.on_gui_click, onGuiClick)
  script.on_event(defines.events.on_gui_text_changed, onGuiTextChanged)
end


--
-- Called every time a save file is loaded except for the instance when a mod is loaded into
-- a save file that it previously wasn't part of. Must not change the game state.
--
script.on_load(function()
  log("loading")
  registerEvents()
  log("loaded")
end)


--
-- Called once when a new save game is created or once when a save file is loaded that previously
-- didn't contain the mod.
--
script.on_init(function()
  log("initializing")
  initGlobalVariables()
  registerEvents()
  log("initialized")
end)


--
-- Called any time the game version changes, prototypes change, startup mod settings change,
-- and any time mod versions change including adding or removing mods.
--
-- @param data The ConfigurationChangedData
--
script.on_configuration_changed(function(data)
  log("configuration changed")
  initGlobalVariables()
  registerEvents()
  log("mod "..script.mod_name.." configuration updated")
end)

