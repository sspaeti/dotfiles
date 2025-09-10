# Tmux Setup

## Plugin Installation After Stow

When you stow tmux configuration, the `~/.tmux/plugins` directory may be empty but still exist, which prevents proper plugin installation.

**Run this command after stowing tmux:**

```bash
rm -rf ~/.tmux/plugins && tmux new-session -d && tmux kill-session
```

Then open tmux and press `Ctrl+t` followed by `I` to install all plugins.

This removes the empty plugins directory and allows the plugin manager to properly install plugins from scratch.