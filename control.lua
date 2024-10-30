-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

require "script.constants"
require "script.output"
require "script.settings"
require "script.utils"
require "script.find"
require "script.filter"
require "script.train"
require "script.dialog"
require "script.events"


--
-- Initialize the global variables.
--
function initGlobalVariables()
  log("init storage variables")

  -- The shuttle trains that are currently active.
  -- Key is the LuaTrain::id, value is a structure with:
  --   train The LuaTrain
  --   player The controlling player
  --   status The control status, see the STATUS_xy constants in constants.lua
  --   destinationName The LuaEntity::backer_name of the destination station
  --   timeout The game.tick time when the train's current action times out
  storage.trackedTrains = storage.trackedTrains or {}

  -- The selected station category
  -- Key is the LuaPlayer::id, value is the name of the category.
  storage.selectedCategory = storage.selectedCategory or {}

  -- The history of the selected stations per player.
  -- Key is the LuaPlayer::id, value is a list of the selected stations.
  storage.history = storage.history or {}

  -- The schedule of the train the player is currently configuring.
  -- Key is the LuaPlayer::id, value is a structure with:
  --   id The ID of the LuaTrain
  --   schedule The train's schedule records
  storage.playerTrain = storage.playerTrain or {}
end


--
-- Add the given station to the player's station history, remove the oldest if the
-- list is too long.
--
-- @param player The LuaPlayer
-- @param stationName The name of the station to add
--
local function updateHistory(player, stationName)
  local history = { stationName }
  local maxEntries = settings.get_player_settings(player)["shuttle-train-gui-height"].value
  for _,name in pairs(storage.history[player.index] or {}) do
    if name ~= stationName and #history < maxEntries then
      table.insert(history, name)
    end
  end
  storage.history[player.index] = history
end


--
-- Call a shuttle train for the player
--
-- @param player The LuaPlayer that called for a shuttle train
-- @param station The LuaEntity of the station where the shuttle train shall be sent (optional)
--
function callShuttleTrain(player, station)
  local train = findShuttleTrainFor(player)
  if not train then
    player.print{"error.noTrainFound"}
    return
  end
  if distance(player, train.front_stock) <= SEARCH_RANGE then
    player.print{"info.useTrainNearby"}
    return
  end

  if not station then
    station = findPickupStationFor(player)
  end
  if station then
    updateHistory(player, station.backer_name)
    if train.station == station then
      player.print{"info.pickupTrainAtStation", stationRef(station)}
    else
      player.print{"info.sendPickupTrain", trainRef(train), stationRef(station)}
      sendPickupTrain(train, player, station)
    end
  elseif findNearbyEntity(player, "train-stop") then
    player.print{"error.unsuitableStationFound"}
  else
    local rail = findNearbyEntity(player, "straight-rail")
    if rail then
      player.print{"info.sendPickupTrainToRail", trainRef(train)}
      sendPickupTrain(train, player, rail)
    else
      player.print{"error.noPickupFound"}
    end
  end
end


--
-- Transport the player to the given station using the train the player is in.
--
-- @param player The LuaPlayer that controls the train
-- @param stationName The name of the destination station
--
function playerClickedStation(player, stationName)
  local station = findStationByName(stationName, player)
  if not station then
    log("player selected unknown station "..stationName)
    player.print{"error.unknownStation"}
    return
  end

  if controlsShuttleTrain(player) then
    storage.playerTrain[player.index] = nil
    local train = player.vehicle.train
    if train.station and train.station.backer_name == stationName then
      player.print{"info.alreadyThere", stationRef(station)}
      return
    end
    updateHistory(player, stationName)
    transportTo(train, player, station)
    closeDialog(player)
  elseif not player.vehicle or not player.vehicle.train then
    callShuttleTrain(player, station)
    closeDialog(player)
  end
end


--
-- Called when a player manually changed the schedule of a shuttle train.
--
-- @param player The LuaPlayer who did the change
-- @param train The LuaTrain that was changed
--
function playerChangedTrainSchedule(player, train)
  if not settings.get_player_settings(player)["shuttle-train-smart-manual-destinations"].value then
    return
  end

  local playerTrainInfo = storage.playerTrain[player.index] or {}
  log("player "..player.name.." manually changed schedule of shuttle train #"..tostring(playerTrainInfo.id))

  local oldRecs = playerTrainInfo.schedule or {}
  local dest = findChangedScheduleRecord(oldRecs, (train.schedule or {}).records or {})

  if not dest then
    log("no new train schedule record was added")
    return
  elseif dest.station then
    dest = findStationByName(dest.station, player)
  else
    dest = dest.rail
  end

  log("destination "..tostring(dest))
  transportTo(train, player, dest)
end

