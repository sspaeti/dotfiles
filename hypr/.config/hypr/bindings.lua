-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
--
-- Converted 1:1 from the old bindings.conf. Notes on commands that no longer
-- exist in Omarchy Quattro are marked with "QUATTRO:".

local home = os.getenv("HOME")
local ssp = home .. "/.config/hypr/sspaeti"

-- CUSTOM Application bindings
-- $terminal = uwsm app -- $TERMINAL  (use { omarchy = "terminal" } instead)
-- $browser = omarchy-launch-browser
-- The browser flags now live inline on the SUPER+B binding below.


-- use zsh shell by default -> check if omarchy is not touched by this change
hl.unbind("SUPER + RETURN") -- default: Terminal
o.bind("SUPER + RETURN", "Terminal (zsh)", { tui = "zsh" })
hl.unbind("SUPER + SHIFT + RETURN") -- default: Browser
o.bind("SUPER + SHIFT + RETURN", "Neovim", { tui = "nvim" })
hl.unbind("SUPER + SHIFT + N") -- default: Editor
o.bind("SUPER + SHIFT + N", "Neovim", { tui = "nvim" })

hl.unbind("SUPER + O") -- default: Pop window out (float & pin)
o.bind("SUPER + O", "Files (Sync)", { launch = "nautilus --new-window " .. home .. "/Simon/Sync/" })
hl.unbind("SUPER + SHIFT + O") -- default: Obsidian
-- NOTE: do NOT use { tui = ... } here. That helper shell-quotes its value into a
-- SINGLE argument, but omarchy-launch-tui expects `<command> [args...]` as
-- separate ones -- it runs `-e "$1" "${@:2}"` and derives the app-id from
-- `basename $1`. A multi-word value lands entirely in $1 and fails to exec.
-- Passing the raw string lets the shell split it, giving app-id org.omarchy.yazi.
-- The old `zsh -c "yazi ~/..."` wrapper existed only to expand ~; yazi takes the
-- path directly.
o.bind("SUPER + SHIFT + O", "Yazi (Sync)", "omarchy-launch-tui yazi " .. home .. "/Simon/Sync")
o.bind("SUPER + B", "Brave", { launch = "brave --new-window --ozone-platform=wayland --force-device-scale-factor=1.0", focus = "brave-browser" })
o.bind("SUPER + Z", "Zen browser", { launch = "zen-browser", focus = "zen" })

hl.unbind("SUPER + SLASH") -- default: Monitor scaling up
o.bind("SUPER + SLASH", "1Password", { launch = "1password" })

-- music and audio
o.bind("SUPER + M", "Email (tmux)", ssp .. "/jump-to-email-tmux.sh") -- launching neomd
hl.unbind("SUPER + SHIFT + M") -- default: Music (Spotify)
o.bind("SUPER + SHIFT + M", "Toggle audio output", ssp .. "/toggle-audio.sh")
o.bind(
  "SUPER + CTRL + M",
  "Toggle Mute",
  [[pamixer --toggle-mute && notify-send "Audio" "$(pamixer --get-mute | grep -q 'true' && echo '🔇 Muted' || echo '🔊 Unmuted')" -t 2000]]
)

-- QUATTRO: omarchy-swayosd-client is gone; volume now goes through
-- omarchy-audio-output-volume (it drives the Omarchy OSD itself).
hl.unbind("SUPER + comma") -- default: Dismiss last notification
o.bind("SUPER + comma", "Volume down", "omarchy-audio-output-volume lower", { locked = true, repeating = true })
o.bind("SUPER + PERIOD", "Volume up", "omarchy-audio-output-volume raise", { locked = true, repeating = true })

-- Sound/Music
-- QUATTRO: swayosd --playerctl -> omarchy-shell media
hl.unbind("SUPER + CTRL + P") -- default: Power panel
o.bind("SUPER + CTRL + P", "Play", "omarchy-shell media playPause", { locked = true })
hl.unbind("SUPER + RIGHT") -- default: Focus on right window
o.bind("SUPER + RIGHT", "Next track", "omarchy-shell media next", { locked = true })
hl.unbind("SUPER + LEFT") -- default: Focus on left window
o.bind("SUPER + LEFT", "Previous track", "omarchy-shell media previous", { locked = true })

-- Shortcuts for system settings : replaced by default omarchy (SUPER CTRL + W, B, A)

-- o.bind("SUPER + A", "Activity", { tui = "btop" })
hl.unbind("SUPER + A")
hl.unbind("SUPER + SHIFT + A") -- default: ChatGPT
o.bind("SUPER + SHIFT + A", "Activity", { tui = "btop" })
o.bind("SUPER + D", "Docker", { tui = "lazydocker" })

-- keyboard switch
hl.unbind("SUPER + BACKSPACE") -- default: Toggle window transparency
o.bind(
  "SUPER + ALT + BACKSPACE",
  "Toggle Keyboard",
  [[MSG=$(]] .. ssp .. [[/switch-keyboard) && notify-send "⌨️ Keyboard" "$MSG"]]
)

-- OMARCHY settings and overwrites
hl.unbind("SUPER + CTRL + K") -- default: Herdr keybindings
o.bind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")

hl.unbind("SUPER + ESCAPE") -- default: System menu
o.bind("SUPER + ESCAPE", "Power menu", ssp .. "/omarchy-system-menu")

-- omarchy menu
o.bind("SUPER + CTRL + ALT + SPACE", "Omarchy menu (custom)", ssp .. "/omarchy-menu")
-- fix for using SUPER ESC on KBDFans Keyboard
o.bind("SUPER + grave", "Power menu", ssp .. "/omarchy-system-menu")

-- Control scratchpad
-- o.bind("SUPER + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
-- o.bind("SUPER + ALT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- keep awake
hl.unbind("SUPER + CTRL + I") -- default: Toggle locking on idle
o.bind_toggle("SUPER + SHIFT + ESCAPE", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + SHIFT + grave", "Toggle locking on idle", "idle")
hl.unbind("SUPER + CTRL + L") -- default: Lock system
o.bind("SUPER + CTRL + L", "Locking computer", ssp .. "/omarchy-system-lock-wrapper.sh")
-- Also check out ~/.dotfiles/helpers/bin/caffeinate to turn off for Xminuts with `caffeinate 30` or `caffeinate off`

-- QUATTRO: the hyprctl setprop one-liner is now a shipped command.
hl.unbind("SUPER + SHIFT + ALT + B") -- default: Browser (private)
o.bind("SUPER + SHIFT + ALT + B", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")

o.bind("SUPER + N", "Obsidian", { launch = "obsidian", focus = "obsidian" })
-- o.bind("SUPER + N", "Obsidian", { launch = "obsidian --disable-gpu", focus = "obsidian" })

hl.unbind("SUPER + SHIFT + S") -- default: Google Maps
o.bind("SUPER + SHIFT + S", "Signal", { launch = "signal-desktop" })
-- o.bind("SUPER + SHIFT + W", "WhatsApp", { webapp = "https://web.whatsapp.com/" })
-- o.bind("SUPER + CTRL + S", "Google Messages", { webapp = "https://messages.google.com/web/conversations" })

hl.unbind("SUPER + CTRL + C") -- default: Capture menu
o.bind("SUPER + CTRL + C", "Morgen", { launch = "morgen", focus = "Morgen" })

hl.unbind("SUPER + CTRL + SPACE") -- default: Background switcher
-- Edit the emoji list here: ~/.config/omarchy/plugins/sspaeti.emojis/emojis.json
-- Enter/click copies the emoji (wl-copy, paste manually with Ctrl+V); Shift+Enter/Shift+Click types it directly via wtype.
o.bind("SUPER + CTRL + SPACE", "Emoji picker", "omarchy-shell shell toggle sspaeti.emojis")
hl.unbind("SUPER + ALT + SHIFT + F") -- default: File manager (cwd) -- NOTE: hl.unbind matches the modifier order used by the default binding
o.bind("SUPER + SHIFT + ALT + F", "Fuzzy file content", ssp .. "/fuzzy-file-content.sh")
-- o.bind("SUPER + SHIFT + F", "Fuzzy file names", ssp .. "/fuzzy-file-names.sh")
hl.unbind("SUPER + F") -- default: Full screen
o.bind("SUPER + F", "Force full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.unbind("SUPER + SHIFT + F") -- default: File manager
o.bind("SUPER + SHIFT + F", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.unbind("SUPER + ALT + F") -- default: Full width
-- o.bind("SUPER + CTRL + ALT + SHIFT + F", "Screenshot browser", { launch = "kitty --title='Screenshot Browser' -e " .. ssp .. "/image-browser/screenshot-browser-gum.sh" })
-- QUATTRO: `fullscreenstate 0 2` is now shipped as a toggle command.
o.bind("SUPER + ALT + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")

-- Clipboard
-- o.bind("SUPER + SHIFT + C", "Clipboard", "kitty --class clipse -e clipse")
-- QUATTRO: walker is gone from the launcher path; clipboard is an Omarchy menu.
hl.unbind("SUPER + SHIFT + C") -- default: Calendar (web app)
o.bind("SUPER + SHIFT + C", "Clipboard", "omarchy-menu-clipboard")
hl.unbind("SUPER + CTRL + F") -- default: Tiled full screen
-- QUATTRO: no walker `-m files` equivalent. fuzzy-file-names.sh rebuilds it by
-- prompting for a term, then priming a yazi instance with `ya emit-to <id>
-- search_do <term> --via=fd` -- so you get real previews (images, PDFs, and the
-- duckdb previewer from yazi.toml) plus yazi's native open/reveal keys.
-- NOTE: no omarchy-launch-tui wrapper here -- the script opens its own terminal.
-- Floating size for org.omarchy.finder is set in looknfeel.lua.
o.bind("SUPER + CTRL + F", "Search Files (Finder)", ssp .. "/fuzzy-file-names.sh")
-- Same finder, but when you don't know the name: drops straight into yazi's
-- built-in fzf plugin (its own `z` key) for live fuzzy-as-you-type, then yazi
-- reveals the pick with a full preview. fd feeds fzf via FZF_DEFAULT_COMMAND.
o.bind("SUPER + CTRL + SHIFT + F", "Browse Files (fuzzy)", ssp .. "/fuzzy-file-names.sh browse")

-- notifications restore
-- QUATTRO: mako is gone; notifications live in the Omarchy shell.
o.bind("SUPER + bracketleft", "Notification history", "omarchy-shell notifications showHistory")
o.bind("SUPER + bracketright", "Dismiss notification", "omarchy-shell notifications dismissOne")

-- Printscreens / Screenshots - TODO: Check orignial Omarchy shell if it has updated from time to time
-- added post script to do the OCR - but using omarchy orginal for now below
-- o.bind("SUPER + ALT + P", "Screenshot", ssp .. "/omarchy-capture-screenshot")
-- o.bind("SUPER + ALT + SHIFT + P", "Screenshot (window)", ssp .. "/omarchy-capture-screenshot window")
-- o.bind("SUPER + ALT + CTRL + P", "Screenshot (raw)", "grim ...")

-- Captures omarchy original (with post-processing wrapper)
o.bind("SUPER + ALT + P", "Screenshot", ssp .. "/omarchy-capture-screenshot-wrapper.sh")
o.bind("SUPER + ALT + SHIFT + P", "Screenshot", ssp .. "/omarchy-capture-screenshot-wrapper.sh smart clipboard")
-- o.bind("ALT + PRINT", "Screenrecording", "omarchy-menu screenrecord")
-- o.bind("SUPER + PRINT", "Color picking", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + ALT + C", "Cut-out image", ssp .. "/omapic-capture-cut.sh")

-- Screenshot with Satty -> Editt workflow
o.bind("SUPER + ALT + CTRL + P", "Screenshot -> Satty -> Editt", ssp .. "/screenshot-edit.sh")

local grim_screenshot = "grim " .. home .. [[/Pictures/Printscreen/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png && ]] .. ssp .. "/image-browser/auto-organize-screenshot.sh"

-- o.bind("PRINT", "Screenshot", ssp .. "/omarchy-capture-screenshot output")
hl.unbind("PRINT") -- default: Screenshot
o.bind("PRINT", "Screenshot (raw)", grim_screenshot)
o.bind("SUPER + ALT + CTRL + SHIFT + P", "Screenshot (raw)", grim_screenshot)

-- Print videos - Screen recordings
o.bind("SUPER + ALT + bracketleft", "Screen record a region", "omarchy-capture-screenrecording region")
o.bind("SUPER + ALT + SHIFT + bracketleft", "Screen record a region with audio", "omarchy-capture-screenrecording region audio")
o.bind("SUPER + CTRL + bracketleft", "Screen record display", "omarchy-capture-screenrecording output")
o.bind("SUPER + CTRL + SHIFT + bracketleft", "Screen record display with audio", "omarchy-capture-screenrecording output audio")
-- kdenlive: no transformation needed when import, but bigger size
o.bind("SUPER + ALT + CTRL + bracketleft", "Screen record for Kdenlive", ssp .. "/omarchy-capture-screenrecording-kdenlive --with-desktop-audio")

hl.unbind("SUPER + G") -- default: Toggle window grouping
hl.unbind("SUPER + SHIFT + SPACE") -- default: Toggle top bar
-- QUATTRO: waybar is gone; the Omarchy shell bar has its own toggle.
o.bind_toggle("SUPER + G", "Toggle top bar", "bar")
-- QUATTRO: omarchy-theme-next is gone; the switcher is the closest thing.
o.bind("SUPER + SHIFT + ALT + CTRL + G", "Theme switcher", "omarchy-theme-switcher")

-- Theme and background
hl.unbind("SUPER + T") -- default: Toggle window floating/tiling
hl.unbind("SUPER + CTRL + T") -- default: Activity (btop)
-- o.bind("SUPER + CTRL + T", "Pick new theme", ssp .. "/omarchy-menu-wrapper theme")
o.bind("SUPER + ALT + T", "Theme menu", "omarchy-menu toggle theme")
-- toggle to my personal background images
o.bind("SUPER + CTRL + T", "Background mode switch", ssp .. "/bg-mode-toggle.sh switch")
o.bind("SUPER + CTRL + SHIFT + T", "Next background", ssp .. "/bg-mode-toggle.sh next")

-- Extra bindings
hl.unbind("SUPER + W") -- default: Close window
hl.unbind("SUPER + SHIFT + W") -- default: Omawrite
o.bind("SUPER + SHIFT + W", "Claude", { webapp = "https://claude.ai" })
-- o.bind("SUPER + CTRL + A", "Claude", { webapp = "https://claude.ai" })
-- o.bind("SUPER + ALT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
-- o.bind("SUPER + SHIFT + A", "Grok", { webapp = "https://grok.com" })
-- o.bind("SUPER + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
-- o.bind("SUPER + E", "Email", { webapp = "https://app.hey.com" })
hl.unbind("SUPER + SHIFT + Y") -- default: YouTube
o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
hl.unbind("SUPER + SHIFT + X") -- default: X
o.bind("SUPER + SHIFT + X", "Bluesky", { webapp = "https://blue.ssp.sh" })
-- o.bind("SUPER + SHIFT + X", "Bluesky compose", { webapp = "https://bsky.app/intent/compose," })

-- Monitor and Screen resolution shorcuts
-- -> in ~/.config/hypr/monitors.lua

-- Extra autostart processes -> in ~/.config/hypr/autostart.lua

-- Extra env variables
-- Note: You must relaunch Hyprland after changing envs (use Super+Esc, then Relaunch)
-- hl.env("MY_GLOBAL_ENV", "setting")

-- Cyrcle light for videocall
hl.unbind("SUPER + SHIFT + Z")
o.bind("SUPER + SHIFT + Z", "Edge light", home .. "/.local/bin/wayland-edge-light-videocalls/launch-edgelight.sh")
-- o.bind("SUPER + SHIFT + ALT + Z", "Position edge light", home .. "/.local/bin/wayland-edge-light-videocalls/position-window-in-border.sh")
