# Makefile for the micro-journal (Raspberry Pi Zero 2W typewriter)
#
# Run from the laptop. The Pi is reachable as `mj` via ~/.ssh/config
# (its network must be on: scripts/startnetwork.sh on the Pi).
#
# Dry-run any rsync target with DRY=n, e.g.  make nvim-to-mj DRY=n

# Paths on the Pi
PI_SECONDBRAIN_DIR = ~/microjournal/documents/SecondBrain
PI_NVIM_CONFIG_DIR = ~/.config/nvim

# Paths on the laptop
SECONDBRAIN_DIR = $(HOME)/Simon/SecondBrain
NVIM_REPO_DIR   = $(CURDIR)/configs/nvim

# What dots-from-mj / dots-to-mj cover: ~/.config/<app> <-> configs/<app>, ~/<file> <-> dotfiles/<file>
CONFIG_APPS = nvim yazi lazygit ranger
DOT_FILES   = .bashrc .aliases.shrc
RSYNC_EXCLUDES = --exclude='.git' --exclude='*.bak-*' --exclude='*.orig-*'

DRY ?=

# Default target
.PHONY: help
help:
	@echo "micro-journal Makefile (run from the laptop, Pi = mj)"
	@echo "====================================================="
	@echo "  sync-secondbrain-to-mj : Push SecondBrain (*.md, *.txt only) to the Pi, --delete on Pi side"
	@echo "  dots-from-mj           : Backup Pi configs ($(CONFIG_APPS)) + $(DOT_FILES) -> configs/ and dotfiles/"
	@echo "  dots-to-mj             : Deploy configs/ + dotfiles/ -> Pi (timestamped backup on Pi first)"
	@echo "  nvim-from-mj           : Same as dots-from-mj, nvim only"
	@echo "  nvim-to-mj             : Same as dots-to-mj, nvim only"
	@echo "  install                : Install required packages from install/wp-packages.txt (run on the Pi)"
	@echo "  help                   : Show this help"
	@echo ""
	@echo "  Add DRY=n to any rsync target for a dry run."

# SecondBrain: laptop -> Pi, one-way. Notes created on the Pi inside
# SecondBrain are deleted by --delete; ~/microjournal/writing is untouched.
.PHONY: sync-secondbrain-to-mj
sync-secondbrain-to-mj:
	@echo "=== SecondBrain -> mj ==="
	rsync -avz$(DRY) --delete --include="*.md" --include="*.txt" --include="*/" --exclude="*" "$(SECONDBRAIN_DIR)/" mj:$(PI_SECONDBRAIN_DIR)/
	@echo "Writing last-loaded.md with timestamp..."
	@ssh mj "echo '$$(date)' > $(PI_SECONDBRAIN_DIR)/last-loaded.md"
	@echo "=== done ==="

# All Pi configs: Pi -> repo. configs/<app> and dotfiles/ are the Pi's canonical configs.
.PHONY: dots-from-mj
dots-from-mj:
	@for a in $(CONFIG_APPS); do \
		echo "=== Pi ~/.config/$$a -> configs/$$a ==="; \
		rsync -ai$(DRY) --delete $(RSYNC_EXCLUDES) mj:~/.config/$$a/ "$(CURDIR)/configs/$$a/" | grep -v '^\.d' || true; \
	done
	@for f in $(DOT_FILES); do \
		echo "=== Pi ~/$$f -> dotfiles/$$f ==="; \
		rsync -ai$(DRY) mj:~/$$f "$(CURDIR)/dotfiles/$$f" || true; \
	done
	@echo "=== done, review with: git -C $(CURDIR) status --short configs dotfiles ==="

# All Pi configs: repo -> Pi. Backs up the Pi's copies first.
.PHONY: dots-to-mj
dots-to-mj:
	@ssh mj 'B=~/.config-backup-$$(date +%F-%H%M); mkdir -p $$B; for a in $(CONFIG_APPS); do [ -d ~/.config/$$a ] && cp -a ~/.config/$$a $$B/; done; for f in $(DOT_FILES); do [ -f ~/$$f ] && cp -a ~/$$f $$B/; done; echo "Pi backup: $$B"'
	@for a in $(CONFIG_APPS); do \
		echo "=== configs/$$a -> Pi ~/.config/$$a ==="; \
		rsync -ai$(DRY) --delete $(RSYNC_EXCLUDES) "$(CURDIR)/configs/$$a/" mj:~/.config/$$a/ | grep -v '^\.d' || true; \
	done
	@for f in $(DOT_FILES); do \
		echo "=== dotfiles/$$f -> Pi ~/$$f ==="; \
		rsync -ai$(DRY) "$(CURDIR)/dotfiles/$$f" mj:~/$$f || true; \
	done
	@echo "=== done ==="

# nvim config: Pi -> repo. configs/nvim is the Pi's canonical config.
# nvim/.config/nvim-wp (laptop writing mode) has diverged; do not deploy it to the Pi.
.PHONY: nvim-from-mj
nvim-from-mj:
	@echo "=== Pi $(PI_NVIM_CONFIG_DIR) -> $(NVIM_REPO_DIR) ==="
	rsync -av$(DRY) --delete --exclude=".git" mj:$(PI_NVIM_CONFIG_DIR)/ "$(NVIM_REPO_DIR)/"
	@echo "=== done, review with: git -C $(CURDIR) diff --stat configs/nvim ==="

# nvim config: repo -> Pi. Backs up the Pi's current config first.
.PHONY: nvim-to-mj
nvim-to-mj:
	@echo "=== $(NVIM_REPO_DIR) -> Pi $(PI_NVIM_CONFIG_DIR) ==="
	@ssh mj 'cp -a $(PI_NVIM_CONFIG_DIR) $(PI_NVIM_CONFIG_DIR)-backup-$$(date +%F-%H%M) && echo "Pi backup: $(PI_NVIM_CONFIG_DIR)-backup-$$(date +%F-%H%M)"'
	rsync -av$(DRY) --delete --exclude=".git" "$(NVIM_REPO_DIR)/" mj:$(PI_NVIM_CONFIG_DIR)/
	@echo "=== done ==="

# Install packages (run this one on the Pi)
.PHONY: install
install:
	@echo "Installing required packages..."
	@cd install && ./install-wp.sh
	@echo "Installation complete!"
