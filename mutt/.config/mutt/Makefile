.PHONY: loop logs help notmuch-loop notmuch-sync sync notmuch-logs notmuch-screen notmuch-init

.DEFAULT_GOAL := notmuch-loop

# Notmuch mail sync loop with mbsync (default)
notmuch-loop:
	@echo "Starting notmuch mail sync loop (10 minute intervals)..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		~/.config/mutt/notmuch/sync/mbsync_notmuch_sync.sh; \
		echo "Sleeping for 10 minutes..."; \
		sleep 600; \
	done

# Run complete sync once (mbsync → notmuch index → screening → mbsync)
notmuch-sync:
	~/.config/mutt/notmuch/sync/mbsync_notmuch_sync.sh

# Alias for notmuch-sync
sync: notmuch-sync

# Show notmuch sync logs
notmuch-logs:
	tail -f ~/.config/mutt/logs/mbsync_notmuch_sync_status.log

# Show notmuch screening logs
notmuch-screen-logs:
	tail -f ~/.config/mutt/logs/notmuch_screening.log

# Run notmuch screening manually
notmuch-screen:
	~/.config/mutt/notmuch/notmuch_screening.sh

# Initialize notmuch database
notmuch-init:
	@echo "Initializing notmuch database..."
	@echo "Database path: /home/sspaeti/Documents/mutt/sspaeti.com"
	NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config notmuch new

#count emails
count-emails:
	find ~/Documents/mutt/sspaeti.com -type f | wc -l

# Legacy aliases (folder-based system)
loop:
	~/.config/mutt/launchctl/mail_sync_watch.sh --loop

logs:
	tail -f ~/.config/mutt/logs/mail_sync.log

# Show help
help:
	@echo "Mail Sync Makefile commands:"
	@echo ""
	@echo "=== Quick Commands ==="
	@echo "  make sync               - Sync everything once (fetch → screen → sync back)"
	@echo "  make                    - Start continuous sync loop (same as notmuch-loop)"
	@echo ""
	@echo "=== Notmuch (tag-based system - DEFAULT) ==="
	@echo "  make notmuch-loop       - Start notmuch sync loop (10 min intervals)"
	@echo "  make notmuch-sync       - Run complete sync once (same as 'make sync')"
	@echo "  make notmuch-screen     - Run notmuch screening manually"
	@echo "  make notmuch-init       - Initialize/reindex notmuch database"
	@echo ""
	@echo "=== Logs ==="
	@echo "  make notmuch-logs       - Show notmuch sync logs"
	@echo "  make notmuch-screen-logs - Show screening logs"
	@echo "  make count-emails       - Count total emails locally"
	@echo ""
	@echo "=== Legacy (folder-based system) ==="
	@echo "  make loop               - Start old mail sync loop"
	@echo "  make logs               - Show old mail sync logs"
	@echo ""
	@echo "Note: Use Ctrl+C to stop any running sync loop"
