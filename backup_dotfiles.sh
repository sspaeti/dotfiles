#this script is done to automatically backup alls my dotsfiles

cp ~/Library/ApplicationSupport/Code/User/settings.json $git/general/dotfiles/vscode/settings.json
cp ~/Library/ApplicationSupport/Code/User/keybindings.json $git/general/dotfiles/vscode/keybindings.json
cp ~/.vimrc $git/general/dotfiles/vim/vimrc #this will be outdated in a while, see nvim init.vim
#using nvim going forward therefore separting configs
cp ~/.config/nvim/init.vim $git/general/dotfiles/nvim/init.vim
cp -r ~/.config/nvim/themes $git/general/dotfiles/nvim/themes
cp -r ~/.config/nvim/autoload $git/general/dotfiles/nvim/autoload
cp -r ~/.gitconfig $git/general/dotfiles/git/gitconfig

cp ~/.tmux.conf $git/general/dotfiles/tmux/tmux.conf
cp ~/.tmux/ide $git/general/dotfiles/tmux/ide
cp ~/.tmux/tmux-session $git/general/dotfiles/tmux/tmux-session

#fzf/zsh
cp ~/.fzf.zsh $git/general/dotfiles/fzf/fzf.zsh
cp -r ~/.fzf/* $git/general/dotfiles/fzf/

#cp -r ~/.oh-my-zsh/custom/* $git/general/dotfiles/zsh/custom/
cp -r ~/.aliases.shrc $git/general/dotfiles/zsh/aliases.shrc

#obsidian
cp ~/Simon/Sync/SecondBrain/.obsidian/workspace $git/general/dotfiles/obsidian/workspace
cp ~/Simon/Sync/SecondBrain/.obsidian/hotkeys.json $git/general/dotfiles/obsidian/hotkeys.json
cp ~/Simon/Sync/SecondBrain/.obsidian/core-plugins.json $git/general/dotfiles/obsidian/core-plugins.json
cp ~/Simon/Sync/SecondBrain/.obsidian/community-plugins.json $git/general/dotfiles/obsidian/community-plugins.json
cp ~/Simon/Sync/SecondBrain/.obsidian/appearance.json $git/general/dotfiles/obsidian/appearance.json
cp ~/Simon/Sync/SecondBrain/.obsidian/app.json $git/general/dotfiles/obsidian/app.json

brew bundle dump > $git/general/dotfiles/Brewfile -f



source $venvs/dagster/bin/activate
pip freeze > $git/general/dotfiles/python/venvs/dagster.txt
deactivate

source $venvs/banking/bin/activate
pip freeze > $git/general/dotfiles/python/venvs/banking.txt
deactivate
