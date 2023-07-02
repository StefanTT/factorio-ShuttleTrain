

data.raw["gui-style"].default["shuttle_train_tool_button"] =
{
  type = "button_style",
  parent = "tool_button",
  padding = 0,
  size = 28,
};

data.raw["gui-style"].default["shuttle_train_highlighted_tool_button"] =
{
  type = "button_style",
  parent = "shuttle_train_tool_button",
  default_graphical_set =
  {
    base = {position = {34, 17}, corner_size = 8},
    shadow = default_dirt,
    glow = default_glow(default_glow_color, 0.5)
  }
};

