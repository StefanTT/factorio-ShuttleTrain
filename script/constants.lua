-- Copyright (c) 2021 StefanT <stt1@gmx.at>
-- See LICENSE.md in the project directory for license information.


-- The name of the item / equipment
NAME = "shuttle-train"

-- The range when searching for shuttle trains / stations
SEARCH_RANGE = 16

-- The game ticks until an action of a tracked train times out
TRACK_TIMEOUT = 3600*5


--
-- The status for tracked trains:
--
-- The train has been called and is enroute to the pickup station
STATUS_PICKUP = "pickup"
-- The train is transporting somebody to the destination station
STATUS_TRANSPORT = "transport"
-- The train is returning to the depot station
STATUS_DEPOT = "depot"

-- Named GUI elements
DIALOG_NAME = "shuttleTrainDialog"
DIALOG_CLOSE_NAME = DIALOG_NAME.."Close"
DIALOG_SEARCH = DIALOG_NAME.."Search"
DIALOG_STATION_PREFIX = DIALOG_NAME.."Station:"
DIALOG_CATEGORY_PREFIX = DIALOG_NAME.."Category:"

DIALOG_CATEGORY_ALL = "..."

