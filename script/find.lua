-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.

local available = {
  [defines.train_state.no_schedule] = true,
  [defines.train_state.manual_control] = true,
  [defines.train_state.wait_station] = true,
}


--
-- Find the nearest available shuttle train that can transport the player.
--
-- @param player The player to find a train for
-- @return The found LuaTrain or nil if no train is available
--
function findShuttleTrainFor(player)
  local px = player.position.x
  local py = player.position.y
  local matchDistance = nil
  local match = nil

  local ignoreManual = settings.global['shuttle-train-global-ignore-manual-trains'].value
  
	for _,train in next, game.train_manager.get_trains({ surface = player.physical_surface }) do
    if available[train.state] and #train.passengers == 0 and isAutomaticShuttleTrain(train) and
      (not ignoreManual or train.state ~= defines.train_state.manual_control) then

      local distance = (train.front_stock.position.x - px) ^ 2 + (train.front_stock.position.y - py) ^ 2
      if not matchDistance or distance < matchDistance then
        matchDistance = distance
        match = train
      end
    end
  end
  return match
end


--
-- Find the nearest available shuttle train.
-- Searches only in the vicinity of the player.
--
-- @param player The LuaPlayer to find the train for
-- @return The found LuaTrain or nil of none
--
function findNearbyShuttleTrain(player)
  local px = player.position.x
  local py = player.position.y
  local matchDistance = nil
  local match = nil
  local range = SEARCH_RANGE

  local locos = player.surface.find_entities_filtered({type = "locomotive", force = player.force,
    area = {{x = px - range, y = py - range}, {x = px + range, y = py + range}} })

	for _,loco in ipairs(locos) do
	  local train = loco.train
    if available[train.state] and isAnyShuttleTrain(train) then
      local distance = (train.front_stock.position.x - px) ^ 2 + (train.front_stock.position.y - py) ^ 2
      if not matchDistance or distance < matchDistance then
        matchDistance = distance
        match = train
      end
    end
  end
  return match
end


--
-- Find the nearest station that is suitable for sending a shuttle train to.
--
-- @param player The player to find a station for
-- @return The found LuaEntity of the station or nil if none was found
--
function findPickupStationFor(player)
  local px = player.position.x
  local py = player.position.y
  local matchDistance = nil
  local match = nil
  local range = SEARCH_RANGE

  local filterFunc = createStationExcludeFilter(player)

  local stations = player.surface.find_entities_filtered({type = "train-stop", force = player.force,
    area = {{x = px - range, y = py - range}, {x = px + range, y = py + range}} })

  for _,station in ipairs(stations) do
    if not filterFunc(station.backer_name) then
      local distance = (station.position.x - px) ^ 2 + (station.position.y - py) ^ 2
      if not matchDistance or distance < matchDistance then
        matchDistance = distance
        match = station
      end
    end
  end
  return match
end


--
-- Find the entity of the given type that is nearest to the player
--
-- @param player The player to find for
-- @param entityType The entity type to find
-- @return The found LuaEntity or nil if none was found
--
function findNearbyEntity(player, entityType)
  local px = player.position.x
  local py = player.position.y
  local matchDistance = nil
  local match = nil
  local range = SEARCH_RANGE

  local rails = player.surface.find_entities_filtered({type = entityType,
    area = {{x = px - range, y = py - range}, {x = px + range, y = py + range}} })

  for _,rail in ipairs(rails) do
    local distance = (rail.position.x - px) ^ 2 + (rail.position.y - py) ^ 2
    if not matchDistance or distance < matchDistance then
      matchDistance = distance
      match = rail
    end
  end
  return match
end


--
-- Find a train station by name for a player.
--
-- @param name The name of the station to find
-- @param player The LuaPlayer to search for
-- @return The LuaEntity of the train stop, nil if not found
--
function findStationByName(name, player)
  local stations = player.surface.find_entities_filtered({type = "train-stop", force = player.force})
  for _,station in ipairs(stations) do
    if station.backer_name == name then
      return station
    end
  end
  return nil
end


--
-- Find the first difference in the two given lists of train schedule records.
--
-- @param oldRecs The old records
-- @param newRecs The new records
-- @return The first entry of newRecs that is different from the entry in oldRecs with the same index, nil if none
--
function findChangedScheduleRecord(oldRecs, newRecs)
  for i = 1,math.max(#oldRecs, #newRecs) do
    if i > #oldRecs then
      return newRecs[i]
    elseif i > #newRecs then
      return nil
    else
      local oldRec = oldRecs[i]
      local newRec = newRecs[i]
      if oldRec ~= newRec.station and oldRec ~= newRec.rail then
        return newRec
      end
    end
  end
  return nil
end

