.DEFAULT_GOAL := save
.PHONY: decrypt run urls save clean help

# Default target - decrypt and run newsboat
run: decrypt
	@newsboat

# Decrypt urls.gpg to urls using environment variable
decrypt:
	@if [ -z "$$NEWSBOAT_PASS" ]; then \
		echo "Error: NEWSBOAT_PASS environment variable not set"; \
		exit 1; \
	fi; \
	if [ -f urls.gpg ]; then \
		echo "$$NEWSBOAT_PASS" | gpg --batch --yes --passphrase-fd 0 --quiet --decrypt urls.gpg > urls 2>/dev/null; \
		if [ $$? -eq 0 ]; then \
			echo "✓ Decrypted urls.gpg -> urls"; \
		else \
			echo "Error: Failed to decrypt urls.gpg"; \
			exit 1; \
		fi \
	else \
		echo "Error: urls.gpg not found"; \
		exit 1; \
	fi

urls: decrypt

# Save (encrypt) urls to urls.gpg using environment variable
save:
	@if [ -z "$$NEWSBOAT_PASS" ]; then \
		echo "Error: NEWSBOAT_PASS environment variable not set"; \
		exit 1; \
	fi; \
	if [ -f urls ]; then \
		echo "$$NEWSBOAT_PASS" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 -o urls.gpg urls 2>/dev/null; \
		if [ $$? -eq 0 ]; then \
			echo "✓ Encrypted urls -> urls.gpg"; \
			echo "Ready to commit: cd ~/git/general/dotfiles && git add newsboat/.config/newsboat/urls.gpg && git commit"; \
		else \
			echo "Error: Failed to encrypt urls"; \
			exit 1; \
		fi \
	else \
		echo "Error: urls file not found"; \
		exit 1; \
	fi

# Clean decrypted urls file
clean:
	@rm -f urls
	@echo "✓ Removed decrypted urls file"

# Help message
help:
	@echo "Newsboat Encrypted URLs Management"
	@echo ""
	@echo "Usage:"
	@echo "  make decrypt  - Decrypt urls.gpg to urls (for editing)"
	@echo "  make urls  - Decrypt urls.gpg to urls (for editing)"
	@echo "  make run      - Decrypt and run newsboat"
	@echo "  make save     - Encrypt urls to urls.gpg (default)"
	@echo "  make clean    - Remove decrypted urls file"
	@echo ""
	@echo "Workflow:"
	@echo "  1. make decrypt   # Edit urls file"
	@echo "  2. make save      # Encrypt changes"
	@echo "  3. git add & commit"
	@echo ""
	@echo "Environment variable required:"
	@echo "  NEWSBOAT_PASS - Passphrase for encryption/decryption"
