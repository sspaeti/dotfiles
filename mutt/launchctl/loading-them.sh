## should be run manaully in mutt wth `S` (sync)
# cp ./offlineimap_sspaeti.plist ~/Library/LaunchAgents/
# launchctl load ~/Library/LaunchAgents/offlineimap_sspaeti.plist

# Should run automatically, not that I have a long startup each time
#
launchctl unload ~/Library/LaunchAgents/initial_screening.plist
rm ~/Library/LaunchAgents/initial_screening.plist

cp ./initial_screening.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/initial_screening.plist
