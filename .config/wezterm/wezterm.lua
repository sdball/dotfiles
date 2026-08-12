local wezterm = require 'wezterm';
local config = wezterm.config_builder()
local act = wezterm.action

config.keys = {
  -- Clears the scrollback and viewport
  {
    key = 'K',
    mods = 'CTRL|SHIFT',
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
  {
    key = 'k',
    mods = 'SUPER',
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
  {
    key = 'd',
    mods = 'SUPER',
    action = act.SplitHorizontal
  },
  {
    key = 'd',
    mods = 'SHIFT|SUPER',
    action = act.SplitVertical
  },
  -- Reads the current selection aloud via macOS say
  {
    key = 'S',
    mods = 'SHIFT|SUPER',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and #sel > 0 then
        wezterm.background_child_process(
          { os.getenv('HOME') .. '/bin/speak', sel })
      end
    end),
  },
  -- Stops narration
  {
    key = '>',
    mods = 'SHIFT|SUPER',
    action = wezterm.action_callback(function()
      wezterm.background_child_process(
        { os.getenv('HOME') .. '/bin/speak', '--stop' })
    end),
  },
}

config.font = wezterm.font("UbuntuMono Nerd Font")
config.font_size = 26.0
config.color_scheme = '3024 (base16)'
config.window_background_opacity = 0.98
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

return config
