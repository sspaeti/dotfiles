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



#nvim wordprocessor config
rm -rf $git/general/dotfiles/nvim-wp/
cp -r ~/.config/nvim-wp/ $git/general/dotfiles/nvim-wp/


cp -r ~/.config/sesh/ $git/general/dotfiles/sesh/
# might contain sensitive information
# cp -r ~/.gitconfig $git/general/dotfiles/git/gitconfig

#tmux
cp ~/.tmux.conf $git/general/dotfiles/tmux/tmux.conf
cp ~/.tmux/ide $git/general/dotfiles/tmux/ide
cp ~/.tmux/tmux-session $git/general/dotfiles/tmux/tmux-session
cp ~/.tmux/themes/tmux-kanagawa-dark.conf $git/general/dotfiles/tmux/themes/tmux-kanagawa-dark.conf
cp ~/.tmux/tmux-switch-session.sh $git/general/dotfiles/tmux/tmux-switch-session.sh
cp ~/.tmux/tmux-switch-session-git.sh $git/general/dotfiles/tmux/tmux-switch-session-git.sh

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

# only locally
cp -r ~/.ssh/* $git/general/dotfiles/.ssh/


#helix
cp ~/.config/helix/config.toml $git/general/dotfiles/helix/config.toml

#obsidian
cp ~/Simon/SecondBrain/.obsidian/workspace $git/general/dotfiles/obsidian/workspace
cp ~/Simon/SecondBrain/.obsidian/workspace.json $git/general/dotfiles/obsidian/workspace.json
cp ~/Simon/SecondBrain/.obsidian/hotkeys.json $git/general/dotfiles/obsidian/hotkeys.json
cp ~/Simon/SecondBrain/.obsidian/core-plugins.json $git/general/dotfiles/obsidian/core-plugins.json
cp ~/Simon/SecondBrain/.obsidian/community-plugins.json $git/general/dotfiles/obsidian/community-plugins.json
cp ~/Simon/SecondBrain/.obsidian/appearance.json $git/general/dotfiles/obsidian/appearance.json
cp ~/Simon/SecondBrain/.obsidian/app.json $git/general/dotfiles/obsidian/app.json
cp ~/Simon/SecondBrain/.obsidian/.vimrc $git/general/dotfiles/obsidian/.vimrc
cp -r ~/Simon/SecondBrain/.obsidian/snippets/* $git/general/dotfiles/obsidian/snippets/
cp -r ~/Simon/SecondBrain/.obsidian/exports/* $git/general/dotfiles/obsidian/exports/

#kitty
cp ~/.config/kitty/kitty.conf $git/general/dotfiles/kitty/kitty.conf
cp ~/.config/kitty/gruvbox-kitty.conf $git/general/dotfiles/kitty/gruvbox-kitty.conf
cp ~/.config/kitty/kanagawa-kitty.conf $git/general/dotfiles/kitty/kanagawa-kitty.conf
cp ~/.config/kitty/kanagawa-paper-kitty.conf $git/general/dotfiles/kitty/kanagawa-paper-kitty.conf
cp ~/.config/kitty/custom_kitty.conf $git/general/dotfiles/kitty/custom_kitty.conf

# Ghostty
cp ~/.config/ghostty/config $git/general/dotfiles/ghostty/config

# yabai and skhd - tiling window manager
# start with `brew services start yabai skhd`
cp ~/.config/yabai/yabairc $git/general/dotfiles/yabai/yabairc
cp ~/.config/skhd/skhdrc $git/general/dotfiles/skhd/skhdrc


# neomutt - email client
cp ~/.config/mutt/muttrc $git/general/dotfiles/mutt/muttrc
cp ~/.config/mutt/initial_screening.sh $git/general/dotfiles/mutt/initial_screening.sh

cp ~/.config/mutt/color.muttrc $git/general/dotfiles/mutt/color.muttrc
cp ~/.config/mutt/generate_pattern.sh $git/general/dotfiles/mutt/generate_pattern.sh
cp ~/.config/mutt/generate_pattern_in.sh $git/general/dotfiles/mutt/generate_pattern_in.sh
cp -r ~/.config/mutt/launchctl/* $git/general/dotfiles/mutt/launchctl/
cp -r ~/.config/mutt/tests/* $git/general/dotfiles/mutt/tests/
cp -r ~/.config/mutt/templates/* $git/general/dotfiles/mutt/templates/
cp ~/.config/mutt/mailcap $git/general/dotfiles/mutt/mailcap
cp ~/.config/mutt/signature $git/general/dotfiles/mutt/signature
cp ~/.config/mutt/update_screen_lists.sh $git/general/dotfiles/mutt/update_screen_lists.sh

cp ~/.config/mutt/get_hey_emails/get_screener_emails_from_hey.py $git/general/dotfiles/mutt/get_hey_emails/get_screener_emails_from_hey.py


#ranger
cp ~/.config/ranger/rc.conf $git/general/dotfiles/ranger/rc.conf
#yazi
cp -r ~/.config/yazi/*  $git/general/dotfiles/yazi/


#linting and formatting

cp -r ~/.pylintrc $git/general/dotfiles/linting/pylintrc
cp -r ~/.config/flake8 $git/general/dotfiles/linting/flake8
cp -r ~/.isort.cfg $git/general/dotfiles/linting/issort.cfg
cp -r ~/.pyproject_example.toml $git/general/dotfiles/linting/pyproject_example.toml
cp -r ~/.config/ruff/pyproject.toml $git/general/dotfiles/ruff/pyproject.toml

#dbbeaver vrapper configs
cp ~/.vrapperrc $git/general/dotfiles/dbeaver/vrapperrc 

# karabiner
cp -r ~/.config/karabiner/* $git/general/dotfiles/karabiner/

#homebrew
brew bundle dump --file=$git/general/dotfiles/Brewfile --force

#ansible
cp ~/.ansible.cfg $git/general/dotfiles/ansible/ansible.cfg

#ansible
cp ~/.k9s/hotkey.yml $git/general/dotfiles/k9s/hotkey.yml

#Lazygit: location could be changed: `export XDG_CONFIG_HOME="$HOME/.config` (but that would affect all apps)
cp -r ~/Library/Application\ Support/lazygit/config.yml $git/general/dotfiles/lazygit/config.yml
# source $venvs/dagster/bin/activate
# pip freeze > $git/general/dotfiles/python/venvs/dagster.txt
# deactivate
# 
# source $venvs/banking/bin/activate
# pip freeze > $git/general/dotfiles/python/venvs/banking.txt
# deactivate
