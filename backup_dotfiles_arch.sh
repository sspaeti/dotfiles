#this script is done to automatically backup alls my dotsfiles for arch that are not part of backup_dotfiles.sh

cp -r ~/.config/hypr/ _arch-linux/hypr/
cp -r ~/.local/share/omarchy/ _arch-linux/hypr/omarchy/

#keyboard shortcuts
cp /etc/kanata/kanata.kbd _arch-linux/kanata/
cp /etc/systemd/system/kanata.service _arch-linux/kanata/
