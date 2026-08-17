local wezterm = require 'wezterm';
local config = wezterm.config_builder()
local act = wezterm.action

local HERDR = '/opt/homebrew/bin/herdr'

local function pane_is_herdr(pane)
  local info = pane:get_foreground_process_info()
  return info ~= nil and info.name == 'herdr'
end

-- A process launched via wezterm.background_child_process doesn't inherit
-- the HERDR_*_ID env vars a real herdr-managed shell gets, so resolve the
-- focused workspace/tab/pane ids from the live snapshot instead.
local function herdr_snapshot()
  local success, stdout = wezterm.run_child_process({ HERDR, 'api', 'snapshot' })
  if not success then return nil end
  local ok, parsed = pcall(wezterm.json_parse, stdout)
  if not ok then return nil end
  return parsed.result and parsed.result.snapshot
end

local function herdr_focused()
  local snap = herdr_snapshot()
  if not snap or not snap.focused_pane_id then return nil end
  return {
    workspace_id = snap.focused_workspace_id,
    tab_id = snap.focused_tab_id,
    pane_id = snap.focused_pane_id,
  }
end

-- Finds the tab_id for the Nth visible tab within the currently focused
-- workspace. Matches by position in snapshot.tabs (herdr has no tab-reorder
-- command, so list order tracks on-screen left-to-right order) rather than
-- label, so renaming a tab doesn't break its Cmd+N slot.
local function herdr_tab_id_for_number(number)
  local snap = herdr_snapshot()
  if not snap or not snap.focused_workspace_id then return nil end
  local position = 0
  for _, t in ipairs(snap.tabs or {}) do
    if t.workspace_id == snap.focused_workspace_id then
      position = position + 1
      if position == number then
        return t.tab_id
      end
    end
  end
  return nil
end

-- Finds the workspace_id for the Nth workspace, matching the number herdr's
-- own ctrl-b,w,<N> switcher uses.
local function herdr_workspace_id_for_number(number)
  local snap = herdr_snapshot()
  if not snap then return nil end
  for _, w in ipairs(snap.workspaces or {}) do
    if w.number == number then
      return w.workspace_id
    end
  end
  return nil
end

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
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local f = herdr_focused()
        if f then
          wezterm.background_child_process(
            { HERDR, 'pane', 'split', '--pane', f.pane_id, '--direction', 'right', '--focus' })
        end
      else
        window:perform_action(act.SplitHorizontal, pane)
      end
    end),
  },
  {
    key = 'd',
    mods = 'SHIFT|SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local f = herdr_focused()
        if f then
          wezterm.background_child_process(
            { HERDR, 'pane', 'split', '--pane', f.pane_id, '--direction', 'down', '--focus' })
        end
      else
        window:perform_action(act.SplitVertical, pane)
      end
    end),
  },
  {
    key = 't',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local f = herdr_focused()
        if f then
          wezterm.background_child_process(
            { HERDR, 'tab', 'create', '--workspace', f.workspace_id, '--focus' })
        end
      else
        window:perform_action(act.SpawnTab 'CurrentPaneDomain', pane)
      end
    end),
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

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local tab_id = herdr_tab_id_for_number(i)
        if tab_id then
          wezterm.background_child_process({ HERDR, 'tab', 'focus', tab_id })
        end
      else
        window:perform_action(act.ActivateTab(i - 1), pane)
      end
    end),
  })
  -- Switch herdr workspaces (no non-herdr default; herdr's own ctrl-b,w,<N>
  -- switcher is the only thing this number/mods combo maps to today).
  -- CTRL|SUPER instead of SHIFT|SUPER: shift remaps digits to their shifted
  -- glyph (!, @, #, ...) before wezterm sees them, so the binding never fires.
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local workspace_id = herdr_workspace_id_for_number(i)
        if workspace_id then
          wezterm.background_child_process({ HERDR, 'workspace', 'focus', workspace_id })
        end
      end
    end),
  })
end

config.font = wezterm.font("UbuntuMono Nerd Font")
config.font_size = 26.0
config.color_scheme = '3024 (base16)'
config.window_background_opacity = 0.98
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

return config
