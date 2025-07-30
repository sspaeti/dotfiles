#this script is done to automatically backup alls my dotsfiles for arch that are not part of backup_dotfiles.sh

cp -r ~/.config/hypr/ _arch-linux/
cp -r ~/.local/share/omarchy/default/hypr/* _arch-linux/hypr/omarchy/default
cp -r ~/.local/share/omarchy/bin/*  _arch-linux/hypr/omarchy/bin

#keyboard shortcuts
cp /etc/kanata/lenovo.kbd _arch-linux/kanata/
cp /etc/kanata/kinesis.kbd _arch-linux/kanata/
cp /etc/systemd/system/kanata.service _arch-linux/kanata/
cp ~/.local/bin/switch-keyboard _arch-linux/bin/helper/
# will be set automatically with above switch-keyboard bash script
# cp /etc/kanata/kanata.kbd _arch-linux/kanata/

cp -r ~/.config/waybar/ _arch-linux/
cp -r ~/.config/wofi/ _arch-linux/wofi


#! I also have the mac ghostty settings in the dots files one level above
cp -r ~/.config/ghostty/ _arch-linux/ghostty


# Installed SW arch (Pacman Yay)
pacman -Qe > _arch-linux/pacman.txt
