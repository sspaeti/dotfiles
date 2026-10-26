# Encrypted secrets loader (age + OS keyring).
#
# Each NAME in _sec_files is loaded from NAME.age, decrypted once per login
# into a RAM-only cache ($XDG_RUNTIME_DIR, tmpfs, wiped on logout/reboot).
# Later shells just source the cache. The cache is refreshed automatically
# whenever NAME.age is newer than it (i.e. after `make edit` / `make add`).
#
# Not yet migrated? Falls back to sourcing the plaintext NAME so nothing breaks.
# Manage with: cd ~/.dotfiles/zsh && make help

_sec_dir="${SECRETS_DIR:-$HOME/.dotfiles/zsh}"
_sec_files=(.secrets .secrets_work)
_sec_cache_dir="${XDG_RUNTIME_DIR:-/tmp}/secrets-cache"
_sec_keyring_service="${SECRETS_KEYRING_SERVICE:-age-secrets}"

for _sec_name in $_sec_files; do
  _sec_src="$_sec_dir/$_sec_name.age"
  _sec_cache="$_sec_cache_dir/$_sec_name.env"

  if [[ -f $_sec_src ]]; then
    if [[ ! -s $_sec_cache || $_sec_src -nt $_sec_cache ]]; then
      (
        umask 077
        mkdir -p "$_sec_cache_dir"
        age -d -i <(secret-tool lookup service "$_sec_keyring_service" key default) "$_sec_src" > "$_sec_cache.tmp" 2>/dev/null \
          && mv -f "$_sec_cache.tmp" "$_sec_cache" \
          || { rm -f "$_sec_cache.tmp"; echo "secrets: failed to decrypt $_sec_name.age (keyring locked? age installed?)" >&2; }
      )
    fi
    [[ -s $_sec_cache ]] && source "$_sec_cache"
  elif [[ -f $_sec_dir/$_sec_name ]]; then
    source "$_sec_dir/$_sec_name"
  fi
done

unset _sec_dir _sec_files _sec_cache_dir _sec_keyring_service _sec_name _sec_src _sec_cache
