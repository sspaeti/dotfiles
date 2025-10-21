# Notmuch Email Screening Setup

This directory contains the configuration and scripts for using **notmuch** with Neomutt for tag-based email management instead of folder-based organization.

## Overview

Instead of moving emails between folders (INBOX, ScreenedOut, Feed, etc.), notmuch uses **tags** to organize emails:

- `screened-in` - Approved senders (stay in inbox)
- `screened-out` - Blocked senders (spam)
- `feed` - Newsletters/feeds
- `papertrail` - Receipts and papertrail items
- `to-screen` - New emails needing manual review
- Plus standard tags: `inbox`, `archive`, `spam`, `waiting`, `someday`, etc.

## Directory Structure

```
~/.config/mutt/
├── muttrc-notmuch          # Main Neomutt config (use instead of muttrc)
└── notmuch/
    ├── README.md           # This file
    ├── notmuch-config      # Notmuch database configuration
    ├── notmuch_screening.sh # Tag-based screening script
    ├── mbsyncrc.example    # Example mbsync config (recommended)
    └── sync/
        ├── notmuch_sync.sh         # Sync script for offlineimap + notmuch
        └── mbsync_notmuch_sync.sh  # Sync script for mbsync + notmuch (recommended)
```

## Required Files (Already in Top-Level Directory)

These files from your existing setup are still needed:

- `~/.config/mutt/screened_in.txt` - List of approved email addresses
- `~/.config/mutt/screened_out.txt` - List of blocked email addresses
- `~/.config/mutt/feed.txt` - List of newsletter/feed email addresses
- `~/.config/mutt/papertrail.txt` - List of papertrail email addresses
- `~/.config/mutt/color.muttrc` - Your color scheme
- `~/.config/mutt/signature` - Email signature
- `~/.config/mutt/mailcap` - MIME type handlers
- `~/.dotfiles/zsh/.secret.muttrc` - Password/secrets file

## Installation & Setup

### Prerequisites

Install required packages on Arch Linux:

```bash
# For notmuch
sudo pacman -S notmuch

# For mbsync (recommended over offlineimap)
sudo pacman -S isync

# If keeping offlineimap
sudo pacman -S offlineimap

# Required utilities (likely already installed)
sudo pacman -S formail grep sed coreutils
```

### Option 1: Keep offlineimap (Easier Migration)

1. **Initialize notmuch database:**
   ```bash
   notmuch setup
   ```
   - Database path: `/home/sspaeti/Documents/mutt/sspaeti.com`
   - Your name: `Simon Späti`
   - Primary email: `simon@ssp.sh`
   - Other emails: `simon@sspaeti.com;simu@sspaeti.com`

2. **Or use the pre-configured notmuch-config:**
   ```bash
   export NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config
   notmuch new
   ```

3. **Test the setup:**
   ```bash
   # Run initial screening
   ~/.config/mutt/notmuch/notmuch_screening.sh

   # Launch Neomutt with notmuch config
   neomutt -F ~/.config/mutt/muttrc-notmuch
   ```

4. **Update your sync workflow:**
   - Use `~/.config/mutt/notmuch/sync/notmuch_sync.sh` instead of your old sync script
   - Or set up a cron job/systemd timer for automatic syncing

### Option 2: Upgrade to mbsync (Recommended)

**Why mbsync?**
- 3-5x faster than offlineimap
- Actively maintained (offlineimap is dormant)
- Better IMAP compliance
- Lower resource usage

**Setup Steps:**

1. **Configure mbsync:**
   ```bash
   cp ~/.config/mutt/notmuch/mbsyncrc.example ~/.mbsyncrc
   ```

2. **Edit `~/.mbsyncrc`:**
   - Update the `PassCmd` line to match your password method
   - Verify folder names match your IMAP server

3. **Initial sync (takes a while):**
   ```bash
   mbsync -V sspaeti.com
   ```

4. **Initialize notmuch:**
   ```bash
   export NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config
   notmuch new
   ```

5. **Run initial screening:**
   ```bash
   ~/.config/mutt/notmuch/notmuch_screening.sh
   ```

6. **Launch Neomutt:**
   ```bash
   neomutt -F ~/.config/mutt/muttrc-notmuch
   ```

7. **Update your workflow:**
   - Use `~/.config/mutt/notmuch/sync/mbsync_notmuch_sync.sh` for syncing

## Usage

### Starting Neomutt with Notmuch

```bash
neomutt -F ~/.config/mutt/muttrc-notmuch
```

Or create an alias in your shell config:
```bash
alias mutt="neomutt -F ~/.config/mutt/muttrc-notmuch"
```

### Key Bindings (Same as Before!)

**Screening macros:**
- `I` - Screen in sender (add to approved list, tag as `screened-in`)
- `O` - Screen out sender (add to blocked list, tag as `screened-out`)
- `F` - Add sender to Feed list (tag as `feed`)
- `P` - Add sender to PaperTrail list (tag as `papertrail`)

**Navigation (using virtual mailboxes):**
- `gi` - Go to INBOX
- `gk` - Go to ToScreen (emails needing review)
- `go` - Go to ScreenedOut
- `gf` - Go to Feed
- `gp` - Go to PaperTrail
- `gw` - Go to Waiting
- `gm` - Go to Someday
- `ga` - Go to Archive
- `gt` - Go to Trash
- `gs` - Go to Sent

**Tagging macros:**
- `Mi` - Tag as inbox
- `Mo` - Tag as screened-out
- `Mf` - Tag as feed
- `Mp` - Tag as papertrail
- `Mw` - Tag as waiting
- `Mm` - Tag as someday
- `Ma` - Tag as archive
- `Mt` - Tag as trash

**Sync:**
- `S` - Sync emails and run screening
- `A` - Run screening only

### How Screening Works

1. **Automatic screening on sync:**
   - New emails are indexed by notmuch
   - Screening script checks sender against your lists
   - Tags are applied automatically

2. **Manual screening:**
   - Review emails in "ToScreen" mailbox (`gk`)
   - Press `I` to approve sender → moves to INBOX
   - Press `O` to block sender → tags as spam
   - Press `F` for feeds, `P` for papertrail

3. **List updates:**
   - When you approve/block a sender, their email is added to the respective .txt file
   - Previously received emails from that sender are retagged automatically

## Files Explained

### notmuch-config
Notmuch database configuration. Defines:
- Database path
- Your email addresses
- Default tags for new emails
- Synchronization settings

### notmuch_screening.sh
Core screening logic. This script:
1. Runs `notmuch new` to index new emails
2. Reads your screened lists (screened_in.txt, screened_out.txt, etc.)
3. Applies appropriate tags to emails based on sender
4. Retags emails in ToScreen if sender status changed

**You should run this after each sync.**

### sync/notmuch_sync.sh
Complete sync workflow for **offlineimap**:
1. Checks Wi-Fi connection
2. Runs offlineimap to fetch new emails
3. Runs notmuch screening
4. Syncs again to push any local changes

### sync/mbsync_notmuch_sync.sh
Complete sync workflow for **mbsync**:
1. Checks Wi-Fi connection
2. Runs mbsync to fetch new emails
3. Runs notmuch screening
4. Syncs again to push any local changes

### mbsyncrc.example
Template configuration for mbsync. Copy to `~/.mbsyncrc` and customize.

## Automation

### Systemd Timer (Recommended)

Create `~/.config/systemd/user/mutt-sync.service`:
```ini
[Unit]
Description=Mutt Email Sync with Notmuch

[Service]
Type=oneshot
ExecStart=/home/sspaeti/.config/mutt/notmuch/sync/mbsync_notmuch_sync.sh
```

Create `~/.config/systemd/user/mutt-sync.timer`:
```ini
[Unit]
Description=Sync emails every 10 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=10min

[Install]
WantedBy=timers.target
```

Enable and start:
```bash
systemctl --user enable --now mutt-sync.timer
```

### Cron Job Alternative

Add to crontab (`crontab -e`):
```bash
*/10 * * * * /home/sspaeti/.config/mutt/notmuch/sync/mbsync_notmuch_sync.sh
```

## Troubleshooting

### Notmuch can't find database
```bash
export NOTMUCH_CONFIG=~/.config/mutt/notmuch/notmuch-config
notmuch new
```

### Tags not applying
Check that your .txt files have proper formatting:
```bash
# Remove trailing whitespace
sed -i 's/[[:space:]]*$//' ~/.config/mutt/screened_in.txt
```

### Virtual mailboxes empty
Run notmuch manually to check:
```bash
notmuch search tag:to-screen
notmuch search tag:inbox
```

### mbsync authentication fails
Check password command in `~/.mbsyncrc`:
```bash
# Test password retrieval
grep HOSTPOINT_SMTP_PASSWORD_SIMU ~/.dotfiles/zsh/.secret.muttrc | cut -d'"' -f2
```

## Migration from Folder-Based System

Your existing folder-based setup will continue to work. To migrate:

1. **Keep both configs** - Use `muttrc` for old system, `muttrc-notmuch` for new
2. **Test thoroughly** with notmuch before fully switching
3. **Your .txt files work with both** - They're shared between systems
4. **No data loss** - Notmuch doesn't modify your maildir, just indexes it

## Advantages of Notmuch

1. **Multiple tags per email** - An email can be both "waiting" and "important"
2. **Faster search** - Full-text search across all email
3. **No file moving** - Tags are just metadata, files stay in place
4. **Better threading** - Notmuch excels at conversation threading
5. **Scriptable** - Easy to write custom tag rules

## Additional Resources

- [Notmuch Documentation](https://notmuchmail.org/documentation/)
- [Neomutt Notmuch Integration](https://neomutt.org/feature/notmuch)
- [mbsync Documentation](https://isync.sourceforge.io/mbsync.html)

## Support

If you encounter issues:
1. Check logs in `~/.config/mutt/logs/`
2. Run screening script manually to see errors
3. Test notmuch commands directly: `notmuch search`, `notmuch tag`, etc.
