# Tmux Setup

## Plugin Installation After Stow

When you stow tmux configuration, the `~/.tmux/plugins` directory may be empty but still exist, which prevents proper plugin installation.

**Run this command after stowing tmux:**

```bash
rm -rf ~/.tmux/plugins && tmux new-session -d && tmux kill-session
```

**Then install TPM (Tmux Plugin Manager) first:**

Run this command to install TPM and all plugins:

```bash
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true 
~/.tmux/plugins/tpm/bin/install_plugins
```

After TPM is installed, you can use `Ctrl+t` followed by `I` for future plugin installations.

This removes the empty plugins directory and allows the plugin manager to properly install plugins from scratch.

## Tmux-Resurrect Error

If you see "tmux resurrect file not found" errors when reloading tmux, it's because the resurrect plugin is trying to restore from a save file that doesn't exist yet.

**Fix:** Press `Ctrl+t` + `Ctrl+s` to manually save a session first. The error will disappear on future reloads.
