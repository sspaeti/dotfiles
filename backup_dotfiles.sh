#this script is done to automatically backup alls my dotsfiles

cp ~/Library/ApplicationSupport/Code/User/settings.json $git/dotfiles/vscode/settings.json
cp ~/Library/ApplicationSupport/Code/User/keybindings.json $git/dotfiles/vscode/keybindings.json
cp ~/.vimrc $git/dotfiles/vim/vimrc #this will be outdated in a while, see nvim init.vim
#using nvim going forward therefore separting configs
cp ~/.config/nvim/init.vim $git/dotfiles/nvim/init.vim
cp -r ~/.config/nvim/themes $git/dotfiles/nvim/themes
cp -r ~/.config/nvim/autoload $git/dotfiles/nvim/autoload

brew bundle dump > $git/dotfiles/Brewfile -f

source $venvs/dagster/bin/activate
pip freeze > $git/dotfiles/python/venvs/dagster.txt
deactivate

source $venvs/banking/bin/activate
pip freeze > $git/dotfiles/python/venvs/banking.txt
deactivate
