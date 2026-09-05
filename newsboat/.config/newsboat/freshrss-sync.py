#!/usr/bin/env python3
"""Sync the newsboat `urls` file with a FreshRSS server (Google Reader API)
and generate per-category OPML files.

Commands:
  status      show diff between local urls file and FreshRSS (read-only)
  pull        append feeds that exist only on FreshRSS to the urls file
  align       rewrite local feed URLs to the server's exact spelling (newsboat
              matches urls lines to remote feeds by exact string, so http/https
              or trailing-slash drift silently disables tags and hiding)
  prune       comment out local feeds that are not on FreshRSS (server is master)
  push        subscribe feeds that exist only locally on FreshRSS (with category)
  opml        write opml/<category>.opml files derived from the urls file
  sync        pull + prune + opml (server-is-master reconcile)

Nothing is ever deleted: pull/push only add, prune only comments lines out.
Unsubscribing on the server stays a manual decision (push is manual too).

Credentials: reads freshrss-url/freshrss-login from the `config` file next to
this script, and the password from $FRESHRSS_PASSWORD (same as newsboat's
freshrss-passwordeval).
"""

import json
import os
import re
import shlex
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import date
from pathlib import Path
from xml.sax.saxutils import escape, quoteattr

DIR = Path(__file__).resolve().parent
URLS_FILE = DIR / "urls"
CONFIG_FILE = DIR / "config"
OPML_DIR = DIR / "opml"

UNCATEGORIZED = "uncategorized"


# ---------------------------------------------------------------- local side

def parse_urls_file():
    """Return {normalized_url: {url, tags, hidden, title}} for real feed lines."""
    feeds = {}
    for raw in URLS_FILE.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith('"query:') or line == "---":
            continue
        try:
            toks = shlex.split(line)
        except ValueError:
            toks = line.split()
        if not toks or not toks[0].startswith("http"):
            continue
        url, tags, hidden, title = toks[0], [], False, None
        for t in toks[1:]:
            if t == "!":
                hidden = True
            elif t.startswith("~"):
                title = t[1:]
            elif t.startswith("#"):
                continue  # stray inline comment
            else:
                tags.append(t)
        feeds[norm(url)] = {"url": url, "tags": tags, "hidden": hidden, "title": title}
    return feeds


def norm(url):
    """Normalize a feed URL for comparison between urls file and server."""
    u = url.replace("&amp;", "&").strip()
    u = re.sub(r"^http://", "https://", u)
    return u.rstrip("/")


def slug(label):
    """Category label -> newsboat tag (query feeds can't match tags with spaces)."""
    return re.sub(r"\s+", "-", label.strip())


# --------------------------------------------------------------- server side

def read_config():
    cfg = {}
    for line in CONFIG_FILE.read_text().splitlines():
        try:
            toks = shlex.split(line, comments=True)
        except ValueError:
            continue
        if len(toks) >= 2 and toks[0] in ("freshrss-url", "freshrss-login"):
            cfg[toks[0]] = toks[1]
    if "freshrss-url" not in cfg or "freshrss-login" not in cfg:
        sys.exit("error: freshrss-url/freshrss-login not found in config")
    password = os.environ.get("FRESHRSS_PASSWORD")
    if not password:
        sys.exit("error: FRESHRSS_PASSWORD environment variable not set")
    return cfg["freshrss-url"].rstrip("/"), cfg["freshrss-login"], password


def api_login(base, login, password):
    data = urllib.parse.urlencode({"Email": login, "Passwd": password}).encode()
    try:
        with urllib.request.urlopen(base + "/accounts/ClientLogin", data, timeout=30) as r:
            for line in r.read().decode().splitlines():
                if line.startswith("Auth="):
                    return line[len("Auth="):]
    except urllib.error.URLError as e:
        sys.exit(f"error: FreshRSS login failed: {e}")
    sys.exit("error: FreshRSS login failed (no Auth token in response)")


def api(base, auth, path, post=None):
    url = base + "/reader/api/0/" + path
    data = urllib.parse.urlencode(post, doseq=True).encode() if post is not None else None
    req = urllib.request.Request(url, data=data,
                                 headers={"Authorization": f"GoogleLogin auth={auth}"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.read().decode()
    except urllib.error.URLError as e:
        sys.exit(f"error: FreshRSS API call {path} failed: {e}")


def server_feeds(base, auth):
    """Return {normalized_url: {url, title, categories, id}}."""
    body = api(base, auth, "subscription/list?output=json")
    feeds = {}
    for s in json.loads(body).get("subscriptions", []):
        url = s.get("url") or s.get("id", "").removeprefix("feed/")
        feeds[norm(url)] = {
            "url": url,
            "title": s.get("title", ""),
            "categories": [c.get("label", "") for c in s.get("categories", [])],
            "id": s.get("id", ""),
        }
    return feeds


# ----------------------------------------------------------------- commands

def diff_feeds():
    local = parse_urls_file()
    base, login, password = read_config()
    auth = api_login(base, login, password)
    server = server_feeds(base, auth)
    server_only = {k: v for k, v in server.items() if k not in local}
    local_only = {k: v for k, v in local.items() if k not in server}
    return local, server, server_only, local_only, (base, auth)


def cmd_status():
    local, server, server_only, local_only, _ = diff_feeds()
    print(f"local urls file: {len(local)} feeds | FreshRSS: {len(server)} feeds\n")
    if server_only:
        print(f"only on FreshRSS ({len(server_only)}) -> `make pull` adds them to urls:")
        for f in server_only.values():
            cats = ", ".join(f["categories"]) or UNCATEGORIZED
            print(f"  {f['url']}  [{cats}]  {f['title']}")
    if local_only:
        print(f"\nonly in urls file ({len(local_only)}) -> `make push` subscribes them on FreshRSS:")
        for f in local_only.values():
            print(f"  {f['url']}  [{f['tags'][0] if f['tags'] else UNCATEGORIZED}]")
    if not server_only and not local_only:
        print("in sync: no differences.")

    # warn about categories no query-feed group matches (hidden feeds there
    # would be invisible in newsboat's group-only feedlist)
    query_tags = set()
    for raw in URLS_FILE.read_text().splitlines():
        if raw.strip().startswith('"query:'):
            query_tags.update(re.findall(r'\\"([^\\"]+)\\"', raw))
    uncovered = set()
    for f in server.values():
        for label in f["categories"] or [UNCATEGORIZED]:
            tokens = set(label.split()) | {slug(label), label}
            if not tokens & query_tags and label.lower() != UNCATEGORIZED:
                uncovered.add(label)
    if uncovered:
        print("\nwarning: no query-feed group matches these categories "
              "(their feeds are invisible if hidden): " + ", ".join(sorted(uncovered)))


def cmd_pull():
    local, _, server_only, _, _ = diff_feeds()
    if not server_only:
        print("pull: nothing to do, urls file already has every server feed.")
        return
    lines = [f"\n# pulled from FreshRSS {date.today().isoformat()}"]
    for f in server_only.values():
        # "!" hides the single feed from the feedlist; the query-feed groups
        # still aggregate hidden feeds, so only groups stay visible
        parts = [f["url"], "!"]
        cats = [c for c in f["categories"] if c and c.lower() != UNCATEGORIZED]
        parts.append(slug(cats[0]) if cats else UNCATEGORIZED)
        if f["title"]:
            parts.append('"~' + f["title"].replace('"', "'") + '"')
        lines.append(" ".join(parts))
        print(f"  + {f['url']}")
    with URLS_FILE.open("a") as fh:
        fh.write("\n".join(lines) + "\n")
    print(f"pull: appended {len(server_only)} feed(s) to {URLS_FILE.name}. "
          "Review, then `make save`.")


def cmd_push():
    _, _, _, local_only, (base, auth) = diff_feeds()
    if not local_only:
        print("push: nothing to do, FreshRSS already has every local feed.")
        return
    for f in local_only.values():
        body = api(base, auth, "subscription/quickadd?"
                   + urllib.parse.urlencode({"quickadd": f["url"]}), post={})
        try:
            stream_id = json.loads(body).get("streamId", "")
        except json.JSONDecodeError:
            stream_id = ""
        if not stream_id:
            print(f"  ! failed to add {f['url']}: {body[:200]}")
            continue
        edit = {"ac": "edit", "s": stream_id}
        if f["tags"]:
            edit["a"] = "user/-/label/" + f["tags"][0]
        if f["title"]:
            edit["t"] = f["title"]
        if len(edit) > 2:
            api(base, auth, "subscription/edit", post=edit)
        print(f"  + {f['url']}  [{f['tags'][0] if f['tags'] else UNCATEGORIZED}]")
    print(f"push: subscribed {len(local_only)} feed(s) on FreshRSS.")


def cmd_align():
    """Rewrite local URLs to the server's exact URL string where they differ."""
    local, server, _, _, _ = diff_feeds()
    exact = {k: v["url"] for k, v in server.items()}
    out, n = [], 0
    for raw in URLS_FILE.read_text().splitlines():
        line = raw.strip()
        if line and not line.startswith("#") and not line.startswith('"query:') and line != "---" and line.startswith("http"):
            url = line.split()[0]
            want = exact.get(norm(url))
            if want and want != url:
                out.append(want + raw[raw.index(url) + len(url):])
                n += 1
                print(f"  {url} -> {want}")
                continue
        out.append(raw)
    if n:
        URLS_FILE.write_text("\n".join(out) + "\n")
    print(f"align: rewrote {n} URL(s) to match FreshRSS exactly.")


def cmd_prune():
    """Comment out feed lines whose URL is no longer subscribed on FreshRSS."""
    _, _, _, local_only, _ = diff_feeds()
    if not local_only:
        print("prune: nothing to do, every local feed exists on FreshRSS.")
        return
    targets = set(local_only.keys())
    out, n = [], 0
    for raw in URLS_FILE.read_text().splitlines():
        line = raw.strip()
        if line and not line.startswith("#") and not line.startswith('"query:') and line != "---":
            try:
                toks = shlex.split(line)
            except ValueError:
                toks = line.split()
            if toks and toks[0].startswith("http") and norm(toks[0]) in targets:
                out.append("#" + raw)
                n += 1
                print(f"  # {toks[0]}")
                continue
        out.append(raw)
    URLS_FILE.write_text("\n".join(out) + "\n")
    print(f"prune: commented out {n} feed(s) not on FreshRSS (server is master). "
          "Uncomment + `make push` to resurrect one.")


def cmd_opml():
    local = parse_urls_file()
    by_cat = {}
    for f in local.values():
        cat = f["tags"][0] if f["tags"] else UNCATEGORIZED
        by_cat.setdefault(cat, []).append(f)
    OPML_DIR.mkdir(exist_ok=True)
    written = set()
    for cat, feeds in sorted(by_cat.items()):
        safe_name = re.sub(r"[^A-Za-z0-9._-]", "_", cat)
        path = OPML_DIR / f"{safe_name}.opml"
        written.add(path.name)
        out = ['<?xml version="1.0" encoding="UTF-8"?>',
               '<opml version="2.0">',
               f"  <head><title>{escape(cat)}</title></head>",
               "  <body>"]
        for f in sorted(feeds, key=lambda x: (x["title"] or x["url"]).lower()):
            title = f["title"] or f["url"]
            out.append(f"    <outline type=\"rss\" text={quoteattr(title)} "
                       f"title={quoteattr(title)} xmlUrl={quoteattr(f['url'])}/>")
        out += ["  </body>", "</opml>", ""]
        path.write_text("\n".join(out))
        print(f"  wrote {path.relative_to(DIR)} ({len(feeds)} feeds)")
    for stale in OPML_DIR.glob("*.opml"):
        if stale.name not in written:
            stale.unlink()
            print(f"  removed stale {stale.relative_to(DIR)}")
    print(f"opml: {len(by_cat)} category file(s) in {OPML_DIR.name}/.")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        cmd_status()
    elif cmd == "pull":
        cmd_pull()
    elif cmd == "push":
        cmd_push()
    elif cmd == "align":
        cmd_align()
    elif cmd == "prune":
        cmd_prune()
    elif cmd == "opml":
        cmd_opml()
    elif cmd == "sync":
        cmd_pull()
        cmd_align()
        cmd_prune()
        cmd_opml()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
