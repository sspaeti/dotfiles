# Linking dotfiles with Stow
#
.DEFAULT_GOAL := arch

# Shared packages (work on both platforms)
SHARED = nvim nvim-wp zsh tmux kitty ghostty lazygit k9s btop fzf helix presenterm ruff sesh mutt msmtp lazydocker yazi

# Platform-specific packages
MACOS = karabiner yabai skhd alfred
LINUX = kanata hypr walker waybar obsidian mako mise XCompose

.PHONY: mac linux shared clean

# Install shared dotfiles
shared:
	stow $(SHARED)

# TODO: Does not yet work on Mac, just the preparation
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

arch:
	pacman -Qe > pacman.txt
