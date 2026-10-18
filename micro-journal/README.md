# Micro Journal Scripts

These scripts are synced with [My Distraction-Free Micro Journal](https://www.ssp.sh/brain/my-distraction-free-typewriter-micro-journal/) and with `make nvim-from-mj` I sync nvim configs to this dotfiles repo.

If you search for nvim to use as wordprocessor on normal hardware and laptop, check out [dotfiles/nvim/.config/nvim-wp](https://wp.ssp.sh), which I use on my modern laptops with aliased to wp with `alias wp='NVIM_APPNAME=nvim-wp nvim'`, so I can run `nvim` for coding, and `wp` for writing.

## Troubleshoot
### Size

Only 3.2 GB was used, instead of full 32GB. 
```sh
sudo raspi-config
```
Then select `Advanced Options -> Expand Filesystem`.

That extended the partition to 32 GB.

## Prepare scripts for syncing

> I wrote one script to turn on the network (`startnetwork.sh`) and a second to sync the clock to my timezone (`stopnetwork.sh`). 
>
> I run those scripts via the terminal and then **activate Syncthing** (I might run a `rsync` script). It connects up to my other devices and grabs new files, versions, etc. Then I kill Syncthing and the network. Whole process takes a minute. *[Reddit](https://sh.reddit.com/r/writerDeck/comments/1j0pe1h/comment/mfpu1e5/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button), thanks to u/corycaea.*

