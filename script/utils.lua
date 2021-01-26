-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Create a string for a train reference.
--
-- @param train The LuaTrain to get the reference for
-- @return The generated reference string
--
function trainRef(train)
  if train.valid then
    if train.front_stock and train.front_stock.valid then
      return "[train="..train.front_stock.unit_number.."]"
    end
    return train.backer_name;
  end
  return "<invalid train>"
end


--
-- Create a string for a train station reference.
--
-- @param station The LuaEntity of the train stop to get the reference for
-- @return The generated reference string
--
function stationRef(station)
  if station.valid then
    return "[train-stop="..station.unit_number.."]"
  end
  return "<invalid station>"
end


--
-- Calculate the distance of two LuaControl objects to each other
--
-- @param obj1 The first LuaControl object
-- @param obj2 The second LuaControl object
-- @return The distance between the objects
--
function distance(obj1, obj2)
  return ((obj1.position.x - obj2.position.x) ^ 2 + (obj1.position.y - obj2.position.y) ^ 2) ^ 0.5
end


--
-- Get the localized name for the signal.
--
-- @param id The signal ID to process
-- @return The localized name of the signal
--
function signalIdToLocalName(id)
  if not id or not id.type then return nil end
  if id.type == 'item' then
    return game.item_prototypes[id.name].localised_name
  elseif id.type == 'fluid' then
    return game.fluid_prototypes[id.name].localised_name
  elseif id.type == 'virtual' then
    return game.virtual_signal_prototypes[id.name].localised_name
  end
end

--
-- Convert a SignalID to a string.
--
-- @param id The signal ID to convert
-- @return A string representing the signal
--
function signalIdToStr(id)
  if not id or not id.type then return nil end
  return string.sub(id.type, 1, 1)..'-'..id.name
end

--
-- Convert a signal string to a SignalID.
--
-- @param sigstr The signal string to convert
-- @return The corresponding signal ID
--
function strToSignalId(sigstr)
  if not sigstr then return nil end

  local type = string.sub(sigstr, 1, 1)
  local name = string.sub(sigstr, 3)

  if type == 'i' then
    return { type = 'item', name = name }
  elseif type == 'f' then
    return { type = 'fluid', name = name }
  elseif type == 'v' then
    return { type = 'virtual', name = name }
  end
  log("unknown signal string type '"..type.."'")
  return nil
end

--
-- Convert a signal to a sprite path.
--
-- @param signal The signal to convert
-- @return The sprite path for the signal
--
function signalToSpritePath(signal)
  if not signal then return nil end
  if signal.type == "virtual" then
    return 'virtual-signal/'..signal.name
  else
    return signal.type..'/'..signal.name
  end
end


--
-- A pairs function that iterates over a table using the comparator function.
--
-- If no comparator function is given then the table is sorted by it's keys using
-- LUA's builtin comparator.
--
-- @param t The table to iterate
-- @param comp The function to compare two table entries, optional
-- @return The iterator for the table
-- 
function sortedPairs(t, comp)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if comparator function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if comp then
        table.sort(keys, comp)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


--
-- Split a string.
--
-- @param str The string to split
-- @param sep The separator character
-- @return A table with the splitted parts
--
function strSplit(str, sep)
  local sep, result = sep or ":", {}
  for s in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(result, s)
  end
  return result
end


--
-- Make a simple copy of the targets of a train schedule
--
-- @param records The train schedule records to copy
-- @return A table with the station names / rail entities of the schedule
--
function copyTrainScheduleRecordTargets(records)
  local result = {}
  for _,record in pairs(records) do
    if record.station then
      table.insert(result, record.station)
    elseif record.rail then
      table.insert(result, record.rail)
    end
  end
  return result
end

