#this script is done to automatically backup alls my dotsfiles

cp ~/Library/ApplicationSupport/Code/User/settings.json $git/general/dotfiles/vscode/settings.json
cp ~/Library/ApplicationSupport/Code/User/keybindings.json $git/general/dotfiles/vscode/keybindings.json
cp ~/.vimrc $git/general/dotfiles/vim/vimrc #this will be outdated in a while, see nvim init.vim
#using nvim going forward therefore separting configs
cp ~/.config/nvim/init.vim $git/general/dotfiles/nvim/init.vim
cp -r ~/.config/nvim/themes $git/general/dotfiles/nvim/themes
cp -r ~/.config/nvim/autoload $git/general/dotfiles/nvim/autoload
cp -r ~/.aliases.shrc $git/general/dotfiles/zsh/aliases.shrc

cp -r ~/.tmux.conf $git/general/dotfiles/tmux/tmux.conf
cp -r ~/ide.sh $git/general/dotfiles/tmux/ide.sh

brew bundle dump > $git/general/dotfiles/Brewfile -f

source $venvs/dagster/bin/activate
pip freeze > $git/general/dotfiles/python/venvs/dagster.txt
deactivate

source $venvs/banking/bin/activate
pip freeze > $git/general/dotfiles/python/venvs/banking.txt
deactivate
