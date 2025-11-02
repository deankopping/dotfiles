local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.window_decorations = "RESIZE"
config.color_scheme = "Gruvbox Dark (Gogh)"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.window_frame = {
	font = wezterm.font({ family = "Roboto", weight = "DemiBold" }),
	font_size = 12.0,
}
config.colors = {
	tab_bar = {
		-- The color of the inactive tab bar edge/divider
		inactive_tab_edge = "#575757",
	},
}
config.keys = {
	{
		key = "LeftArrow",
		mods = "CMD",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "RightArrow",
		mods = "CMD",
		action = wezterm.action.ActivateTabRelative(1),
	},
}

wezterm.on("format-tab-title", function(tab)
	local process = tab.active_pane.foreground_process_name
	local is_nvim = process and process:find("nvim")

	-- Get just the last part of the path or process name
	local title = tab.active_pane.title
	title = title:match("([^/]+)$") or title

	local fixed_width = 35
	-- Center the title
	local padding = math.floor((fixed_width - #title) / 2)
	local left_pad = string.rep(" ", padding)
	local right_pad = string.rep(" ", fixed_width - #title - padding)
	title = left_pad .. title .. right_pad --

	if tab.is_active then
		return {
			{ Background = { Color = "#1F1F28" } },
			{ Foreground = { Color = "#ffffff" } },
			{ Text = title },
		}
	elseif is_nvim then
		return {
			{ Background = { Color = "#b45309" } },
			{ Foreground = { Color = "#ffffff" } },
			{ Text = title },
		}
	else
		return {
			{ Background = { Color = "None" } },
			{ Foreground = { Color = "#a89984" } },
			{ Text = title },
		}
	end
end)

return config
