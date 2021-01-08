# Overview

This mod allows to do use shuttle trains for personal transportation. These are ordinary
trains that have a special equipment item set into them.

# Features

* works with vanilla and modded trains
* works with any train station
* can pick you up in the wilderness rail

# Equipment

Craft a shuttle train module and place it in the frontmost locomotive of a train. If
you use dual headed trains then the frontmost locomotives at both ends need to have
a shuttle train module.

There is a startup mod setting that ensures that all locomotives have an equipment grid.
This option does not override existing equipment grids, so it should be fine to leave
it turned on.

# Shuttle train interaction

A shuttle train can be called to a train station near you or a straight rail segment
by either clicking the shuttle train shortcut or pressing the call-train keyboard
control (default ctrl-j). When inside a shuttle train locomotive the shortcut / keyboard
control toggles the station selection window.

# Station selection window

The station selection window allows to select the destination. When clicking a train
station the shuttle train takes you there.

On the right side are categories. These categories are automatically populated by
the name of the train stations. At the moment the following pattern is supported:
"[category] station name". You can place an icon to the beginning of the station
name and it will be used as a category. Or simply use some text. See the screenshots
for examples.

The first category button "..." shows all stations.

# Excluding stations

You can configure strings in the mod settings to filter out stations. Stations that
are filtered out are not shown in the station selection window and are not used when
a train is being called.

# After transportation

You can configure what the shuttle train does after transportation. The train can
stay where he is then in either automatic or manual mode, or it can return to the
shuttle train depot. Configure it in the map settings. A personal override is also
possible.

# Shuttle train depot

It is wise to setup a shuttle train depot somewhere, even if you do not use it in
the first place. If a shuttle train cannot reach it's destination it will return
there to avoid causing rail traffic jams.

