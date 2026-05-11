#!/usr/bin/env python3
"""waybar tooltip: agenda from morgen-calendar CLI (Personal/Family/Work)."""
import html
import json
import os
import re
import shutil
import subprocess
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

ICON = "󰃭"
ALLOWED = {"Personal", "Family", "Work"}
DAYS_AHEAD = 7
ANSI = re.compile(r"\x1b\[[0-9;]*m")


def emit(tooltip: str) -> None:
    print(json.dumps({"text": ICON, "tooltip": tooltip}))


def find_cli() -> str | None:
    candidates = [
        Path.home() / ".local" / "bin" / "morgen-calendar",
        Path("/usr/local/bin/morgen-calendar"),
        Path("/usr/bin/morgen-calendar"),
    ]
    for p in candidates:
        if p.exists():
            return str(p)
    return shutil.which("morgen-calendar")


def run_cli() -> tuple[str, str, int] | None:
    cli = find_cli()
    if not cli:
        return None
    today = date.today()
    end_day = today + timedelta(days=DAYS_AHEAD)
    start_iso = datetime.combine(today, datetime.min.time(), timezone.utc).isoformat().replace("+00:00", "Z")
    end_iso = datetime.combine(end_day, datetime.max.time().replace(microsecond=0), timezone.utc).isoformat().replace("+00:00", "Z")
    env = os.environ.copy()
    extra = [
        str(Path.home() / ".local" / "share" / "mise" / "shims"),
        str(Path.home() / ".local" / "bin"),
    ]
    env["PATH"] = ":".join(extra + [env.get("PATH", "")])
    proc = subprocess.run(
        [cli, "le", "--all", "--start", start_iso, "--end", end_iso],
        capture_output=True, text=True, timeout=25, env=env,
    )
    return ANSI.sub("", proc.stdout), ANSI.sub("", proc.stderr), proc.returncode


def parse_events(stdout: str) -> list[dict]:
    events: list[dict] = []
    cur: dict | None = None

    def flush():
        nonlocal cur
        if cur and cur.get("title") and cur.get("calendar"):
            events.append(cur)
        cur = None

    skip_prefixes = (
        "===", "Total:", "Accounts:", "Timezone:", "Warning:",
        "Error", "No events", "- ",
    )
    for line in stdout.splitlines():
        if not line.strip():
            flush()
            continue
        if line.startswith("  "):
            if cur is None:
                continue
            s = line.strip()
            if s.startswith("Calendar:"):
                cur["calendar"] = s[len("Calendar:"):].strip()
            elif s.startswith("Start:"):
                cur["start"] = s[len("Start:"):].strip()
            elif s.startswith("All Day:"):
                cur["all_day"] = s[len("All Day:"):].strip().lower() == "yes"
            continue
        # non-indented: candidate title
        flush()
        s = line.strip()
        if any(s.startswith(p) for p in skip_prefixes):
            continue
        cur = {"title": s}
    flush()
    return events


def format_time(start: str, all_day: bool) -> tuple[date, int, str] | None:
    """Returns (date, minutes-of-day or -1 for all-day, display string)."""
    m = re.match(r"^(\d{4}-\d{2}-\d{2})(?:[T ](\d{2}):(\d{2}))?", start)
    if not m:
        return None
    d = date.fromisoformat(m.group(1))
    if all_day or not m.group(2):
        return d, -1, "All day"
    h, mi = int(m.group(2)), int(m.group(3))
    return d, h * 60 + mi, f"{h:02d}:{mi:02d}"


def day_header(d: date, today: date) -> str:
    if d == today:
        return "Today"
    if d == today + timedelta(days=1):
        return "Tomorrow"
    return d.strftime("%a, %b %d")


def main() -> None:
    try:
        result = run_cli()
    except subprocess.TimeoutExpired:
        emit("morgen-calendar timeout")
        return
    if result is None:
        emit("morgen-calendar not found in PATH or ~/.local/bin")
        return
    stdout, stderr, _ = result

    if "API key not configured" in stdout or "API key not configured" in stderr:
        emit("Morgen API key not set\nRun: morgen-config set apiKey &lt;key&gt;")
        return

    today = date.today()
    end = today + timedelta(days=DAYS_AHEAD)

    rows: list[tuple[date, int, str, str]] = []
    for ev in parse_events(stdout):
        if ev.get("calendar") not in ALLOWED:
            continue
        parsed = format_time(ev.get("start", ""), ev.get("all_day", False))
        if not parsed:
            continue
        d, mins, time_str = parsed
        if d < today or d > end:
            continue
        rows.append((d, mins, time_str, ev["title"]))

    rows.sort(key=lambda r: (r[0], r[1]))

    if not rows:
        emit("No events in next 7 days")
        return

    lines: list[str] = []
    last_day: date | None = None
    for d, _mins, t, title in rows:
        if d != last_day:
            if lines:
                lines.append("")
            lines.append(day_header(d, today))
            last_day = d
        lines.append(f"{t:<7}  -  {html.escape(title)}")
    emit("\n".join(lines))


if __name__ == "__main__":
    main()
