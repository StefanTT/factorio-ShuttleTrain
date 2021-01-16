-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

local ignoredStates = {
  [defines.train_state.on_the_path] = true,
  [defines.train_state.arrive_signal] = true,
  [defines.train_state.wait_signal] = true,
  [defines.train_state.arrive_station] = true,
}

--
-- Returns the next rail in front of a specified train.
-- May return nil if there is no such rail.
--
-- @param train :: LuaTrain: The train
--
local function getNextRailForTrain(train)
  if not train.front_rail then
    return nil
  end

  local cdirs = {
    defines.rail_connection_direction.straight,
    defines.rail_connection_direction.left,
    defines.rail_connection_direction.right
  }

  for _,v in ipairs(cdirs) do
    local next_rail = train.front_rail.get_connected_rail{ rail_direction=train.rail_direction_from_front_rail, rail_connection_direction=v }
    if next_rail then
      return next_rail
    end
  end

  return train.front_rail
end

--
-- Called when the player's driving state has changed, this means a player has either entered or left a vehicle.
--
-- @param event The event containing
--        player_index :: uint
--        entity :: LuaEntity (optional): The vehicle (if any)
--
local function onPlayerDrivingChangedState(event)
  if not event.entity or not event.entity.valid then return end

  local train = event.entity.train
  local player = game.players[event.player_index]
  if not player then return end

  if player.vehicle then
    if controlsShuttleTrain(player) then
      log("player "..player.name.." entered shuttle train "..train.front_stock.backer_name)
      openDialog(player)
      if #train.passengers == 1 then
        train.schedule = nil
        untrackTrain(train)
      end
    end
  else
    if train and isShuttleTrain(train) then
      log("player "..player.name.." exited shuttle train "..train.front_stock.backer_name)
      closeDialog(player)
      if #train.passengers == 0 then
        log("shuttle train finished transportation")
        untrackTrain(train)

        if exitActionOf(player) == "Automatic" then
          log("exit action: wait for the player to return, and return to the depot after some time")
          -- It is necessary to use the next rail instead of the current rail here.
          -- Otherwise, the train will loop back around the track in order to reach its current position.

          local target_rail = getNextRailForTrain(train)
          if target_rail then
            sendPickupTrain(train, player, target_rail)
          else
            log("warning: the target rail of shuttle train "..train.front_stock.backer_name.." is nil! falling back to generic exit action (which will probably fail to find a path)")

            sendTrainToDepot(train, player)
          end
        elseif exitActionOf(player) == "Depot" then
          log("exit action: order train back to depot immediately")

          sendTrainToDepot(train, player)
        elseif exitActionOf(player) == "Manual" then
          log("exit action: switch train to manual mode")

          train.manual_mode = true
        end
      end
    end
  end
end


--
-- Called when a train changes status (started to stopped and vice versa).
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
  -- Close the station selection dialog when the train is switched to manual control
  if train.state == defines.train_state.manual_control then
    for _,player in pairs(game.players) do
      if controlsShuttleTrain(player) and player.vehicle.train == event.train then
        closeDialog(player)
      end
    end
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
--  Called when the player opens a GUI.
--
-- @param event The event containing:
--        player_index :: uint: The player
--        gui_type :: defines.gui_type: The GUI type that was opened
--        entity :: LuaEntity (optional): The entity that was opened
--        item :: LuaItemStack (optional): The item that was opened
--        equipment :: LuaEquipment (optional): The equipment that was opened
--        other_player :: LuaPlayer (optional): The other player that was opened
--        element :: LuaGuiElement (optional): The custom GUI element that was opened
--
function onGuiOpened(event)
  -- Close the station selection dialog when the player opens a locomotive of the train he is sitting in
  if event.gui_type == defines.gui_type.entity then
    local player = game.players[event.player_index]
    if event.entity.train and player and player.vehicle and player.vehicle.train == event.entity.train then
      closeDialog(player)
    end
  end
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
  script.on_event(defines.events.on_gui_opened, onGuiOpened)
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

