#this script is done to automatically backup alls my dotsfiles

cp ~/Library/ApplicationSupport/Code/User/settings.json $git/dotfiles/vscode/settings.json
cp ~/Library/ApplicationSupport/Code/User/keybindings.json $git/dotfiles/vscode/keybindings.json
cp ~/.vimrc $git/dotfiles/vim/vimrc

brew bundle dump > $git/dotfiles/Brewfile -f

source $venvs/dagster/bin/activate
pip freeze > $git/dotfiles/python/venvs/dagster.txt
deactivate
