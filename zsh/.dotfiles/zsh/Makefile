# Encrypted secrets management (age + gnome-keyring).
#
#   make keygen                  one-time: create age key, private part -> keyring, public -> .secrets.pub
#   make migrate                 one-time: encrypt existing plaintext .secrets / .secrets_work -> *.age
#   make edit [FILE=.secrets]    decrypt to FILE_edit, open $EDITOR, re-encrypt, shred FILE_edit
#   make add KEY=NAME [FILE=..]  append `export NAME='value'` (value prompted, hidden), no plaintext on disk
#   make purge-plaintext         after verifying a new shell works: shred the old plaintext files
#
# The private key never touches disk: it lives in the keyring and is read via
# process substitution each time. The zsh loader (secrets.zsh) picks up changes
# automatically because it re-decrypts whenever the .age file is newer than its cache.

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

FILES ?= .secrets .secrets_work
FILE  ?= .secrets
PUB   := .secrets.pub
EDITOR ?= vi

SERVICE ?= age-secrets
KEY_LOOKUP = secret-tool lookup service $(SERVICE) key default
DECRYPT    = age -d -i <($(KEY_LOOKUP))
ENCRYPT    = age -r "$$(cat $(PUB))"

.PHONY: help keygen migrate edit add purge-plaintext check

help:
	@grep -E '^#   make' $(MAKEFILE_LIST) | sed 's/^#   //'

check:
	@command -v age >/dev/null || { echo "age not installed: sudo pacman -S age"; exit 1; }
	command -v secret-tool >/dev/null || { echo "secret-tool not installed: sudo pacman -S libsecret"; exit 1; }
	$(KEY_LOOKUP) >/dev/null 2>&1 || { echo "no age key in keyring: run 'make keygen' first"; exit 1; }
	test -f $(PUB) || { echo "missing $(PUB): run 'make keygen' first"; exit 1; }

keygen:
	@command -v age-keygen >/dev/null || { echo "age not installed: sudo pacman -S age"; exit 1; }
	if $(KEY_LOOKUP) >/dev/null 2>&1; then
		echo "an age key already exists in the keyring (service=$(SERVICE) key=default). Refusing to overwrite."
		exit 1
	fi
	key="$$(age-keygen 2>/dev/null)"
	printf '%s\n' "$$key" | grep '^AGE-SECRET-KEY-' | tr -d '\n' \
		| secret-tool store --label='age secrets key (~/.dotfiles/zsh)' service $(SERVICE) key default
	printf '%s\n' "$$key" | age-keygen -y > $(PUB)
	unset key
	echo "private key stored in keyring, public key in $(PUB):"
	cat $(PUB)

migrate: check
	for f in $(FILES); do
		if [[ -f $$f.age ]]; then echo "skip $$f: $$f.age already exists"; continue; fi
		if [[ ! -f $$f ]]; then echo "skip $$f: no plaintext file"; continue; fi
		$(ENCRYPT) -o $$f.age $$f
		echo "encrypted $$f -> $$f.age"
	done
	echo
	echo "Now open a NEW shell and check a variable works (e.g. echo \$$SOME_VAR)."
	echo "When satisfied: make purge-plaintext"

edit: check
	tmp=$(FILE)_edit
	trap 'shred -u "$$tmp" 2>/dev/null || true' EXIT
	umask 077
	if [[ -f $(FILE).age ]]; then $(DECRYPT) $(FILE).age > "$$tmp"; else : > "$$tmp"; fi
	before="$$(sha256sum "$$tmp")"
	$(EDITOR) "$$tmp"
	if [[ "$$(sha256sum "$$tmp")" == "$$before" ]]; then
		echo "no changes"; exit 0
	fi
	$(ENCRYPT) -o $(FILE).age.tmp "$$tmp" && mv -f $(FILE).age.tmp $(FILE).age
	echo "saved $(FILE).age. Run: source ~/.zshrc  (or open a new shell)"

add: check
	@test -n "$(KEY)" || { echo "usage: make add KEY=NAME [FILE=.secrets]"; exit 1; }
	read -rs -p "value for $(KEY): " val; echo
	esc="$${val//\'/\'\\\'\'}"
	{
		if [[ -f $(FILE).age ]]; then $(DECRYPT) $(FILE).age; fi
		printf "export %s='%s'\n" "$(KEY)" "$$esc"
	} | $(ENCRYPT) -o $(FILE).age.tmp && mv -f $(FILE).age.tmp $(FILE).age
	unset val esc
	echo "added $(KEY) to $(FILE).age. Run: source ~/.zshrc  (or open a new shell)"

purge-plaintext: check
	for f in $(FILES); do
		[[ -f $$f ]] || continue
		[[ -f $$f.age ]] || { echo "skip $$f: no $$f.age, not deleting plaintext"; continue; }
		$(DECRYPT) $$f.age | cmp -s - $$f || { echo "skip $$f: $$f.age content differs from plaintext, not deleting"; continue; }
		read -r -p "shred plaintext $$f? [y/N] " ans
		[[ $$ans == y ]] && shred -u $$f && echo "shredded $$f" || echo "kept $$f"
	done
