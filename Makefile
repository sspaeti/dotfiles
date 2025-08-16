# Linking dotfiles with Stow
#

# Shared packages (work on both platforms)
SHARED = nvim nvim-wp zsh tmux kitty ghostty lazygit k9s btop fzf helix presenterm ruff sesh

# Platform-specific packages
MACOS = karabiner yabai skhd alfred
LINUX = kanata hypr walker waybar obsidian mako

.PHONY: mac linux shared clean



# obsidian:
# 	cp ~/Simon/SecondBrain/.obsidian/workspace $git/general/dotfiles/obsidian/workspace
# 	cp ~/Simon/SecondBrain/.obsidian/plugins $git/general/dotfiles/obsidian/plugins
# 	cp ~/Simon/SecondBrain/.obsidian/workspace.json $git/general/dotfiles/obsidian/workspace.json
# 	cp ~/Simon/SecondBrain/.obsidian/hotkeys.json $git/general/dotfiles/obsidian/hotkeys.json
# 	cp ~/Simon/SecondBrain/.obsidian/core-plugins.json $git/general/dotfiles/obsidian/core-plugins.json
# 	cp ~/Simon/SecondBrain/.obsidian/community-plugins.json $git/general/dotfiles/obsidian/community-plugins.json
# 	cp ~/Simon/SecondBrain/.obsidian/appearance.json $git/general/dotfiles/obsidian/appearance.json
# 	cp ~/Simon/SecondBrain/.obsidian/app.json $git/general/dotfiles/obsidian/app.json
# 	cp ~/Simon/SecondBrain/.obsidian/.vimrc $git/general/dotfiles/obsidian/.vimrc
# 	cp -r ~/Simon/SecondBrain/.obsidian/snippets/* $git/general/dotfiles/obsidian/snippets/
# 	cp -r ~/Simon/SecondBrain/.obsidian/exports/* $git/general/dotfiles/obsidian/exports/

# Install shared dotfiles
shared:
	stow $(SHARED)

# Install macOS-specific setup
mac: shared
	stow $(MACOS)

# Install Linux-specific setup  
linux: shared
	stow $(LINUX)

# Remove all symlinks
clean:
	stow -D $(SHARED) $(MACOS) $(LINUX)

# Remove only macOS symlinks
clean-mac:
	stow -D $(MACOS)

# Remove only Linux symlinks
clean-linux:
	stow -D $(LINUX)

install-kanata:
	sudo cp systemd/.config/systemd/system/kanata.service /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable kanata.service

uninstall-kanata:
	sudo systemctl stop kanata.service
	sudo systemctl disable kanata.service
	sudo rm /etc/systemd/system/kanata.service
