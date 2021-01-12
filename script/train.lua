-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


local untrack = {
  [defines.train_state.no_schedule] = true,
  [defines.train_state.manual_control] = true,
  [defines.train_state.wait_station] = true,
}


--
-- Test if the train is a shuttle train.
--
-- @param train The train to test
-- @return true if the train is a shuttle train
--
function isShuttleTrain(train)
  if not train.id or not train.front_stock or train.front_stock.type ~= "locomotive" then return false end
  local locomotive = train.front_stock
	if locomotive.valid and locomotive.grid and locomotive.grid.equipment then
		for _, equipment in pairs(locomotive.grid.equipment) do
			if equipment.name == NAME then return true end
		end
	end
	return false
end


--
-- Test if the given player is in a locomotive of a train that has a
-- shuttle train equipment installed
--
-- @param player The player to test
-- @return true / false
--
function controlsShuttleTrain(player)
  local vehicle = player.vehicle
  if vehicle and vehicle.valid and vehicle.train and vehicle.type == "locomotive" then
    return isShuttleTrain(vehicle.train)
  end
  return false
end


--
-- Create a train schedule record for a destination station or rail with optional wait conditions.
--
-- @param destination The LuaEntity of the destination station or rail segment
-- @param waitConditions The wait conditions, may be nil
-- @return The train schedule record
--
local function createScheduleRecord(destination, waitConditions)
  if destination.type == "train-stop" then
    return {station = destination.backer_name, wait_conditions = waitConditions}
  else
    return {rail = destination, temporary = true, wait_conditions = waitConditions}
  end
end

--
-- Send a train to a station to pickup passengers.
--
-- @param train The LuaTrain to send
-- @param player The LuaPlayer that called the train
-- @param destination The LuaEntity of the destination station or rail segment
--
function sendPickupTrain(train, player, destination)
  if not destination.valid then return end

  log("sending shuttle train "..train.front_stock.backer_name.." to "..(destination.backer_name or "rail").." for "..player.name)
  train.manual_mode = true

  local recs = {}

  -- If the destination is a train stop, then we add a temporary record
  -- at the rail where the station is placed. This allows the train to
  -- path to the correct station, in case there are multiple train stops
  -- with the same name.
  if destination.type == "train-stop" then
    table.insert(recs, createScheduleRecord(destination.connected_rail,
      {{ type = "time", compare_type = "and", ticks = 0 -- 0 ticks => temporary stop
      }}))
  end

  -- Next, a record is added for the destination itself (either a train stop, or a rail)
  table.insert(recs, createScheduleRecord(destination,
    {{ type = "passenger_not_present", compare_type = "and" },
     { type = "time", compare_type = "and", ticks = 7200 }}))

  -- Finally, if the player has the appropriate option enabled,
  -- then a record is added to return the train to the depot
  local exitAction = exitActionOf(player)
  if exitAction == "Depot" then
    local depotName = depotNameOf(player)
    if depotName ~= "" then
      table.insert(recs, { station = depotName, wait_conditions =
        {{ type = "circuit", compare_type = "and" }}})
    end
  end

  train.schedule = {
    current = 1,
    records = recs
  }

  train.manual_mode = false
  trackTrain(train, player, destination, STATUS_PICKUP)
end


--
-- Send a train to the depot.
--
-- @param train The LuaTrain to send
-- @param player The LuaPlayer that initiated it
--
function sendTrainToDepot(train, player)
  local depotName = depotNameOf(player)
  local depot = findStationByName(depotName, player)
  if not depot then
    player.print({"error.noDepot", depotName})
    return
  end

  train.manual_mode = true

  if train.station == depot then
    train.schedule = nil
    train.manual_mode = false
  else
    train.schedule = { current = 1, records = {{station = depot.backer_name}}}
    train.manual_mode = false

    trackTrain(train, player, depot, STATUS_DEPOT)
  end
end


--
-- Transport the player to the station.
--
-- @param train The LuaTrain to use
-- @param player The LuaPlayer that initiated it
-- @param destination The LuaEntity of the destination station
--
function transportTo(train, player, destination)
  if not destination.valid then return end

  log("transport via shuttle train "..train.front_stock.backer_name.." to "..destination.backer_name.." for "..player.name)
  train.manual_mode = true

  local exitAction = exitActionOf(player)
  local depotName

  if exitAction == "Depot" then
    depotName = depotNameOf(player)
  end

  if exitAction == "Depot" and depotName ~= "" then
    train.schedule = { current = 1, records = {
      {rail = destination.connected_rail, temporary = true, wait_conditions = {
        {type = "passenger_not_present", compare_type = "and"}}},
      {station = destination.backer_name, wait_conditions = {
        {type = "passenger_not_present", compare_type = "and"},
        {type = "time", compare_type = "and", ticks = 180}}},
      {station = depotName, wait_conditions = {{type = "circuit", compare_type = "and"}}}
    }}
  else
    train.schedule = { current = 1, records = {{station = destination.backer_name}}}
  end

  train.manual_mode = false
  trackTrain(train, player, destination, STATUS_TRANSPORT)
end


--
-- Control all tracked trains.
--
function onTrackedTrainControlTimer()
  log("control tracked trains")
  for id,track in pairs(global.trackedTrains) do
    local train = track.train
    if not train.valid or untrack[train.state] then
      untrackTrain(train, id)
      return -- avoid problems because we modified global.trackedTrains
    end
  end
end


--
-- Called when the status of a tracked train changed.
--
-- @param train The tracked LuaTrain that changed status
--
function onTrackedTrainChangedStatus(train)
  local track = global.trackedTrains[train.id]
  local status = train.state
  if status == defines.train_state.wait_station then
    if train.station and train.station.backer_name == track.destinationName then
      untrackTrain(train)
      if track.status == STATUS_TRANSPORT and exitActionOf(track.player) == "Manual" then
        train.manual_mode = true
      end
    end
  elseif status == defines.train_state.no_path or status == defines.train_state.path_lost then
    untrackTrain(train)
    trackedTrainLostPath(train, track.player, track.destinationName, track.status)
  end
end


--
-- Called when a tracked train lost it's path.
--
-- @param train The LuaTrain to track
-- @param player The controlling player
-- @param destinationName The name of the destination station
-- @param status The tracking status of the train
--
function trackedTrainLostPath(train, player, destinationName, status)
  if player.valid then
    player.print({"error.trainLostPath", destinationName})
  end

  if #train.passengers > 0 then return end

  local depotName = depotNameOf(player)
  if depotName == destinationName then
    player.print({"info.fixTrain"})
    return
  end

  local depot = findStationByName(depotName, player)
  if not depot then
    player.print({"info.fixTrain"})
    player.print({"info.fixTrainHint"})
    return
  end

  player.print({"info.fixTrainDepot"})
  sendTrainToDepot(train, player)
end


--
-- Begin tracking a train
--
-- @param train The LuaTrain to track
-- @param player The controlling player
-- @param destination The destination station
-- @param status The tracking status of the train
--
function trackTrain(train, player, destination, status)
  if not next(global.trackedTrains) then
    log("registering timer for train tracking")
    script.on_nth_tick(nil)
    script.on_nth_tick(617, onTrackedTrainControlTimer)
  end

  log("start tracking train #"..train.id)
  global.trackedTrains[train.id] = { train = train, player = player, status = status,
    destinationName = destination.backer_name, timeout = game.tick + TRACK_TIMEOUT}
end


--
-- Stop tracking a train
--
-- @param train The LuaTrain to stop tracking
-- @param id The ID of the train (optional)
--
function untrackTrain(train, id)
  if not id then id = train.id end
  global.trackedTrains[id] = nil
  log("stop tracking train #"..id)

  if not next(global.trackedTrains) then
    log("unregistering timer for train tracking")
    script.on_nth_tick(nil)
  end
end

