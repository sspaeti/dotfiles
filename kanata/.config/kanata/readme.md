
Install systemd service to run it automatically. It must be as /etc/systemd/system as it needs uinput permission that only sudo has.

I also added below line to `/etc/sudoers` to allow hypr shortcut without asking for sudo password each time i hit the shortcut:

```
sspaeti ALL=(ALL) NOPASSWD: /bin/cp /etc/kanata/*.kbd /home/sspaeti/.config/kanata/kanata.kbd, /bin/systemctl restart kanata
```
