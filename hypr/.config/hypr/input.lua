-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
	input = {
		--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
		kb_layout = "us", --,dk,eu",
		kb_options = "compose:caps,grp:alt_space_toggle",
		--
		--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
		--     kb_variant = "intl",
		--
		--     -- Change speed of keyboard repeat.
		repeat_rate = 40,
		repeat_delay = 200,
		--
		--     -- Start with numlock on by default.
		--     numlock_by_default = true,
		--
		--     -- Increase sensitivity for mouse/trackpad (default: 0).
		sensitivity = 0.6,
		--
		--     -- Turn off mouse acceleration (default: adaptive).
		--     accel_profile = "flat",
		--
		touchpad = {
			-- Use natural (inverse) scrolling.
			natural_scroll = true,
			--
			-- Use two-finger clicks for right-click instead of lower-right corner.
			clickfinger_behavior = true,
			--
			--       -- Control the speed of your scrolling.
			scroll_factor = 0.8,
			--
			--       -- Enable the touchpad while typing.
			--       disable_while_typing = false,
			--
			--       -- Left-click-and-drag with three fingers.
			--       drag_3fg = 1,
		},
	},
})

-- Per-device overrides.Names must match `hyprctl devices` exactly (lowercase, dash-separated).
--
-- Global input.natural_scroll stays off (Omarchy default), so `true` here means
-- "natural scroll on this mouse only" -- the touchpad is handled separately above.

-- check with `hyprctl devices` which devices are plugged in
-- deft bluetooth
hl.device({ name = "deft-pro-trackball", natural_scroll = true })
-- deft cable
hl.device({ name = "elecom-trackball-mouse-deft-pro-trackball-mouse", natural_scroll = true })
-- NOTE: the old input.conf had this one on `false` (traditional scrolling).
-- Set to true on purpose -- this is the mouse in daily use.
hl.device({ name = "logitech-mx-master-3s", natural_scroll = true })
hl.device({ name = "mx-anywhere-2-mouse", natural_scroll = true })
hl.device({ name = "logitech-anywhere-mx", natural_scroll = true }) -- backbag mouse
hl.device({ name = "mx-anywhere-2s-mouse", natural_scroll = true }) -- white home

-- App-specific touchpad scroll speeds.
-- Scroll faster in the terminal (1:1 from the old input.conf; both rules still
-- exist in Quattro, they were just left commented in the template).
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
