-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- HOW THIS FILE WORKS
--   1. Every monitor I own is defined ONCE below (matched by description, not port).
--   2. A "profile" (home / office / laptop / hdmi...) picks layout + workspaces.
--   3. The chosen profile is PERSISTED to ~/.local/state/omarchy/monitor-profile,
--      so Hyprland reloads (e.g. omarchy theme changes) keep the current setup.
--   4. On every reload the stored profile is validated against the monitors that
--      are actually connected; if it no longer fits (cable pulled, different
--      desk), it falls back to auto-detection: home Dell -> HOME, work Dell ->
--      OFFICE, none -> laptop only.
--   5. ~/.config/hypr/sspaeti/monitor-hotplug-watcher.sh (autostart) clears the
--      stored profile and reloads whenever a monitor is plugged/unplugged, so
--      cable events always re-run auto-detection.
--   6. MANUAL MODE (SUPER+ALT+3): snapshots the CURRENT live monitor settings
--      (after tweaking scale/resolution, e.g. for screen recording) into
--      ~/.local/state/omarchy/.monitor-manual and stores profile "manual", so
--      reloads keep the tweaked setup instead of snapping back to a profile.
--      Any profile keybind, SUPER+ALT+0, or a cable change exits manual mode
--      through the existing state-file paths -- nothing extra to clean up.

local omarchy_gdk_scale = 2

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- ============================================================================
-- SINGLE SOURCE OF TRUTH
-- Define each monitor I own once. Change ports here if they swap or break.
-- Add new monitors below by following the same pattern.
-- ============================================================================

-- Match Dells by description, not port. The port (DP-1, DP-2, HDMI-*) doesn't
-- matter anymore -- Hyprland resolves "desc:<substring>" to whatever port the
-- monitor is currently plugged into. Confirm description with: hyprctl monitors

-- --- HOME Dell (Dell S2722QC, 27" 4K UHD) ---
local dell_home_match = "S2722QC" -- unique substring, used for auto-detection
local dell_home_port = "desc:Dell Inc. DELL " .. dell_home_match
local dell_home_res = "3840x2160@60"
local dell_home_scale = 1.6

-- --- WORK Dell (Dell S2725QC, 4K UHD) ---
local dell_work_match = "S2725QC"
local dell_work_port = "desc:Dell Inc. DELL " .. dell_work_match .. " DTFF464"
local dell_work_res = "3840x2160@60"
local dell_work_scale = 1.6

-- --- TUXEDO laptop internal ---
local laptop = "eDP-1"
local laptop_res = "2880x1800@120"
local laptop_scale = 1.6

-- --- HDMI (check with `hyprctl monitors` whether it is HDMI-A-1 or HDMI-1) ---
local hdmi = "HDMI-A-1"

-- --- Catch-all for unknown monitors ---
-- The scale is `laptop_scale` (a bare variable, not a literal) for TWO reasons:
--   1. omarchy-hyprland-monitor-scaling sed-rewrites a literal `scale = <n>`
--      on this line; that file write makes Hyprland auto-reload and re-apply
--      the profile, instantly reverting the very scale change just made.
--      A variable dodges its regex.
--   2. omarchy-hyprland-monitor-clamshell (run by omarchy-hyprland-monitor-watch
--      after every monitor event, with 1/3/7s delayed retries) TEXT-PARSES this
--      file for the internal monitor's "configured" scale. Our eDP-1 rules use
--      `output = laptop`, which its parser can't match, so it falls back to this
--      catch-all. It CAN resolve a bare word via `local laptop_scale = 1.6`, so
--      pointing it here keeps its desired scale == what the profiles apply.
--      Otherwise it force-evals eDP-1 back to `position = auto` at the stale
--      scale a few seconds after every profile switch (laptop ends up right of
--      the Dell instead of below it).
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = laptop_scale })

-- --- Logical (scaled) sizes ---
-- Hyprland `position` is in SCALED coordinates, not native pixels. So every
-- position below is derived from resolution/scale -- change a scale above and
-- the layouts stay flush automatically (no more gaps like 1.5 -> 1.6 caused).
--   Dell   3840x2160 @1.6 -> 2400x1350
--   Laptop 2880x1800 @1.6 -> 1800x1125
local dell_w = math.floor(3840 / dell_home_scale)
local dell_h = math.floor(2160 / dell_home_scale)
local laptop_w = math.floor(2880 / laptop_scale)
local laptop_h = math.floor(1800 / laptop_scale)

-- --- Layout positions ---
local pos_ext_top_left = "0x0" -- external at origin
-- laptop BELOW external, horizontally centered under it (home stack)
local pos_home_laptop = string.format("%dx%d", math.floor((dell_w - laptop_w) / 2), dell_h)
-- laptop RIGHT of external, vertically centered against it (office)
local pos_office_laptop = string.format("%dx%d", dell_w, math.floor((dell_h - laptop_h) / 2))
local pos_standalone_laptop = "0x0" -- laptop standalone
local pos_hdmi_laptop = "1920x0" -- laptop right of HDMI (extended)

-- --- Composable helpers ---
local function assign_workspaces(first, last, monitor)
  for ws = first, last do
    hl.workspace_rule({ workspace = tostring(ws), monitor = monitor })
  end
end

-- ===== MONITOR LAYOUTS =====
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

local function layout_hdmi_mirror()
  hl.monitor({ output = hdmi, mode = "preferred", position = "auto", scale = "auto" })
  hl.monitor({ output = laptop, mode = laptop_res, position = "0x0", scale = laptop_scale, mirror = hdmi })
end

local function layout_hdmi_ext()
  hl.monitor({ output = hdmi, mode = "preferred", position = "0x0", scale = "auto" })
  hl.monitor({ output = laptop, mode = laptop_res, position = pos_hdmi_laptop, scale = laptop_scale })
end

-- ===== PROFILES =====
-- `needs` names a key from detect_monitors(); if that monitor is not connected
-- anymore, the stored profile is discarded and auto-detection takes over.
local profiles = {
  home = {
    needs = "home_dell",
    apply = function()
      layout_home()
      assign_workspaces(1, 5, dell_home_port)
      assign_workspaces(6, 10, laptop)
    end,
  },
  home_ext = {
    needs = "home_dell",
    apply = function()
      layout_home_ext_only()
      assign_workspaces(1, 10, dell_home_port)
    end,
  },
  office = {
    needs = "work_dell",
    apply = function()
      layout_office()
      assign_workspaces(1, 5, dell_work_port)
      assign_workspaces(6, 10, laptop)
    end,
  },
  office_ext = {
    needs = "work_dell",
    apply = function()
      layout_office_ext_only()
      assign_workspaces(1, 10, dell_work_port)
    end,
  },
  laptop = {
    apply = function()
      layout_laptop_only()
      assign_workspaces(1, 10, laptop)
    end,
  },
  hdmi_mirror = {
    needs = "hdmi",
    apply = function()
      layout_hdmi_mirror()
      assign_workspaces(1, 10, laptop)
    end,
  },
  hdmi_ext = {
    needs = "hdmi",
    apply = function()
      layout_hdmi_ext()
      assign_workspaces(1, 10, laptop)
    end,
  },
}

-- ===== PERSISTENCE + AUTO-DETECTION =====
local state_file = (os.getenv("HOME") or "") .. "/.local/state/omarchy/monitor-profile"
-- Snapshot of live monitor settings, written by SUPER+ALT+3 (manual mode).
-- One monitor per line: "<name> <WxH@Hz> <XxY> <scale>" or "<name> disabled".
local manual_file = (os.getenv("HOME") or "") .. "/.local/state/omarchy/.monitor-manual"

local function read_stored_profile()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local line = f:read("*l")
  f:close()
  return line and line:match("%S+")
end

-- Detect connected monitors from sysfs (DRM connector status + EDID model
-- string). Deliberately NOT `hyprctl monitors`: this code runs while Hyprland
-- parses the config, and Hyprland cannot answer its own IPC mid-reload
-- (deadlocks until timeout). sysfs is always readable, even at first boot.
local function read_file(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

local function detect_monitors()
  local h = io.popen("ls -d /sys/class/drm/card*-* 2>/dev/null")
  if not h then
    return nil
  end
  local listing = h:read("*a") or ""
  h:close()
  if listing == "" then
    return nil
  end

  local present = { home_dell = false, work_dell = false, hdmi = false }
  for dir in listing:gmatch("[^\n]+") do
    local status = read_file(dir .. "/status") or ""
    if status:find("^connected") then
      local edid = read_file(dir .. "/edid") or ""
      if edid:find(dell_home_match, 1, true) then
        present.home_dell = true
      end
      if edid:find(dell_work_match, 1, true) then
        present.work_dell = true
      end
      -- connector name, e.g. card1-HDMI-A-1 -> HDMI-A-1
      if dir:match("card%d+%-HDMI") then
        present.hdmi = true
      end
    end
  end
  return present
end

-- Build a profile from the SUPER+ALT+3 snapshot. Port names (not desc:) are
-- fine here: the snapshot is only valid for the exact hardware it was taken
-- on, and any cable change clears it via the hotplug watcher anyway.
local function manual_profile()
  local f = io.open(manual_file, "r")
  if not f then
    return nil
  end
  local monitors = {}
  for line in f:lines() do
    local name, rest = line:match("^(%S+)%s+(.+)$")
    if name and rest == "disabled" then
      monitors[#monitors + 1] = { output = name, disabled = true }
    elseif name then
      local mode, pos, scale = rest:match("^(%S+)%s+(%S+)%s+(%S+)$")
      if mode then
        monitors[#monitors + 1] = { output = name, mode = mode, position = pos, scale = tonumber(scale) }
      end
    end
  end
  f:close()
  if #monitors == 0 then
    return nil
  end
  return {
    apply = function()
      for _, m in ipairs(monitors) do
        hl.monitor(m)
      end
      -- workspaces keep the static default split; Hyprland falls back to an
      -- available monitor when a rule names a disabled one
    end,
  }
end

local function resolve_profile()
  local present = detect_monitors()
  if not present then
    return nil -- sysfs unreadable: leave static defaults in place
  end

  local stored = read_stored_profile()
  if stored == "manual" then
    local manual = manual_profile()
    if manual then
      return manual
    end
    -- snapshot missing/empty: fall through to auto-detection
  end
  local profile = stored and profiles[stored]
  if profile and profile.needs and not present[profile.needs] then
    profile = nil -- stored profile no longer matches connected hardware
  end

  if not profile then
    if present.home_dell then
      profile = profiles.home
    elseif present.work_dell then
      profile = profiles.office
    else
      profile = profiles.laptop
    end
  end

  return profile
end

-- ===== KEYBINDS: pick a profile =====
-- Each bind only persists the profile name and reloads -- the layout itself is
-- applied by resolve_profile() above, so keypress and reload share ONE code path.
--
-- NOTE: SUPER+ALT+1..5 are Omarchy defaults ("Switch to group window N"), so
-- they are unbound first. SUPER+ALT+7/8/9/0 were free.
local state_file_q = o.shell_quote(state_file)

local function bind_profile(keys, description, profile_name, message)
  local cmd = "printf '%s' "
    .. profile_name
    .. " > "
    .. state_file_q
    .. " && hyprctl reload"
    .. " && notify-send 'Monitor Setup' "
    .. o.shell_quote(message)
  o.bind(keys, description, "sh -c " .. o.shell_quote(cmd))
end

bind_profile("SUPER + ALT + 7", "Home Setup", "home", "HOME: External above laptop")

hl.unbind("SUPER + ALT + code:10") -- default: Switch to group window 1
bind_profile("SUPER + ALT + 1", "Home Ext Only", "home_ext", "HOME: External only")

bind_profile("SUPER + ALT + 8", "Office Setup", "office", "OFFICE: Laptop right of external")

hl.unbind("SUPER + ALT + code:11") -- default: Switch to group window 2
bind_profile("SUPER + ALT + 2", "Office Ext Only", "office_ext", "OFFICE: External only")

bind_profile("SUPER + ALT + 9", "Laptop Only", "laptop", "Laptop only mode")

-- SUPER ALT 3: MANUAL mode -- pin whatever is on screen RIGHT NOW (after
-- tweaking scale/resolution) so reloads stop reverting it. No hyprctl reload
-- needed: the settings are already live; this only makes them survive.
hl.unbind("SUPER + ALT + code:12") -- default: Switch to group window 3
o.bind(
  "SUPER + ALT + 3",
  "Pin Current Setup",
  "sh -c "
    .. o.shell_quote(
      "hyprctl monitors all -j"
        .. [[ | jq -r '.[] | if .disabled then "\(.name) disabled" else "\(.name) \(.width)x\(.height)@\(.refreshRate) \(.x)x\(.y) \(.scale)" end']]
        .. " > "
        .. o.shell_quote(manual_file)
        .. " && printf '%s' manual > "
        .. state_file_q
        .. " && notify-send 'Monitor Setup' 'MANUAL: current settings pinned'"
    )
)

hl.unbind("SUPER + ALT + code:13") -- default: Switch to group window 4
bind_profile("SUPER + ALT + 4", "HDMI Mirror", "hdmi_mirror", "HDMI: Mirrored display")

hl.unbind("SUPER + ALT + code:14") -- default: Switch to group window 5
bind_profile("SUPER + ALT + 5", "HDMI Extended", "hdmi_ext", "HDMI: Extended display")

-- SUPER ALT 0: back to auto-detection (clears the stored profile)
o.bind(
  "SUPER + ALT + 0",
  "Auto Setup",
  "sh -c "
    .. o.shell_quote(
      "rm -f " .. state_file_q .. " && hyprctl reload && notify-send 'Monitor Setup' 'AUTO: detected from connected monitors'"
    )
)

-- Cycle monitor scaling with SUPER + CTRL + / (slash)
-- (omarchy default SUPER+SLASH / SUPER+ALT+SLASH are taken by 1Password here)
o.bind("SUPER + CTRL + SLASH", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up")
o.bind("SUPER + CTRL + ALT + SLASH", "Monitor scaling down", "omarchy-hyprland-monitor-scaling down")

-- Scaling on dell home setup - Scaling comparison:
-- - **1.0 (Native)**: 3840x2160 - Too small, text would be unreadable
-- - **1.5 (seem best)**: 2560x1440 effective - Perfect balance ✅
-- - **2.0**: 1920x1080 effective - Too large, wastes the 4K resolution

-- ===== STATIC DEFAULTS + PROFILE APPLICATION =====
-- Base workspace split (overridden by the profile below when IPC is ready).
-- Hyprland already falls back to an available monitor when the one named in a
-- workspace rule is not connected, so no extra fallback rules are needed.
assign_workspaces(1, 5, dell_home_port)
assign_workspaces(6, 10, laptop)

local profile = resolve_profile()
if profile then
  profile.apply()
end
