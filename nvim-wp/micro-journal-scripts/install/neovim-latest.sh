# Make sure snapd is installed and up-to-date
sudo apt update
sudo apt install snapd
sudo reboot  # You'll need to reboot after installing snapd

# After reboot, install the core snap
sudo snap install core

# Now install Neovim
sudo snap install nvim --classic


#-------------
#does not work: 
# sudo apt remove neovim
# sudo apt install ninja-build gettext cmake unzip curl
# git clone https://github.com/neovim/neovim
# cd neovim
# make CMAKE_BUILD_TYPE=RelWithDebInfo
# ls
# cd build
# cpack -G DEB
# # sudo dpkg -i nvim-linux64.deb
# # sudo apt remove neovim
# sudo dpkg -i --force-overwrite  nvim-linux64.deb
# nvim

# sudo apt remove ninja-build gettext cmake
# sudo apt autoremove  # This removes packages that were installed as dependencies but are no longer needed
