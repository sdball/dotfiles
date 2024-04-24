local wezterm = require 'wezterm';
local config = wezterm.config_builder()
local act = wezterm.action

config.keys = {
  -- Clears the scrollback and viewport, and then sends CTRL-L to ask the
  -- shell to redraw its prompt
  {
    key = 'K',
    mods = 'CTRL|SHIFT',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },
  {
    key = 'k',
    mods = 'SUPER',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },
}

config.font = wezterm.font("UbuntuMono Nerd Font")
config.font_size = 26.0
config.color_scheme = '3024 (base16)'
config.window_background_opacity = 0.98
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

return config
