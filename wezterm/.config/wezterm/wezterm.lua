local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- or, changing the font size and color scheme.

config.window_decorations = "RESIZE"

-- Finally, return the configuration to wezterm:
return config
