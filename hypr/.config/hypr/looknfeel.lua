-- Change the default Omarchy look'n'feel.
-- Converted 1:1 from the old looknfeel.conf.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows
    gaps_in = 2, -- 1.8
    gaps_out = 0,

    border_size = 1,

    -- Use master layout instead of dwindle
    -- layout = "master",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--   },
-- })

-- animations:enabled = yes, please :)
hl.config({
  animations = {
    enabled = true,
  },
})

-- --------WINDOWS-------------------
--
-- Just dash of opacity.
-- Omarchy tags every window "+default-opacity" and lets apps opt out with
-- "-default-opacity" (media players, etc). Targeting the tag instead of ".*"
-- keeps those opt-outs working while still overriding Omarchy's own value,
-- because this file loads after the defaults.
o.window({ tag = "default-opacity" }, { opacity = "0.99 0.98 1.0" })
o.window("^(Chromium|chromium|google-chrome|google-chrome-unstable)$", { opacity = "1 0.99 1.0" })

-- Clipboard -floating
o.window("(clipse)", { name = "windowrule-ssp-3", float = true }) -- ensure you have a floating window class set if you want this behavior
o.window("(clipse)", { name = "windowrule-ssp-4", size = { 622, 652 } }) -- set the size of the window as necessary

-- Image browser -floating
o.window({ title = "(Screenshot Browser)" }, { name = "windowrule-ssp-5", float = true }) -- ensure you have a floating window class set if you want this behavior
o.window({ title = "(Screenshot Browser)" }, { name = "windowrule-ssp-6", size = { 1200, 800 } }) -- set the size of the window as necessary

-- floating Screenshot: larger than default - override omarchy default
o.window("^(com.gabm.satty)$", { name = "windowrule-ssp-7", size = { 1200, 800 } })

o.window("^(io.ente.auth)$", { name = "windowrule-ssp-8", no_screen_share = true })
o.window("^(io.ente.auth)$", { tag = "+floating-window" })

-- Evince PDF viewer: remove from default floating-window tag and set larger size
o.window("^(org\\.gnome\\.Evince)$", { tag = "-floating-window" })
o.window("^(org\\.gnome\\.Evince)$", { float = true })
o.window("^(org\\.gnome\\.Evince)$", { center = true })
o.window("^(org\\.gnome\\.Evince)$", { size = { 1300, 900 } })

-- Untag btop from omarchy's `floating-window` rule so Activity tiles like before the recent update.
-- Default rule lives in $OMARCHY_PATH/default/hypr/apps/system.lua (size 875 600 was too cramped).
o.window("^(org\\.omarchy\\.btop)$", { tag = "-floating-window" })

-- Make the default floating-window box bigger than omarchy's 875x600 (used by image viewer, About, generic floats).
o.window({ tag = "floating-window" }, { size = { 1300, 900 } })
