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

-- Steps delta tabs from the focused one within the focused workspace,
-- wrapping at both ends.
local function herdr_tab_id_by_offset(delta)
  local snap = herdr_snapshot()
  if not snap or not snap.focused_workspace_id then return nil end
  local ordered = {}
  for _, t in ipairs(snap.tabs or {}) do
    if t.workspace_id == snap.focused_workspace_id then
      table.insert(ordered, t)
    end
  end
  if #ordered < 2 then return nil end
  local current
  for i, t in ipairs(ordered) do
    if t.tab_id == snap.focused_tab_id then current = i end
  end
  if not current then return nil end
  local target = ((current - 1 + delta) % #ordered) + 1
  return ordered[target].tab_id
end

-- Steps delta workspaces from the focused one in snapshot list order,
-- wrapping at both ends. Uses list position rather than workspace.number,
-- which is a persistent counter that drifts from on-screen order.
local function herdr_workspace_id_by_offset(delta)
  local snap = herdr_snapshot()
  if not snap or not snap.focused_workspace_id then return nil end
  local ordered = snap.workspaces or {}
  if #ordered < 2 then return nil end
  local current
  for i, w in ipairs(ordered) do
    if w.workspace_id == snap.focused_workspace_id then current = i end
  end
  if not current then return nil end
  local target = ((current - 1 + delta) % #ordered) + 1
  return ordered[target].workspace_id
end

-- Picks the agent pane most likely to want attention: the most recently
-- changed blocked agent, else the most recently changed idle one. Skips the
-- pane already focused. herdr's own prefix+o (open_notification_target)
-- depends on its notification queue, which never populates here, so this
-- derives the target from agent state directly instead.
local function herdr_attention_pane()
  local snap = herdr_snapshot()
  if not snap then return nil end
  local best, best_rank
  for _, a in ipairs(snap.agents or {}) do
    local rank
    if a.agent_status == 'blocked' then
      rank = 2
    elseif a.agent_status == 'idle' then
      rank = 1
    end
    if rank and not a.focused then
      local seq = a.state_change_seq or 0
      if not best
        or rank > best_rank
        or (rank == best_rank and seq > (best.state_change_seq or 0)) then
        best, best_rank = a, rank
      end
    end
  end
  return best and best.pane_id or nil
end

config.keys = {
  -- Clears the scrollback and viewport. Inert inside herdr, which owns and
  -- redraws that screen itself: clearing wezterm's buffer underneath it
  -- corrupts the rendering, and it is not the `clear` it looks like.
  {
    key = 'K',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      if not pane_is_herdr(pane) then
        window:perform_action(act.ClearScrollback 'ScrollbackAndViewport', pane)
      end
    end),
  },
  {
    key = 'k',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if not pane_is_herdr(pane) then
        window:perform_action(act.ClearScrollback 'ScrollbackAndViewport', pane)
      end
    end),
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
  -- Cycle tabs within the focused workspace, wrapping at both ends.
  {
    key = 'LeftArrow',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local target = herdr_tab_id_by_offset(-1)
        if target then
          wezterm.background_child_process({ HERDR, 'tab', 'focus', target })
        end
      else
        window:perform_action(act.ActivateTabRelative(-1), pane)
      end
    end),
  },
  {
    key = 'RightArrow',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local target = herdr_tab_id_by_offset(1)
        if target then
          wezterm.background_child_process({ HERDR, 'tab', 'focus', target })
        end
      else
        window:perform_action(act.ActivateTabRelative(1), pane)
      end
    end),
  },
  -- Cycle workspaces, wrapping at both ends. Vertical to match herdr's
  -- sidebar layout, where workspaces stack top to bottom.
  {
    key = 'UpArrow',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local target = herdr_workspace_id_by_offset(-1)
        if target then
          wezterm.background_child_process({ HERDR, 'workspace', 'focus', target })
        end
      end
    end),
  },
  {
    key = 'DownArrow',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local target = herdr_workspace_id_by_offset(1)
        if target then
          wezterm.background_child_process({ HERDR, 'workspace', 'focus', target })
        end
      end
    end),
  },
  -- Jump to the agent pane wanting attention, blocked first then idle.
  {
    key = 'o',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local target = herdr_attention_pane()
        if target then
          wezterm.background_child_process({ HERDR, 'agent', 'focus', target })
        end
      end
    end),
  },
  -- New herdr workspace. herdr also binds this natively as ctrl+b Shift+N.
  {
    key = 't',
    mods = 'CTRL|SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        wezterm.background_child_process({ HERDR, 'workspace', 'create', '--focus' })
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

-- Vim-style pane focus within herdr. Lowercase keys with SHIFT|SUPER, matching
-- the existing split_vertical binding; letters don't suffer the shifted-glyph
-- remapping that rules SHIFT out for digits.
for key, direction in pairs({ h = 'left', j = 'down', k = 'up', l = 'right' }) do
  table.insert(config.keys, {
    key = key,
    mods = 'SHIFT|SUPER',
    action = wezterm.action_callback(function(window, pane)
      if pane_is_herdr(pane) then
        local f = herdr_focused()
        if f then
          wezterm.background_child_process(
            { HERDR, 'pane', 'focus', '--pane', f.pane_id, '--direction', direction })
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
