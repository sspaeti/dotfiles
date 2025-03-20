# Makefile for Raspberry Pi Pico Typewriter Syncing

# Path definitions for Pi
PI_WRITING_DIR = $(HOME)/microjournal/writing
PI_NVIM_CONFIG_DIR = $(HOME)/config/nvim
PI_CONFIG_DIR = $(HOME)/microjournal/config
PI_SECONDBRAIN_DIR = ~/microjournal/documents/SecondBrain

# Mac connection details
MAC_USER = your_mac_username
MAC_HOST = your_mac_hostname_or_ip
PI_USER = microjournal
PI_HOST = mj
# Path definitions for Mac (remote)
MAC_NVIM_CONFIG_GIT = $(MAC_USER)@$(MAC_HOST):$(HOME)/Documents/git/general/dotfiles/nvim-wp
MAC_TYPEWRITER_CONFIG = $(MAC_USER)@$(MAC_HOST):$(HOME)/Documents/git/general/dotfiles/nvim-wp/micro-journal-scripts
MAC_WRITING_DIR = $(MAC_USER)@$(MAC_HOST):$(HOME)/Simon/SecondBrain/⚛️\ Areas/✍🏻\ Writing/micro-journal
MAC_SECONDBRAIN_DIR = ~/Simon/SecondBrain

# Default target
.PHONY: help
help:
	@echo "Typewriter Sync Makefile"
	@echo "========================"
	@echo "Available targets:"
	@echo "  to-mac       : Sync writing from Pi to Mac"
	@echo "  from-mac     : Sync configs and SecondBrain from Mac to Pi"
	@echo "  sync-all     : Run both to-mac and from-mac syncs"
	@echo "  install      : Install required packages from wp-packages.txt"
	@echo "  network-on   : Start network connection"
	@echo "  network-off  : Stop network connection"
	@echo "  time-sync    : Synchronize system time"
	@echo "  help         : Show this help information"

# Network management
# .PHONY: network-on
# network-on:
# 	@echo "Starting network connection..."
# 	@./startnetwork.sh
# 	@echo "Waiting for network connection..."
# 	@for i in $$(seq 1 15); do \
# 		if ping -c 1 google.com > /dev/null 2>&1; then \
# 			echo "Network is ready."; \
# 			break; \
# 		fi; \
# 		if [ $$i -eq 15 ]; then \
# 			echo "WARNING: Network may not be fully ready, but continuing..."; \
# 		fi; \
# 		sleep 1; \
# 	done

# .PHONY: network-off
# network-off:
# 	@echo "Stopping network connection..."
# 	@./stopnetwork.sh

# Time synchronization
.PHONY: time-sync
time-sync: network-on
	@echo "Synchronizing system time..."
	@sudo ./time.sh

# Sync from Pi to Mac
# .PHONY: to-mac
# to-mac: network-on time-sync
# 	@echo "=== Starting Pi to Mac sync process ==="
# 	@echo "Syncing writing files - writing..."
# 	@rsync -avz --delete "$(PI_WRITING_DIR)/" "$(MAC_WRITING_DIR)/"
# 	@echo "Syncing nvim-wp files..."
# 	@rsync -avz --delete "$(PI_NVIM_CONFIG_DIR)/" "$(MAC_NVIM_CONFIG_GIT)/"
# 	@echo "Writing files sync completed!"
# 	@make -s network-off
# 	@echo "=== Pi to Mac sync process completed successfully! ==="

# Sync from Mac to Pi

.PHONY: sync-secondbrain-to-mj
sync-secondbrain-to-mj: 
	@echo "=== Starting Mac to Pi sync process ==="
	
	@echo "Syncing SecondBrain contents..."
	@rsync -avz --delete --include="*.md" --include="*.txt" --include="*/" --exclude="*" $(MAC_SECONDBRAIN_DIR)/ mj:$(PI_SECONDBRAIN_DIR)/
	@echo "SecondBrain contents sync completed!"

	@echo "Creating last-loaded.md file with timestamp..."
	@ssh mj "echo '$$(date)' > $(PI_SECONDBRAIN_DIR)/last-loaded.md"
	@echo "Timestamp file created!"
	
	@echo "=== Mac to Pi sync process completed successfully! ==="

# Complete sync in both directions
.PHONY: sync-all
sync-all: network-on time-sync to-mac from-mac network-off

# Install packages
.PHONY: install
install:
	@echo "Installing required packages..."
	@cd install && ./install-wp.sh
	@echo "Installation complete!"
