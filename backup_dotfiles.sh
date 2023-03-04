#this script is done to automatically backup alls my dotsfiles

#nvim
cp ~/Library/ApplicationSupport/Code/User/settings.json $git/general/dotfiles/vscode/settings.json
cp ~/Library/ApplicationSupport/Code/User/keybindings.json $git/general/dotfiles/vscode/keybindings.json
#cp ~/.vimrc $git/general/dotfiles/vim/vimrc #this will be outdated in a while, see nvim init.vim
#using nvim going forward therefore separting configs
rm -r $git/general/dotfiles/nvim/ && mkdir -p $git/general/dotfiles/nvim/after/plugin && mkdir $git/general/dotfiles/nvim/lua/
cp ~/.config/nvim/lazy-lock.json $git/general/dotfiles/nvim/lazy-lock.json
cp -r ~/.config/nvim/lua/ $git/general/dotfiles/nvim/lua/
cp -r ~/.config/nvim/after/ $git/general/dotfiles/nvim/after/
cp -r ~/.config/nvim/plugin/ $git/general/dotfiles/nvim/plugin/
cp -r ~/.config/nvim/ftplugin/ $git/general/dotfiles/nvim/ftplugin/
cp -r ~/.gitconfig $git/general/dotfiles/git/gitconfig

#tmux
cp ~/.tmux.conf $git/general/dotfiles/tmux/tmux.conf
cp ~/.tmux/ide $git/general/dotfiles/tmux/ide
cp ~/.tmux/tmux-session $git/general/dotfiles/tmux/tmux-session
cp ~/.tmux/themes/tmux-kanagawa-dark.conf $git/general/dotfiles/tmux/themes/tmux-kanagawa-dark.conf

#fzf/zsh
cp ~/.fzf.zsh $git/general/dotfiles/fzf/fzf.zsh
cp -r ~/.fzf/* $git/general/dotfiles/fzf/

#cp -r ~/.oh-my-zsh/custom/* $git/general/dotfiles/zsh/custom/
cp -r ~/.zshrc $git/general/dotfiles/zsh/zshrc
cp -r ~/.dotfiles/zsh/.secrets $git/general/dotfiles/zsh/.secrets
cp -r ~/.dotfiles/zsh/aliases.shrc $git/general/dotfiles/zsh/aliases.shrc
cp -r ~/.dotfiles/zsh/paths.shrc $git/general/dotfiles/zsh/paths.shrc
cp -r ~/.dotfiles/zsh/configs.shrc $git/general/dotfiles/zsh/configs.shrc
cp -r ~/.dotfiles/zsh/end.shrc $git/general/dotfiles/zsh/end.shrc
cp -r ~/.dotfiles/helpers/* $git/general/dotfiles/zsh/helpers/

#helix
cp ~/.config/helix/config.toml $git/general/dotfiles/helix/config.toml

#obsidian
cp ~/Simon/Sync/SecondBrain/.obsidian/workspace $git/general/dotfiles/obsidian/workspace
cp ~/Simon/Sync/SecondBrain/.obsidian/workspace.json $git/general/dotfiles/obsidian/workspace.json
cp ~/Simon/Sync/SecondBrain/.obsidian/hotkeys.json $git/general/dotfiles/obsidian/hotkeys.json
cp ~/Simon/Sync/SecondBrain/.obsidian/core-plugins.json $git/general/dotfiles/obsidian/core-plugins.json
cp ~/Simon/Sync/SecondBrain/.obsidian/community-plugins.json $git/general/dotfiles/obsidian/community-plugins.json
cp ~/Simon/Sync/SecondBrain/.obsidian/appearance.json $git/general/dotfiles/obsidian/appearance.json
cp ~/Simon/Sync/SecondBrain/.obsidian/app.json $git/general/dotfiles/obsidian/app.json
cp ~/Simon/Sync/SecondBrain/.obsidian/.vimrc $git/general/dotfiles/obsidian/.vimrc
cp ~/Simon/Sync/SecondBrain/.obsidian/themes/custom_kanagawa.css $git/general/dotfiles/obsidian/themes/custom_kanagawa.css
cp -r ~/Simon/Sync/SecondBrain/.obsidian/snippets/* $git/general/dotfiles/obsidian/snippets/

#kitty
cp ~/.config/kitty/kitty.conf $git/general/dotfiles/kitty/kitty.conf
cp ~/.config/kitty/gruvbox-kitty.conf $git/general/dotfiles/kitty/gruvbox-kitty.conf
cp ~/.config/kitty/kanagawa-kitty.conf $git/general/dotfiles/kitty/kanagawa-kitty.conf
cp ~/.config/kitty/custom_kitty.conf $git/general/dotfiles/kitty/custom_kitty.conf

# yabai and skhd - tiling window manager
# start with `brew services start yabai skhd`
cp ~/.config/yabai/yabairc $git/general/dotfiles/yabai/yabairc
cp ~/.config/skhd/skhdrc $git/general/dotfiles/skhd/skhdrc

#ranger
cp ~/.config/ranger/rc.conf $git/general/dotfiles/ranger/rc.conf


#linting and formatting

cp -r ~/.pylintrc $git/general/dotfiles/linting/pylintrc
cp -r ~/.config/flake8 $git/general/dotfiles/linting/flake8
cp -r ~/.isort.cfg $git/general/dotfiles/linting/issort.cfg
cp -r ~/.pyproject_example.toml $git/general/dotfiles/linting/pyproject_example.toml

#dbbeaver vrapper configs
cp ~/.vrapperrc $git/general/dotfiles/dbeaver/vrapperrc 


#homebrew
brew bundle dump > $git/general/dotfiles/Brewfile -f


# source $venvs/dagster/bin/activate
# pip freeze > $git/general/dotfiles/python/venvs/dagster.txt
# deactivate
# 
# source $venvs/banking/bin/activate
# pip freeze > $git/general/dotfiles/python/venvs/banking.txt
# deactivate
