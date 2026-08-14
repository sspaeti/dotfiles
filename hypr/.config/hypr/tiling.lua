-- CUSTOM TILING SHORTCUTS
--
-- Converted 1:1 from the old tiling.conf. That file was sourced by the old
-- hyprland.conf but had no Lua counterpart, so none of it was active after the
-- Quattro upgrade -- this is why SUPER+Q stopped closing windows.
--
-- Loaded from hyprland.lua AFTER hypr.bindings, so it wins on shared keys.

-- Close window
hl.unbind("SUPER + W") -- Quattro default: Close active window (moved to SUPER+Q here)
o.bind("SUPER + Q", "Close active window", hl.dsp.window.close())

-- Control tiling
hl.unbind("SUPER + P") -- default: Pseudo window
-- hl.unbind("SUPER + V")
--   NOTE: left commented on purpose. In the old Omarchy, SUPER+V was the
--   clipboard picker and you cleared it. In Quattro, SUPER+V is "Universal
--   paste" (it translates to CTRL+V / SHIFT+Insert depending on the window).
--   Uncomment if you really want the key free again.
hl.unbind("SUPER + I")
o.bind("SUPER + I", "Toggle window split", hl.dsp.layout("togglesplit")) -- dwindle
o.bind("SUPER + P", "Pseudo window", hl.dsp.window.pseudo()) -- dwindle
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
hl.unbind("SUPER + SHIFT + P") -- default: Google Photos
o.bind("SUPER + SHIFT + P", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")

-- Move focus with mainMod + vim keys
hl.unbind("SUPER + H")
hl.unbind("SUPER + L") -- default: Toggle workspace layout
hl.unbind("SUPER + J") -- default: Toggle window split
hl.unbind("SUPER + K") -- default: Keybindings
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- Swap active window with mainMod + SHIFT + arrow keys
-- Cycle through applications with ALT + Tab
-- Scroll through workspaces with mainMod + scroll
-- Move/resize windows with mainMod + LMB/RMB and dragging
--   All of the above are already Omarchy Quattro defaults, bound identically in
--   $OMARCHY_PATH/default/hypr/bindings/tiling.lua. Re-binding them here would
--   only create duplicate entries, so they are intentionally left out.

-- vim swap
o.bind("SUPER + CTRL + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + CTRL + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + CTRL + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Resize active window
o.bind("SUPER + SHIFT + H", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + SHIFT + L", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("SUPER + SHIFT + K", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("SUPER + SHIFT + J", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- New Grouping feature

-- Toggle groups
hl.unbind("SUPER + SHIFT + G") -- default: Signal
o.bind("SUPER + SHIFT + G", "Toggle window grouping", hl.dsp.group.toggle())
-- The old config bound SUPER+SHIFT+G a second time to moveoutofgroup. Hyprland
-- only ever fires the first binding for a key, so that line never ran. Omarchy's
-- default for it is SUPER+ALT+G, which is still available.
-- o.bind("SUPER + SHIFT + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))

-- Join groups
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
hl.unbind("SUPER + ALT + K") -- default: Tmux keybindings
o.bind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
