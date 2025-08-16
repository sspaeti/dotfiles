.PHONY: start logs help

.DEFAULT_GOAL := loop

# Start mail sync
loop:
	~/.config/mutt/launchctl/mail_sync_watch.sh --loop

# Show logs
logs:
	tail -f ~/.config/mutt/logs/mail_sync.log

# Show help
help:
	@echo "Mail Sync Makefile commands:"
	@echo "  make start  - Start mail sync loop"
	@echo "  make logs   - Show mail sync logs"
	@echo ""
	@echo "Note: Use Ctrl+C to stop the sync"
