.DEFAULT_GOAL := sync_status

# Makefile for managing Neomutt sync launchd job

# Variables
PLIST_FILE = ~/Library/LaunchAgents/com.user.neomuttsync.plist
LABEL = com.user.neomuttsync
LOG_FILE = ~/.config/mutt/logs/sync_status.log

# Phony targets
.PHONY: load unload reload status check help sync_status next_run

# Default target
help:
	@echo "Usage:"
	@echo "  make load        - Load the launchd job"
	@echo "  make unload      - Unload the launchd job"
	@echo "  make reload      - Reload the launchd job"
	@echo "  make status      - Check the status of the launchd job"
	@echo "  make check       - Validate the plist file"
	@echo "  make sync_status - Check if a sync is currently running"
	@echo "  make next_run    - Show the next scheduled run time"

# Load the launchd job
load:
	launchctl load $(PLIST_FILE)
	@echo "Launchd job loaded."

# Unload the launchd job
unload:
	launchctl unload $(PLIST_FILE)
	@echo "Launchd job unloaded."

# Reload the launchd job
reload: unload load

# Check the status of the launchd job
status:
	@launchctl list | grep $(LABEL) || echo "Job is not loaded."


# Check the status of the launchd job
status2:
	@echo "Job Status:"
	@launchctl list $(LABEL) || echo "Job is not loaded."
	@echo "\nNext Run Time:"
	@launchctl print $(LABEL) | grep 'next' || echo "Unable to determine next run time."
	@echo "\nLast Exit Status:"
	@launchctl print $(LABEL) | grep 'last exit code' || echo "No exit status available."

# Validate the plist file
check:
	plutil -lint $(PLIST_FILE)

# Check if a sync is currently running
sync_status:
	@if pgrep -f "neomutt_sync.sh" > /dev/null; then \
		echo "Sync is currently running."; \
		ps aux | grep "[n]eomutt_sync.sh"; \
	else \
		echo "No sync is currently running."; \
		echo "Last sync status:"; \
		tail -n 1 $(LOG_FILE); \
	fi

# Show the next scheduled run time
next_run:
	@next_run_time=$$(launchctl list $(LABEL) | awk '/next exit/ {print $$1}'); \
	if [ -n "$$next_run_time" ]; then \
		date -r $$next_run_time; \
	else \
		echo "Unable to determine next run time. Check if the job is loaded."; \
	fi
