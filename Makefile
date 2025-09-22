# Linking dotfiles with Stow
#
.DEFAULT_GOAL := arch

# Shared packages (work on both platforms)
SHARED = nvim git zsh tmux kitty ghostty lazygit k9s btop fzf helix presenterm ruff sesh mutt msmtp lazydocker yazi

# Platform-specific packages
MACOS = karabiner yabai skhd alfred
LINUX = kanata hypr walker waybar obsidian mako mise XCompose clipse OBS

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
	pacman -Qqm > yay_aur.txt
	pacman -Qqen | grep -v -f <(pacman -Qqm) > pacman.txt
	pacman -Qen | grep -v -f <(pacman -Qqm) > pacman-versions.txt

oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" #install oh-my-zsh
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

#TODO
post-omarchy-install:
	arch-install
	cp ~/stow/.stowrc ~/.stowrc
	linux
	oh-my-zsh
	sudo systemctl enable --now sshd
	rsync TODO _post-scripts/rsync.sh (take from readme)
	sudo systemctl enable --now sshd
	install-kanata



arch-install:
	sudo pacman -S --needed - < pacman.txt
	yay -S --needed --noconfirm - < yay_aur.txt

tmux-init-install:
	rm -rf ~/.tmux/plugins
	tmux new-session -d && tmux kill-session
	mkdir -p ~/.tmux/plugins
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
	~/.tmux/plugins/tpm/bin/install_plugins
