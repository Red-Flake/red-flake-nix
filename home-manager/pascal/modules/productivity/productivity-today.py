"""Shows today's active and work time at the computer (ActivityWatch/awatcher)
and logs it to a CSV file. A day runs from 04:00 to 04:00, because the evening
often goes past midnight.

Each run logs today so far and the complete previous day, so the log has full
days even though the evening summary comes before the day is over.
"""
import csv
import json
import os
import re
import subprocess
import sys
import urllib.request
from datetime import datetime, timedelta

AW = os.environ.get("AW_URL", "http://127.0.0.1:5600")
NOTIFY = os.environ.get("NOTIFY_SEND", "notify-send")
# Matched separately: an app pattern never sees titles and the other way round
# (ActivityWatch's own categorize() checks every field with one regex).
WORK_APPS = re.compile(os.environ.get("WORK_APPS", "ghostty|konsole"), re.IGNORECASE)
WORK_TITLES = re.compile(os.environ.get("WORK_TITLES", "(?!)"), re.IGNORECASE)
LOG = os.path.expanduser(os.environ.get("PRODUCTIVITY_LOG", "~/.local/share/productivity/log.csv"))
DAY_START_HOUR = 4
MERGE_GAP_S = 10 * 60  # work events closer than this form one window
MIN_WINDOW_S = 15 * 60  # shorter windows are dropped


def day_start(now):
    start = now.replace(hour=DAY_START_HOUR, minute=0, second=0, microsecond=0)
    return start - timedelta(days=1) if now < start else start


def is_work(event):
    data = event.get("data", {})
    return bool(WORK_APPS.search(data.get("app", "")) or WORK_TITLES.search(data.get("title", "")))


def aw_query(start, end):
    """Active (not-afk) seconds and the window events during active time."""
    query = [
        'afk = flood(query_bucket(find_bucket("aw-watcher-afk_")));',
        'notafk = filter_keyvals(afk, "status", ["not-afk"]);',
        'win = flood(query_bucket(find_bucket("aw-watcher-window_")));',
        "win = filter_period_intersect(win, notafk);",
        'RETURN = {"active": sum_durations(notafk), "events": win};',
    ]
    body = json.dumps({"timeperiods": [f"{start.isoformat()}/{end.isoformat()}"], "query": query}).encode()
    req = urllib.request.Request(AW + "/api/0/query/", data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)[0]


def windows(events):
    """Merges work events into time windows, local time."""
    spans = []
    for e in events:
        s = datetime.fromisoformat(e["timestamp"].replace("Z", "+00:00")).astimezone()
        spans.append((s, s + timedelta(seconds=e["duration"])))
    merged = []
    for s, e in sorted(spans):
        if merged and (s - merged[-1][1]).total_seconds() < MERGE_GAP_S:
            merged[-1][1] = max(merged[-1][1], e)
        else:
            merged.append([s, e])
    return [(s, e) for s, e in merged if (e - s).total_seconds() >= MIN_WINDOW_S]


def report(start, end):
    res = aw_query(start, end)
    work = [e for e in res["events"] if is_work(e)]
    return res["active"], sum(e["duration"] for e in work), windows(work)


def fmt_h(seconds):
    return f"{seconds / 3600:.1f} h"


def write_log(days):
    """days: {date: (active, work, windows)}; replaces those rows, keeps the rest."""
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    rows = {}
    if os.path.exists(LOG):
        with open(LOG, newline="") as f:
            rows = {r["date"]: r for r in csv.DictReader(f)}
    for day, (active, work, wins) in days.items():
        rows[day] = {
            "date": day,
            "active_min": round(active / 60),
            "work_min": round(work / 60),
            "windows": " ".join(f"{s:%H:%M}-{e:%H:%M}" for s, e in wins),
        }
    with open(LOG, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["date", "active_min", "work_min", "windows"])
        w.writeheader()
        for day in sorted(rows):
            w.writerow(rows[day])


def main():
    now = datetime.now().astimezone()
    start = day_start(now)
    yesterday = start - timedelta(days=1)
    today = report(start, now)
    write_log({f"{yesterday:%Y-%m-%d}": report(yesterday, start), f"{start:%Y-%m-%d}": today})

    active, work, wins = today
    wins_text = ", ".join(f"{s:%H:%M}–{e:%H:%M}" for s, e in wins) or "none of 15 min or more"
    text = f"Active at the computer: {fmt_h(active)}\nOf that, work: {fmt_h(work)}\nWork windows: {wins_text}"
    print(f"{start:%a %Y-%m-%d}\n{text}")
    if "--notify" in sys.argv:
        subprocess.run([NOTIFY, "--app-name=Productivity", "--icon=chronometer", "Today at the computer", text], check=False)


if __name__ == "__main__":
    main()
