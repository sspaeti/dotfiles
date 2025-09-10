# Tmux Setup

## Plugin Installation After Stow

When you stow tmux configuration, the `~/.tmux/plugins` directory may be empty but still exist, which prevents proper plugin installation.

**Run this command after stowing tmux:**

```bash
rm -rf ~/.tmux/plugins && tmux new-session -d && tmux kill-session
```

Then open tmux and press `Ctrl+t` followed by `I` to install all plugins.

This removes the empty plugins directory and allows the plugin manager to properly install plugins from scratch.

## Tmux-Resurrect Error

If you see "tmux resurrect file not found" errors when reloading tmux, it's because the resurrect plugin is trying to restore from a save file that doesn't exist yet.

**Fix:** Press `Ctrl+t` + `Ctrl+s` to manually save a session first. The error will disappear on future reloads.