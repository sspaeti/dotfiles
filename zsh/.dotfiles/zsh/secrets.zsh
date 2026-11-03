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
      # Serialize: at login tmux-resurrect restores ~90 shells at once, and all
      # of them block on the same keyring-unlock prompt. Without the lock they
      # then all decrypt into one shared .tmp and every mv but the first fails
      # with "cannot stat". With it, the first shell decrypts (secret-tool waits
      # for the keyring password), the rest wait on the lock and source the cache.
      (
        umask 077
        mkdir -p "$_sec_cache_dir"
        exec 9>"$_sec_cache.lock"
        flock 9
        [[ -s $_sec_cache && ! $_sec_src -nt $_sec_cache ]] && exit 0   # another shell just did it
        _sec_tmp="$_sec_cache.$$.tmp"
        age -d -i <(secret-tool lookup service "$_sec_keyring_service" key default) "$_sec_src" > "$_sec_tmp" 2>/dev/null \
          && mv -f "$_sec_tmp" "$_sec_cache" \
          || { rm -f "$_sec_tmp"; echo "secrets: failed to decrypt $_sec_name.age (keyring locked? age installed?)" >&2; }
      )
    fi
    [[ -s $_sec_cache ]] && source "$_sec_cache"
  elif [[ -f $_sec_dir/$_sec_name ]]; then
    source "$_sec_dir/$_sec_name"
  fi
done

unset _sec_dir _sec_files _sec_cache_dir _sec_keyring_service _sec_name _sec_src _sec_cache
