#all configs
cp -r ~/.conf/* ~/configs/dotfiles/micro-journal/

# Copy only files (not directories) from ~/microjournal
find ~/microjournal -maxdepth 1 -type f -exec cp {} ~/configs/dotfiles/micro-journal/scripts/ \;

# copy dotfiles
cp ~/.bashrc ~/.aliases.shrc ~/configs/dotfiles/micro-journal/dotfiles/
