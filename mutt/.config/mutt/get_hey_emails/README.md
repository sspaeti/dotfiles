# get_hey_emails

Scrapes email addresses from your [HEY](https://hey.com) account and writes them to local `.txt` files. Useful for building allowlists/blocklists in mutt or other mail clients.

## What it scrapes

| Flag | Source | Output file |
|---|---|---|
| `--screener` | Screener (approved/denied senders) | `approved_emails.txt`, `denied_emails.txt` |
| `--feed` | The Feed (newsletters) | `feed_emails.txt` |
| `--paper` | Paper Trail (receipts/notifications) | `paper_trail_emails.txt` |

No flag runs all three.

## Setup

Requires [uv](https://github.com/astral-sh/uv). Dependencies are declared in `pyproject.toml`.

### Get your session cookies

HEY uses `httponly` cookies for authentication, so you need to grab them from the browser's Network tab:

1. Open `https://app.hey.com/my/clearances` in your browser
2. Open DevTools → Network tab, find any request to `app.hey.com`
3. Run this in the DevTools Console to copy the non-httponly cookies:

```javascript
copy(['x_user_agent','device_token'].map(name => {
  const val = document.cookie.split('; ').find(c => c.startsWith(name+'='))?.split('=').slice(1).join('=') || '';
  return `export HEY_${name.toUpperCase()}='${val}'`;
}).join('\n'));
```

4. For `session_token` and `_haystack_session` (httponly), copy them manually from **Request Headers → Cookie** in the Network tab.

Export all four:

```bash
export HEY_X_USER_AGENT='...'
export HEY_DEVICE_TOKEN='...'       # long-lived (~20 years)
export HEY_SESSION_TOKEN='...'      # refresh after re-login
export HEY_HAYSTACK_SESSION='...'   # refresh periodically
```

## Usage

```bash
uv run get_screener_emails_from_hey.py            # all
uv run get_screener_emails_from_hey.py --screener
uv run get_screener_emails_from_hey.py --feed
uv run get_screener_emails_from_hey.py --paper
```
