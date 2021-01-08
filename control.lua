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
  log("init global variables")

  -- The shuttle trains that are currently active.
  -- Key is the LuaTrain::id, value is a structure with:
  --   train The LuaTrain
  --   player The controlling player
  --   status The control status, see the STATUS_xy constants in constants.lua
  --   destinationName The LuaEntity::backer_name of the destination station
  --   timeout The game.tick time when the train's current action times out
  global.trackedTrains = global.trackedTrains or {}

  -- The selected station category
  -- Key is the LuaPlayer::id, value is the name of the category
  global.selectedCategory = global.selectedCategory or {}
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
    if train.station == station then
      player.print{"info.pickupTrainAtStation", station.backer_name}
    else
      player.print{"info.sendPickupTrain", station.backer_name}
      sendPickupTrain(train, player, station)
    end
  elseif findNearbyEntity(player, "train-stop") then
    player.print{"error.unsuitableStationFound"}
  else
    local rail = findNearbyEntity(player, "straight-rail")
    if rail then
      player.print{"info.sendPickupTrainToRail"}
      sendPickupTrain(train, player, rail)
    else
      player.print{"error.noPickupFound"}
    end
  end
end


--
-- Transport the player to the given station using the train the player is in
--
-- @param player The LuaPlayer that controls the train
-- @param stationName The name of the destination station
--
function playerClickedStation(player, stationName)
    local station = findStationByName(stationName, player)
    if not station then
      log("player selected unknown station "..event.element.caption)
      player.print{"error.unknownStation"}
      return
    end

    if controlsShuttleTrain(player) then
      local train = player.vehicle.train
      if train.station and train.station.backer_name == stationName then
        player.print{"info.alreadyThere", stationName}
        return
      end
      transportTo(train, player, station)
      closeDialog(player)
    elseif not player.vehicle or not player.vehicle.train then
      callShuttleTrain(player, station)
      closeDialog(player)
    end
end

