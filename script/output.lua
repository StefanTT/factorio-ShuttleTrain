-- Copyright (c) 2019 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


-- Write a message to the console of everybody or all members of a force
-- @param msg The message to write
-- @param force The force to write to, nil to write to everybody
function printForce(msg, force)
  if force and force.valid then
    force.print{msg}
  else
    game.print{msg}
  end
  log(msg)
end

