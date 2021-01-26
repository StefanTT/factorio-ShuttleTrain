-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


--
-- Get the exit action of a player. Uses the player's setting and if it
-- is unset then the map setting is returned.
--
-- @param player The player to get it for
-- @return The configured value
--
function exitActionOf(player)
  local v = settings.get_player_settings(player)["shuttle-train-exit-action"].value
  if v and v ~= "" then return v end
  return settings.global["shuttle-train-global-exit-action"].value or ""
end


--
-- Get the shuttle train depot name of a player. Uses the player's setting and if it
-- is unset then the map setting is returned.
--
-- @param player The player to get it for
-- @return The configured value
--
function depotNameOf(player)
  local v = settings.get_player_settings(player)["shuttle-train-depot"].value
  if v and v ~= "" then return v end
  return settings.global["shuttle-train-global-depot"].value or ""
end


--
-- Get the station exclusion settings of a player.
--
-- @param player The player to get it for
-- @return The configured value
--
function stationExcludesOf(player)
  local v = settings.get_player_settings(player)["shuttle-train-exclude"].value
  if v and v ~= "" then return v end
  return settings.global["shuttle-train-global-exclude"].value or ""
end


--
-- Get the station exclusion invert flag settings of a player.
--
-- @param player The player to get it for
-- @return The configured value
--
function stationExcludesInvertOf(player)
  local v = settings.get_player_settings(player)["shuttle-train-exclude"].value
  if v and v ~= "" then
    return settings.get_player_settings(player)["shuttle-train-exclude-invert"].value
  end
  return settings.global["shuttle-train-global-exclude-invert"].value
end

