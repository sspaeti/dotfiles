
# Micro Journal Scripts

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

