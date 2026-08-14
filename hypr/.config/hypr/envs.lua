-- Extra env variables
-- Note: You must relaunch Hyprland after changing envs (use Super+Esc, then Relaunch)
-- hl.env("MY_GLOBAL_ENV", "setting")
--
-- Converted 1:1 from the old envs.conf, which was sourced by the old
-- hyprland.conf but had no Lua counterpart, so none of it was active after the
-- Quattro upgrade.

-- Make Brave use XCompose and all Wayland
hl.env("BRAVE_FLAGS", "--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4")

-- Cursor size (Omarchy's default is 24)
hl.env("XCURSOR_SIZE", "48")
hl.env("HYPRCURSOR_SIZE", "48")
