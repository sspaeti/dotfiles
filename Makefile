# Linking dotfiles with Stow
#
.DEFAULT_GOAL := arch

# Shared packages (work on both platforms)
SHARED = nvim git zsh tmux kitty ghostty lazygit k9s btop fzf helix presenterm ruff sesh mutt msmtp lazydocker yazi

# Platform-specific packages
MACOS = karabiner yabai skhd alfred
LINUX = kanata hypr walker waybar obsidian mako mise XCompose clipse

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
	pacman -Qqen | grep -v -f <(pacman -Sl chaotic-aur | awk '{print $$2}') > pacman.txt
	pacman -Qen | grep -v -f <(pacman -Sl chaotic-aur | awk '{print $$2}') > pacman-versions.txt
	{ pacman -Qqm; pacman -Qqen | grep -f <(pacman -Sl chaotic-aur | awk '{print $$2}'); } | sort -u > yay_aur.txt


#TODO
post-omarchy-install:
	arch-install
	cp ~/stow/.stowrc ~/.stowrc
	linux
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sudo systemctl enable --now sshd
	rsync TODO _post-scripts/rsync.sh (take from readme)
	sudo systemctl enable --now sshd
	install-kanata





arch-install:
	sudo pacman -S --needed - < pacman.txt
	yay -S --needed --noconfirm - < yay_aur.txt
