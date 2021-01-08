-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Create a station filter function for a player
--
-- @param player The LuaPlayer to create the filter for
-- @return The station filter which returns true if the given string shall be filtered, false if not
--
function createStationFilter(player)
  local excludes = {}
  for exclude in string.gmatch(stationExcludesOf(player) or "", "[^,]+") do
    table.insert(excludes, exclude:lower())
  end

  return function(name)
    for _,exclude in ipairs(excludes) do
      if string.find(name, exclude, 1, true) then
        return true
      end
    end
    return false
  end
end

