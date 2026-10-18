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

DRY ?=

# Default target
.PHONY: help
help:
	@echo "micro-journal Makefile (run from the laptop, Pi = mj)"
	@echo "====================================================="
	@echo "  sync-secondbrain-to-mj : Push SecondBrain (*.md, *.txt only) to the Pi, --delete on Pi side"
	@echo "  nvim-from-mj           : Backup Pi ~/.config/nvim -> configs/nvim (git keeps history)"
	@echo "  nvim-to-mj             : Deploy configs/nvim -> Pi ~/.config/nvim (timestamped backup on Pi first)"
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
