# Notmuch Email Screening Setup

Tag-based email management with **notmuch** + **mbsync** for Neomutt.

## Overview

Instead of moving emails between folders, notmuch uses **tags**:

- `screened-in` - Approved senders (inbox)
- `screened-out` - Blocked senders (spam)
- `feed` - Newsletters/feeds
- `papertrail` - Receipts
- `to-screen` - Needs manual review
- Plus: `inbox`, `archive`, `spam`, `waiting`, `someday`, etc.

## Quick Start

```bash
# 1. Install packages
sudo pacman -S notmuch isync

# 2. Configure mbsync
cp ~/.config/mutt/notmuch/mbsyncrc.example ~/.mbsyncrc
# Edit ~/.mbsyncrc - update PassCmd for password

# 3. Initial sync
cd ~/.config/mutt
make notmuch-sync    # Downloads all emails (takes time)

# 4. Initialize notmuch
make notmuch-init    # Indexes emails

# 5. Run screening
make notmuch-screen  # Tags emails based on lists

# 6. Launch neomutt
neomutt
```

## Daily Usage

```bash
cd ~/.config/mutt

make sync        # Sync once (fetch → screen → sync back)
make             # Start continuous loop (syncs every 10 min)
make help        # Show all commands
```

## Key Bindings in Neomutt

**Screening (in email view):**
- `I` - Approve sender → inbox
- `O` - Block sender → spam
- `F` - Add to Feed
- `P` - Add to PaperTrail

**Navigation:**
- `gi` - INBOX, `gk` - ToScreen, `go` - ScreenedOut
- `gf` - Feed, `gp` - PaperTrail, `gw` - Waiting
- `gm` - Someday, `ga` - Archive, `gt` - Trash

**Tagging:**
- `Mi` - inbox, `Mo` - screened-out, `Mf` - feed
- `Mw` - waiting, `Mm` - someday, `Ma` - archive

**Sync:**
- `S` - Sync all, `A` - Screen only

## How It Works

1. **mbsync** downloads emails from IMAP to local Maildir
2. **notmuch** indexes emails and applies tags based on:
   - `~/.dotfiles/mutt/.lists/screened_in.txt`
   - `~/.dotfiles/mutt/.lists/screened_out.txt`
   - `~/.dotfiles/mutt/.lists/feed.txt`
   - `~/.dotfiles/mutt/.lists/papertrail.txt`
3. Emails from unknown senders get tagged `to-screen`
4. Review `ToScreen` mailbox and press `I`/`O`/`F`/`P` to categorize

## Troubleshooting

**Notmuch can't find database:**
```bash
export NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config
notmuch new
```

**Virtual mailboxes empty:**
```bash
# Check tags
NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config notmuch search tag:inbox
```

**mbsync authentication fails:**
```bash
# Test password extraction
grep imap_pass ~/.dotfiles/zsh/.secret.muttrc | cut -d'"' -f2
```

## Files

```
~/.config/mutt/
├── muttrc                  # Main config
├── Makefile                # make sync, make help
└── notmuch/
    ├── notmuch-config      # DB config
    ├── notmuch_screening.sh # Tagging script
    ├── mbsyncrc.example    # mbsync template
    └── sync/mbsync_notmuch_sync.sh

~/.dotfiles/mutt/.lists/    # Email lists (git ignored)
├── screened_in.txt         # 1,723 approved senders
├── screened_out.txt        # 1,287 blocked senders
├── feed.txt                # 107 newsletters
└── papertrail.txt          # 12 receipts

~/.mbsyncrc                 # mbsync config
```

## Why Notmuch?

- **Faster search** - Full-text search across all email
- **Multiple tags** - Email can be "waiting" AND "important"
- **No file moving** - Tags are metadata, files stay in place
- **Better threading** - Excellent conversation threading
- **Scriptable** - Easy custom tag rules

## Resources

- [Notmuch Docs](https://notmuchmail.org/doc/latest/man1/notmuch.html)
- [Neomutt Notmuch](https://neomutt.org/feature/notmuch)
- [mbsync Docs](https://isync.sourceforge.io/mbsync.html)
