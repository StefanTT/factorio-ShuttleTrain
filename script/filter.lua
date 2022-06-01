-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Create a station filter function for a player. Resulting function performs case-insensitive filtering.
--
-- @param player The LuaPlayer to create the filter for
-- @return The station filter which returns true if the given string shall be filtered, false if not
--
function createStationExcludeFilter(player)
  local excludes = {}
  for exclude in string.gmatch(stationExcludesOf(player) or "", "[^,]+") do
    table.insert(excludes, exclude:lower())
  end

  local invert = stationExcludesInvertOf(player)

  return function(name)
    name = name:lower()
    for _,exclude in ipairs(excludes) do
      local found = string.find(name, exclude, 1, true) ~= nil
      if found ~= invert then
        return true
      end
    end
    return false
  end
end


--
-- Create a station filter when searching for a station in the dialog.
--
-- @param layer The LuaPlayer to create the filter for
-- @param search The search string the player has entered into the search field
-- @return The station filter which returns true if the given station shall be included in the result, false if not
--
function createSearchFilter(player, search)

  local ignoreItems = settings.get_player_settings(player)["shuttle-train-search-ignore-items"].value
  local pattern

  if search == "" or search == nil then
    -- empty search string
    pattern = ".*"
  elseif search:find(" ") ~= nil then
    -- use word based search, e.g. "ho sta" for "my home station"
    pattern = ""
    for word in search:gmatch("%w+") do
      pattern = pattern..word:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1").."[^%s]*%s+"
    end
    pattern = pattern:gsub("%%s%+$", "")
  else
    -- use one letter per word based search, e.g. "mh" for "my home station"
    pattern = ""
    for i = 1,search:len() do
      pattern = pattern..search:sub(i, i):gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1").."[^%s]*%s+"
    end
    pattern = pattern:gsub("%%s%+$", "")
  end

  return function(name)
    name = name:lower()

    local nameWithoutItems = name:gsub("%[[%-%a]+=[^%]]+%]", "")
    if ignoreItems then
      name = nameWithoutItems
    else
      -- only remove category item (if present)
      name = name:gsub("^%[[%-%a]+=[^%]]+%]", "")
    end

    if string.find(name, search, 1, true) then
      return true
    end
    return nameWithoutItems:match(pattern) ~= nil
  end

end

