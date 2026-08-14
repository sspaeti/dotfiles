-- Extra autostart processes.
-- o.launch_on_start("my-service")
--
-- Converted 1:1 from the old autostart.conf.
--   o.launch_on_start(cmd)  ==  exec-once = uwsm app -- cmd
--   o.exec_on_start(cmd)    ==  exec-once = cmd

local home = os.getenv("HOME")
local ssp = home .. "/.config/hypr/sspaeti"

-- Additional Autostart sspaeti:
-- Replaced now with Walker clipboard. Before temporarly until
-- https://github.com/basecamp/omarchy/issues/126 is fixed
-- o.launch_on_start("clipse -listen")

-- daylight: since v.11 there is daylight included
-- o.exec_on_start("wlsunset -l 47.4095 -L 8.5514 -t 3500 -T 6500")
-- QUATTRO: hyprsunset is built into Hyprland now and Omarchy drives it via
-- `omarchy toggle nightlight` / hyprsunset.conf. Starting a second standalone
-- hyprsunset process fights with it, so this stays off. Re-enable only if
-- nightlight actually stops working.
-- o.launch_on_start("hyprsunset")

-- start terminal, obsidian, browser
o.exec_on_start(ssp .. "/autostart-apps.sh")

-- Restore personal background if in personal mode (overrides Omarchy's swaybg)
o.exec_on_start(ssp .. "/bg-mode-toggle.sh restore")

-- Morgen calendar: do NOT launch it here.
-- QUATTRO/uwsm now runs XDG autostart entries, so ~/.config/autostart/morgen.desktop
-- ("Exec=/opt/Morgen/morgen --hidden") already starts it in the background as
-- app-morgen@autostart.service. Morgen is single-instance, so a second
-- `uwsm app -- morgen` here did not start a second process -- it just told the
-- running one to un-hide, which is why a Morgen window popped up at login.
-- Verify with: systemctl --user status app-morgen@autostart.service
-- o.launch_on_start("morgen")

-- GPU guard: one-shot check ~20s after login. Warns if the GPU is already
-- degraded this boot, or if kernel/mesa/firmware changed and is untested.
-- Silent when everything is fine. No background process.
o.exec_on_start(ssp .. "/gpu-checks/gpu-session-check")
