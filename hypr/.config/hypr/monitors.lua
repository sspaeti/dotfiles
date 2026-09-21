-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- HOW THIS FILE WORKS
--   1. Every monitor I own is defined ONCE below (matched by description, not port).
--   2. A "profile" (home / office / laptop) picks layout + workspaces.
--   3. The chosen profile is PERSISTED to ~/.local/state/omarchy/monitor-profile,
--      so Hyprland reloads (theme changes, clamshell polls, ...) keep it.
--   4. NOTHING resets the profile automatically except one safety check: on every
--      reload the stored profile is validated against the monitors that are
--      actually connected. If the monitor it needs is gone (cable pulled,
--      different desk) it falls back to auto-detection: home Samsung -> HOME,
--      work Dell -> OFFICE, none -> LAPTOP. Cable plug/unplug does NOT wipe your
--      choice -- only pressing a profile key or SUPER+ALT+0 does.
--   5. Scale is a bare literal below, rewritten in place by SUPER+ALT+3 (pin) and
--      reset by any profile key or SUPER+ALT+0. See "SCALES" for why a literal.
--
-- WHAT IS DELIBERATELY *NOT* HERE ANYMORE (Omarchy already does it better):
--   * external-only / laptop-off  -> SUPER+ALT+1  omarchy-hyprland-monitor-internal
--   * mirroring for presentations -> SUPER+ALT+2  omarchy-hyprland-monitor-internal-mirror
--     (mirrors to whatever external is live -- HDMI, DP, USB-C dongle -- and
--     recovers itself on unplug. The old hdmi_mirror/hdmi_ext profiles hardcoded
--     HDMI-A-1 and were useless for a projector on anything else.)
--   * lid-closed handling         -> omarchy-hyprland-monitor-clamshell (automatic)
--   * text size (shell/GTK/term)  -> SUPER+CTRL+ALT+PLUS/MINUS, see bindings below
--   Both toggles layer on top of whichever profile is active, via
--   ~/.local/state/omarchy/toggles/hypr/*.lua, which hyprland.lua requires AFTER
--   this file -- so they always win, and clearing them restores the profile.

-- ============================================================================
-- SCALES
-- ============================================================================
-- SUPER+ALT+3 rewrites the three `local *_scale = <n>` lines below in place
-- (sspaeti/monitor-scale.sh), then reloads. Everything else in this file --
-- including every position -- is derived from them, so a pinned scale keeps the
-- layout flush instead of shoving the laptop off to the side.
--
-- They MUST stay bare numeric literals, each alone on its line. Two parsers
-- depend on that shape:
--   1. sspaeti/monitor-scale.sh -- its sed target.
--   2. omarchy-hyprland-monitor-clamshell -- run by omarchy-hyprland-monitor-watch
--      after every monitor event AND on a 2s poll while docked. It TEXT-PARSES
--      this file for the internal monitor's configured scale and re-asserts it
--      via `hyprctl eval`. Our eDP-1 rules use `output = laptop` (a variable),
--      which its rule regex cannot match, so it falls through to the catch-all
--      rule below -- which points at `laptop_scale` precisely so it resolves.
--      If it resolves to nothing it force-evals eDP-1 to scale 2 at
--      `position = auto`, i.e. it fights whatever we just set.
--   Pinning the literal (rather than layering an override on top) is what keeps
--   Omarchy's own machinery in agreement with us instead of racing it.
local samsung_scale = 2
local dell_scale = 1.6
local laptop_scale = 1.6
-- One literal per monitor, because the two externals differ: the work Dell is
-- still 4K and stays at 1.6 (2400x1350), while the home Samsung is 5K.
-- Reset targets for SUPER+ALT+0 and any profile key (see monitor-scale.sh):
-- Samsung 2, Dell 1.6, laptop 1.6. The Samsung is an INTEGER scale on purpose:
-- 5K at 2 is 2560x1440 logical -- pixel-perfect for everything, including
-- XWayland and non-fractional GTK apps that get rendered at 2x and downsampled
-- (blurry) at 1.6 -- and still more room than the old 4K Dell at 1.6 (2400x1350).
-- The same 5K panel at 1.6 would be 3200x1800 logical: tiny text, blurry X apps.
-- Nothing else in this file assumes the two scales are equal.

local omarchy_gdk_scale = 2
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- ============================================================================
-- SINGLE SOURCE OF TRUTH
-- Define each monitor I own once. Add new monitors by following the pattern.
-- ============================================================================
-- Match Dells by description, not port. The port (DP-1, DP-2, HDMI-*) doesn't
-- matter -- Hyprland resolves "desc:<substring>" to whatever port it is on.
-- Confirm the description with: hyprctl monitors

-- Each external carries its native pixel size so the layout math below can
-- derive logical sizes per monitor (the two externals no longer share a mode).
-- `match` is the EDID model string used for sysfs auto-detection.

-- --- HOME Samsung (ViewFinity S80HF, 27" 5K 5120x2880@60) ---
-- Replaced the 4K Dell S2722QC on 2026-09-21. Same physical size, 4x the
-- pixels, so scale 2 is the sweet spot (see SCALES). Only mode is 5K@59.99.
local samsung_home = {
  match = "LS27H80xEF",
  port = "desc:Samsung Electric Company LS27H80xEF",
  w = 5120,
  h = 2880,
  mode = "5120x2880@60",
  scale = samsung_scale,
}

-- --- WORK Dell (Dell S2725QC, 27" 4K UHD) ---
local dell_work = {
  match = "S2725QC",
  port = "desc:Dell Inc. DELL S2725QC DTFF464",
  w = 3840,
  h = 2160,
  mode = "3840x2160@60",
  scale = dell_scale,
}

-- --- TUXEDO laptop internal ---
local laptop = "eDP-1"
local laptop_w, laptop_h = 2880, 1800
local laptop_res = "2880x1800@120"

-- --- Catch-all for unknown monitors (projectors, a colleague's screen, ...) ---
-- Plain extend at Hyprland's own placement. Read the SCALES note above before
-- touching `scale = laptop_scale` -- the bare variable is load-bearing.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = laptop_scale })

-- ============================================================================
-- LAYOUT MATH
-- ============================================================================
-- Hyprland `position` is in SCALED coordinates, not native pixels, so every
-- position is derived from resolution/scale. Pin a different scale and the
-- monitors stay flush (no gaps, no laptop stranded off to the right).
--   Samsung 5120x2880 @2   -> 2560x1440
--   Dell    3840x2160 @1.6 -> 2400x1350
--   Laptop  2880x1800 @1.6 -> 1800x1125
local lt_w = math.floor(laptop_w / laptop_scale)
local lt_h = math.floor(laptop_h / laptop_scale)

local function logical(ext)
  return math.floor(ext.w / ext.scale), math.floor(ext.h / ext.scale)
end

-- laptop BELOW the external, horizontally centered under it (home stack)
local function pos_below(ext)
  local w, h = logical(ext)
  return string.format("%dx%d", math.max(0, math.floor((w - lt_w) / 2)), h)
end

-- laptop RIGHT of the external, vertically centered against it (office)
local function pos_right(ext)
  local w, h = logical(ext)
  return string.format("%dx%d", w, math.max(0, math.floor((h - lt_h) / 2)))
end

local function assign_workspaces(first, last, monitor)
  for ws = first, last do
    hl.workspace_rule({ workspace = tostring(ws), monitor = monitor })
  end
end

-- External at the origin, laptop wherever the profile wants it.
local function layout_docked(ext, laptop_pos)
  hl.monitor({ output = ext.port, mode = ext.mode, position = "0x0", scale = ext.scale })
  hl.monitor({ output = laptop, mode = laptop_res, position = laptop_pos, scale = laptop_scale })
end

-- ============================================================================
-- PROFILES
-- ============================================================================
-- `needs` names a key from detect_monitors(). If that monitor is no longer
-- connected the stored profile is discarded and auto-detection takes over.
-- This is the ONLY automatic behaviour left, and it only ever fires when the
-- stored profile literally cannot be applied.
local profiles = {
  home = {
    needs = "home_samsung",
    apply = function()
      layout_docked(samsung_home, pos_below(samsung_home))
      assign_workspaces(1, 5, samsung_home.port)
      assign_workspaces(6, 10, laptop)
    end,
  },
  office = {
    needs = "work_dell",
    apply = function()
      layout_docked(dell_work, pos_right(dell_work))
      assign_workspaces(1, 5, dell_work.port)
      assign_workspaces(6, 10, laptop)
    end,
  },
  laptop = {
    apply = function()
      hl.monitor({ output = samsung_home.port, disabled = true })
      hl.monitor({ output = dell_work.port, disabled = true })
      hl.monitor({ output = laptop, mode = laptop_res, position = "0x0", scale = laptop_scale })
      assign_workspaces(1, 10, laptop)
    end,
  },
}

-- ============================================================================
-- PERSISTENCE + AUTO-DETECTION
-- ============================================================================
local state_file = (os.getenv("HOME") or "") .. "/.local/state/omarchy/monitor-profile"

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

local function read_stored_profile()
  local content = read_file(state_file)
  return content and content:match("%S+")
end

-- Detect connected monitors from sysfs (DRM connector status + EDID model
-- string). Deliberately NOT `hyprctl monitors`: this code runs while Hyprland
-- parses the config, and Hyprland cannot answer its own IPC mid-reload
-- (deadlocks until timeout). sysfs is always readable, even at first boot.
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

  local present = { home_samsung = false, work_dell = false }
  for dir in listing:gmatch("[^\n]+") do
    local status = read_file(dir .. "/status") or ""
    if status:find("^connected") then
      local edid = read_file(dir .. "/edid") or ""
      if edid:find(samsung_home.match, 1, true) then
        present.home_samsung = true
      end
      if edid:find(dell_work.match, 1, true) then
        present.work_dell = true
      end
    end
  end
  return present
end

local function resolve_profile()
  local present = detect_monitors()
  if not present then
    return nil -- sysfs unreadable: leave the catch-all defaults in place
  end

  local stored = read_stored_profile()
  local profile = stored and profiles[stored]
  if profile and profile.needs and not present[profile.needs] then
    profile = nil -- stored profile no longer matches connected hardware
  end

  if not profile then
    if present.home_samsung then
      profile = profiles.home
    elseif present.work_dell then
      profile = profiles.office
    else
      profile = profiles.laptop
    end
  end

  return profile
end

-- ============================================================================
-- KEYBINDS
-- ============================================================================
-- Profiles (SUPER+ALT+7/8/9/0) only persist a NAME and reload -- the layout is
-- applied by resolve_profile() above, so keypress and reload share ONE path.
-- Picking a profile also resets a pinned scale, which is the intended "put
-- everything back the way it was" gesture.
--
-- NOTE: SUPER+ALT+1..3 are Omarchy defaults ("Switch to group window N"), so
-- they are unbound first. SUPER+ALT+7/8/9/0 were free.
local home = os.getenv("HOME") or ""
local ssp = home .. "/.config/hypr/sspaeti"
local scale_sh = o.shell_quote(ssp .. "/monitor-scale.sh")
local text_sh = o.shell_quote(ssp .. "/text-size-step.sh")
local state_file_q = o.shell_quote(state_file)

local function bind_profile(keys, description, profile_name, message)
  local cmd = scale_sh
    .. " reset && printf '%s' "
    .. profile_name
    .. " > "
    .. state_file_q
    .. " && hyprctl reload && notify-send 'Monitor Setup' "
    .. o.shell_quote(message)
  o.bind(keys, description, "sh -c " .. o.shell_quote(cmd))
end

bind_profile("SUPER + ALT + 7", "Home Setup", "home", "HOME: external above laptop")
bind_profile("SUPER + ALT + 8", "Office Setup", "office", "OFFICE: laptop right of external")
bind_profile("SUPER + ALT + 9", "Laptop Only", "laptop", "LAPTOP: internal display only")

-- SUPER+ALT+0: back to auto-detection (clears the stored profile and the pin)
o.bind(
  "SUPER + ALT + 0",
  "Auto Setup",
  "sh -c "
    .. o.shell_quote(
      scale_sh
        .. " reset && rm -f "
        .. state_file_q
        .. " && hyprctl reload && notify-send 'Monitor Setup' 'AUTO: detected from connected monitors'"
    )
)

-- Omarchy's own orthogonal toggles. They layer on top of the active profile via
-- ~/.local/state/omarchy/toggles/hypr/, so they compose with home/office/laptop
-- and undo cleanly. Both auto-recover when the external monitor disappears.
hl.unbind("SUPER + ALT + code:10") -- default: Switch to group window 1
o.bind("SUPER + ALT + 1", "Toggle laptop display", "omarchy-hyprland-monitor-internal toggle")

-- Presentation mode: mirrors the laptop onto whatever external is live, so it
-- works with a projector on HDMI, DP or a USB-C dongle. Plug in, then hit this.
hl.unbind("SUPER + ALT + code:11") -- default: Switch to group window 2
o.bind("SUPER + ALT + 2", "Toggle mirror (present)", "omarchy-hyprland-monitor-internal-mirror toggle")

-- Monitor scale. Deliberately NOT `omarchy-hyprland-monitor-scaling up`: that
-- command applies the new scale at `position = "auto"`, which makes Hyprland
-- re-place the monitor -- the external jumps to the right of the laptop and the
-- office/home arrangement is destroyed on every single scale step.
-- monitor-scale.sh steps the `*_scale` literal above instead and reloads, so
-- every position is recomputed from the new scale and the arrangement survives.
-- (Omarchy's default SUPER+SLASH / SUPER+ALT+SLASH are taken by 1Password here.)
-- Primary chord: SUPER+CTRL+ALT +/-. One modifier out from SUPER+CTRL +/-,
-- which is cursor zoom in bindings.lua, so the two "make it bigger" gestures sit
-- next to each other. The SLASH pair is kept as an alias (Omarchy's own default
-- for monitor scaling is on SLASH, so muscle memory from the stock config works).
o.bind("SUPER + CTRL + ALT + EQUAL", "Monitor scaling up", "sh -c " .. o.shell_quote(scale_sh .. " up"))
o.bind("SUPER + CTRL + ALT + MINUS", "Monitor scaling down", "sh -c " .. o.shell_quote(scale_sh .. " down"))
o.bind("SUPER + CTRL + SLASH", "Monitor scaling up", "sh -c " .. o.shell_quote(scale_sh .. " up"))
o.bind("SUPER + CTRL + ALT + SLASH", "Monitor scaling down", "sh -c " .. o.shell_quote(scale_sh .. " down"))

-- Reset scale only, keeping the current profile (SUPER+ALT+0 resets scale AND
-- clears the profile back to auto-detection).
o.bind(
  "SUPER + CTRL + ALT + 0",
  "Monitor scaling reset",
  "sh -c "
    .. o.shell_quote(
      scale_sh .. " reset && hyprctl reload && notify-send 'Monitor Setup' 'Scale reset: Samsung 2, Dell 1.6, laptop 1.6'"
    )
)

-- SUPER+ALT+3: pin the CURRENT live scales into this file and reload, so the
-- layout is recomputed around them. Still useful when the scale was changed
-- somewhere that does go through Omarchy's `position = auto` path -- the shell's
-- monitor panel, or the Omarchy menu -- which leaves the layout skewed until
-- this repairs it. Undo with any profile key or SUPER+ALT+0.
hl.unbind("SUPER + ALT + code:12") -- default: Switch to group window 3
o.bind("SUPER + ALT + 3", "Pin current scale", "sh -c " .. o.shell_quote(scale_sh .. " pin"))

-- Text size: shell + GTK + terminal font in lockstep, geometry untouched. This
-- is the knob for "make this readable in a screenshot" -- it does not move a
-- single window, unlike monitor scaling. Same chord as scaling plus SHIFT.
o.bind("SUPER + CTRL + ALT + SHIFT + EQUAL", "Text size up", "sh -c " .. o.shell_quote(text_sh .. " up"))
o.bind("SUPER + CTRL + ALT + SHIFT + MINUS", "Text size down", "sh -c " .. o.shell_quote(text_sh .. " down"))
o.bind("SUPER + CTRL + ALT + SHIFT + 0", "Text size reset", "sh -c " .. o.shell_quote(text_sh .. " reset"))

-- Scaling comparison, 27" 5K Samsung (5120x2880):
--   1.0 (native) 5120x2880 -- unusable, ~217 PPI unscaled
--   1.6          3200x1800 -- tiny text, XWayland/non-fractional apps blurry
--   2.0          2560x1440 -- daily driver: integer scale, everything crisp
--   2.5          2048x1152 -- screen recording / presentations
--   4.0          1280x720  -- demo-to-a-room big
--   3.0 is NOT a clean divisor for 5120x2880 (Hyprland would auto-correct it
--   and raise a config error), so monitor-scale.sh skips it on this panel.
-- 27" 4K Dell (3840x2160): 1.6 -> 2400x1350 (old daily driver), 2.0 -> 1920x1080,
--   2.5 -> 1536x864, 3.0 -> 1280x720.

-- ============================================================================
-- STATIC DEFAULTS + PROFILE APPLICATION
-- ============================================================================
-- Base workspace split, overridden by the profile below. Hyprland already falls
-- back to an available monitor when a workspace rule names a disconnected one,
-- so no extra fallback rules are needed.
assign_workspaces(1, 5, samsung_home.port)
assign_workspaces(6, 10, laptop)

local profile = resolve_profile()
if profile then
  profile.apply()
end
