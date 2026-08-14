-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- ---------------------------------------------------------------------------------------
-- Everything below is converted from the old monitors.conf.
--
-- NOTE: the old config set `env = GDK_SCALE,1.75` (for 4k). The Omarchy default
-- above sets 2. Change `omarchy_gdk_scale` to 1.75 if the old value worked better.
-- You must relaunch Hyprland after changing envs (use Super+Esc, then Relaunch).
-- ---------------------------------------------------------------------------------------

-- ============================================================================
-- SINGLE SOURCE OF TRUTH
-- Define each monitor I own once. Change ports here if they swap or break.
-- Add new monitors below by following the same pattern.
-- ============================================================================

-- Match Dells by description, not port. The port (DP-1, DP-2, HDMI-*) doesn't
-- matter anymore -- Hyprland resolves "desc:<substring>" to whatever port the
-- monitor is currently plugged into. Confirm description with: hyprctl monitors

-- --- HOME Dell (Dell S2722QC, 27" 4K UHD) ---
local dell_home_port = "desc:Dell Inc. DELL S2722QC"
local dell_home_res = "3840x2160@60"
local dell_home_scale = 1.5

-- --- WORK Dell (Dell S2725QC, 4K UHD) ---
-- TODO: verify exact description at office (hyprctl monitors -j)
-- local dell_work_port = "desc:Dell Inc. DELL S2722QC 89CQLD3"
local dell_work_port = "desc:Dell Inc. DELL S2725QC DTFF464"
local dell_work_res = "3840x2160@60"
local dell_work_scale = 1.5

-- --- TUXEDO laptop internal ---
local laptop = "eDP-1"
local laptop_res = "2880x1800@120"
local laptop_scale = 1.6

-- --- HDMI (check with `hyprctl monitors` whether it is HDMI-A-1 or HDMI-1) ---
local hdmi = "HDMI-A-1"

-- --- Layout positions ---
local pos_ext_top_left = "0x0" -- external at origin
local pos_home_laptop = "480x1440" -- laptop BELOW external (home stack)
local pos_office_laptop = "2560x220" -- laptop RIGHT of external (office)
local pos_standalone_laptop = "0x0" -- laptop standalone
local pos_hdmi_laptop = "1920x0" -- laptop right of HDMI (extended)

-- --- Workspace assignment is dynamic ---
-- At boot, workspaces 1-5 default to dell_home_port (see bottom of file).
-- When you press SUPER+ALT+7 (home) or SUPER+ALT+8 (office), the keybind
-- reassigns workspaces 1-5 to whichever Dell port is in use, so you only
-- ever need to update dell_home_port or dell_work_port above.

-- --- Composable helpers (replaces the old hyprctl --batch fragments) ---
local function assign_workspaces(first, last, monitor)
  for ws = first, last do
    hl.workspace_rule({ workspace = tostring(ws), monitor = monitor })
  end
end

local function notify(title, body)
  hl.exec_cmd("notify-send " .. o.shell_quote(title) .. " " .. o.shell_quote(body))
end

-- Monitor layouts
local function layout_home()
  hl.monitor({ output = dell_home_port, mode = dell_home_res, position = pos_ext_top_left, scale = dell_home_scale })
  hl.monitor({ output = laptop, mode = laptop_res, position = pos_home_laptop, scale = laptop_scale })
end

local function layout_home_ext_only()
  hl.monitor({ output = dell_home_port, mode = dell_home_res, position = pos_ext_top_left, scale = dell_home_scale })
  hl.monitor({ output = laptop, disabled = true })
end

local function layout_office()
  hl.monitor({ output = dell_work_port, mode = dell_work_res, position = pos_ext_top_left, scale = dell_work_scale })
  hl.monitor({ output = laptop, mode = laptop_res, position = pos_office_laptop, scale = laptop_scale })
end

local function layout_office_ext_only()
  hl.monitor({ output = dell_work_port, mode = dell_work_res, position = pos_ext_top_left, scale = dell_work_scale })
  hl.monitor({ output = laptop, disabled = true })
end

local function layout_laptop_only()
  hl.monitor({ output = dell_home_port, disabled = true })
  hl.monitor({ output = dell_work_port, disabled = true })
  hl.monitor({ output = laptop, mode = laptop_res, position = pos_standalone_laptop, scale = laptop_scale })
end

-- Monitor and Screen resolution --TUXEDO
--
-- Desc for 4: For example, if you have a 27" or 32" 4K, you can use fractional
-- scaling (GDK_SCALE 1.75 and monitor scale 1.666667).
-- Fallback: the `output = ""` monitor at the top of this file covers everything else.

-- ===== STATIC MONITOR DEFINITIONS =====
-- These apply when Hyprland starts

-- -- External Dell 4K monitor (works for both home and office)
-- hl.monitor({ output = dell_home_port, mode = dell_home_res, position = pos_ext_top_left, scale = dell_home_scale })

-- -- TUXEDO laptop internal screen (default) - append mirror for demo-presentations
-- hl.monitor({ output = laptop, mode = laptop_res, position = pos_home_laptop, scale = laptop_scale })

-- MIRROR for PRESENTATIONs -> Comment out above and use below. Check with `hyprctl monitors`
-- -1 DisplayPort:
-- hl.monitor({ output = laptop, mode = laptop_res, position = "0x0", scale = laptop_scale, mirror = dell_home_port })
-- -2 HDMI:
-- hl.monitor({ output = laptop, mode = laptop_res, position = "0x0", scale = laptop_scale, mirror = hdmi })

-- SUPER+ALT+0 for autosetup for presentation
-- Manual Setup: Use `hyprmon` to setup screen

-- ===== DYNAMIC LAYOUT SWITCHING =====
-- Only the POSITION changes between home and office
--
-- NOTE: SUPER+ALT+1..5 are Omarchy defaults ("Switch to group window N"), so
-- they are unbound first. SUPER+ALT+7/8/9/0 were free.

-- SUPER ALT 7: HOME setup (external above, laptop below) -- Toggle to HOME setup
o.bind("SUPER + ALT + 7", "Home Setup", function()
  layout_home()
  assign_workspaces(1, 5, dell_home_port)
  assign_workspaces(6, 10, laptop)
  notify("Monitor Setup", "HOME: External above laptop")
end)

hl.unbind("SUPER + ALT + code:10") -- default: Switch to group window 1
o.bind("SUPER + ALT + 1", "Home Ext Only", function()
  layout_home_ext_only()
  assign_workspaces(1, 5, dell_home_port)
  notify("Monitor Setup", "HOME: External only")
end)

-- SUPER ALT 8: OFFICE setup (external left, laptop right) -- Toggle to OFFICE setup
o.bind("SUPER + ALT + 8", "Office Setup", function()
  layout_office()
  assign_workspaces(1, 5, dell_work_port)
  assign_workspaces(6, 10, laptop)
  notify("Monitor Setup", "OFFICE: Laptop right of external")
end)

hl.unbind("SUPER + ALT + code:11") -- default: Switch to group window 2
o.bind("SUPER + ALT + 2", "Office Ext Only", function()
  layout_office_ext_only()
  assign_workspaces(1, 5, dell_work_port)
  notify("Monitor Setup", "OFFICE: External only")
end)

-- SUPER ALT 9: Laptop only (disable both externals)
o.bind("SUPER + ALT + 9", "Laptop Only", function()
  layout_laptop_only()
  assign_workspaces(1, 5, laptop)
  notify("Monitor Setup", "Laptop only mode")
end)

-- SUPER ALT 0: Auto setup (reset to defaults)
o.bind("SUPER + ALT + 0", "Auto Setup", function()
  hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
  notify("Monitor Setup", "AUTO setup")
end)

-- ===== HDMI SHORTCUTS =====
-- TODO: Check when connected it shows up as HDMI-A-1 or HDMI-1
-- SUPER ALT 4: Mirror internal laptop to HDMI (for presentations)
hl.unbind("SUPER + ALT + code:13") -- default: Switch to group window 4
o.bind("SUPER + ALT + 4", "HDMI Mirror", function()
  hl.monitor({ output = hdmi, mode = "preferred", position = "auto", scale = "auto" })
  hl.monitor({ output = laptop, mode = laptop_res, position = "0x0", scale = laptop_scale, mirror = hdmi })
  notify("Monitor Setup", "HDMI: Mirrored display")
end)

-- SUPER ALT 5: Extended display with HDMI (laptop + HDMI side by side)
hl.unbind("SUPER + ALT + code:14") -- default: Switch to group window 5
o.bind("SUPER + ALT + 5", "HDMI Extended", function()
  hl.monitor({ output = hdmi, mode = "preferred", position = "0x0", scale = "auto" })
  hl.monitor({ output = laptop, mode = laptop_res, position = pos_hdmi_laptop, scale = laptop_scale })
  notify("Monitor Setup", "HDMI: Extended display")
end)

-- Cycle monitor scaling with SUPER + CTRL + / (slash)
-- QUATTRO: omarchy-hyprland-monitor-scaling-cycle is gone; it is now
-- `omarchy-hyprland-monitor-scaling up|down` (also on SUPER+SLASH / SUPER+ALT+SLASH
-- by default, but those are taken by 1Password here).
o.bind("SUPER + CTRL + SLASH", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up")
o.bind("SUPER + CTRL + ALT + SLASH", "Monitor scaling down", "omarchy-hyprland-monitor-scaling down")

-- Scaling on dell home setup - Scaling comparison:
-- - **1.0 (Native)**: 3840x2160 - Too small, text would be unreadable
-- - **1.5 (seem best)**: 2560x1440 effective - Perfect balance ✅
-- - **2.0**: 1920x1080 effective - Too large, wastes the 4K resolution

-- ===== WORKSPACE ASSIGNMENT =====
-- Boot defaults: workspaces 1-5 on dell_home_port. SUPER+ALT+7/8 reassign at runtime.
assign_workspaces(1, 5, dell_home_port)

-- Workspaces 6-10 on laptop screen (eDP-1)
assign_workspaces(6, 10, laptop)

-- Fallback: when no external monitor, all workspaces on laptop
--
-- The old monitors.conf repeated `workspace = 1..5, monitor:$laptop, default:true`
-- here as a fallback. That does NOT translate: hl.workspace_rule() is keyed by
-- workspace, so a second call for the same workspace REPLACES the first one --
-- re-adding these lines pins workspaces 1-5 to eDP-1 permanently and the Dell
-- never gets them. Hyprland already falls back to an available monitor when the
-- one named in the rule is not connected, so no fallback rule is needed.

-- HOME SETUP: External monitor (top) - Dell S2722QC at native 4K resolution
-- Laptop screen on the bottom
--   hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "0x0", scale = 1.5 })
--   hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x1440", scale = 1.5 })

-- OFFICE SETUP: Dell display to the left of laptop
--   hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "0x0", scale = 1.5 })
--   hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "2560x0", scale = 1.25 })
