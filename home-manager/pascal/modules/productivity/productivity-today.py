"""Shows today's active and work time at the computer (ActivityWatch/awatcher)
and logs it to a CSV file. A day runs from 04:00 to 04:00, because the evening
often goes past midnight.

Each run logs today so far and the complete previous day, so the log has full
days even though the evening summary comes before the day is over.

  productivity-today                 summary of today, updates the log
  productivity-today --notify        same, also as a desktop notification
  productivity-today --unmatched [N] active windows that did not count as work,
                                     today or over the last N days

Firefox time is judged by the URL of the active tab when the aw-watcher-web
extension reports it (domain or page title), else by the window title.
"""
import csv
import ipaddress
import json
import os
import re
import subprocess
import sys
import urllib.request
from bisect import bisect_left
from collections import Counter
from datetime import datetime, timedelta
from itertools import accumulate
from urllib.parse import urlsplit

AW = os.environ.get("AW_URL", "http://127.0.0.1:5600")
NOTIFY = os.environ.get("NOTIFY_SEND", "notify-send")
# Matched separately: an app pattern never sees titles and the other way round
# (ActivityWatch's own categorize() checks every field with one regex).
WORK_APPS = re.compile(os.environ.get("WORK_APPS", "ghostty|konsole"), re.IGNORECASE)
WORK_TITLES = re.compile(os.environ.get("WORK_TITLES", "(?!)"), re.IGNORECASE)
# Plain domains (a domain also covers its subdomains) or IP networks like 10.0.0.0/8.
_entries = [d.strip().lower() for d in os.environ.get("WORK_DOMAINS", "").split("|") if d.strip()]
WORK_DOMAINS = [d for d in _entries if "/" not in d]
WORK_NETWORKS = [ipaddress.ip_network(d) for d in _entries if "/" in d]
BROWSER_APP = "firefox"  # windows whose tabs aw-watcher-web reports
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


def host_of(event):
    host = (urlsplit(event.get("data", {}).get("url", "")).hostname or "").lower()
    return host.removeprefix("www.")


def in_work_network(host):
    try:
        ip = ipaddress.ip_address(host)
    except ValueError:
        return False
    return any(ip in net for net in WORK_NETWORKS)


def is_work_web(event):
    host = host_of(event)
    return (
        any(host == d or host.endswith("." + d) for d in WORK_DOMAINS)
        or in_work_network(host)
        or bool(WORK_TITLES.search(event.get("data", {}).get("title", "")))
    )


def aw_query(start, end):
    """Active (not-afk) seconds, the window events during active time and the
    aw-watcher-web tab events while a Firefox window was active."""
    with urllib.request.urlopen(AW + "/api/0/buckets/", timeout=10) as r:
        web_buckets = [b for b in json.load(r) if b.startswith("aw-watcher-web-firefox")]
    query = [
        'afk = flood(query_bucket(find_bucket("aw-watcher-afk_")));',
        'notafk = filter_keyvals(afk, "status", ["not-afk"]);',
        'win = flood(query_bucket(find_bucket("aw-watcher-window_")));',
        "win = filter_period_intersect(win, notafk);",
        f'browser = filter_keyvals_regex(win, "app", "(?i){BROWSER_APP}");',
        "web = [];",
    ]
    for bucket in web_buckets:
        query.append(f"web = concat(web, filter_period_intersect(flood(query_bucket({json.dumps(bucket)})), browser));")
    query.append('RETURN = {"active": sum_durations(notafk), "events": win, "web": web};')
    body = json.dumps({"timeperiods": [f"{start.isoformat()}/{end.isoformat()}"], "query": query}).encode()
    req = urllib.request.Request(AW + "/api/0/query/", data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)[0]


def span(event):
    start = datetime.fromisoformat(event["timestamp"].replace("Z", "+00:00"))
    return start, start + timedelta(seconds=event["duration"])


def classify(res):
    """Splits the active time into work and other events. Firefox windows that
    have tab events are judged by those; the rest by app and window title."""
    web_spans = sorted(span(w) for w in res["web"])
    starts = [s for s, _ in web_spans]
    max_ends = list(accumulate((e for _, e in web_spans), max))

    def has_tab_events(e):
        s, end = span(e)
        i = bisect_left(starts, end)  # tab events starting before this window ends
        return i > 0 and max_ends[i - 1] > s

    work, other = [], []
    for e in res["events"]:
        if re.search(BROWSER_APP, e.get("data", {}).get("app", ""), re.IGNORECASE) and has_tab_events(e):
            continue  # judged by its tab events below
        (work if is_work(e) else other).append(e)
    for w in res["web"]:
        (work if is_work_web(w) else other).append(w)
    return work, other


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
    work, _ = classify(res)
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


def print_unmatched(start, end, top=40):
    """Lists active windows and Firefox domains that did not count as work, longest first."""
    spent = Counter()
    _, other = classify(aw_query(start, end))
    for e in other:
        data = e.get("data", {})
        key = ("firefox tab", host_of(e)) if "url" in data else (data.get("app", ""), data.get("title", ""))
        spent[key] += e["duration"]
    print(f"Not counted as work since {start:%a %Y-%m-%d %H:%M} (app | title, or firefox tab | domain):")
    for (app, what), seconds in spent.most_common(top):
        print(f"{seconds / 60:6.0f} min  {app or '?'} | {what[:100]}")
    if not spent:
        print("  nothing")


def main():
    now = datetime.now().astimezone()
    start = day_start(now)
    if "--unmatched" in sys.argv:
        rest = sys.argv[sys.argv.index("--unmatched") + 1:]
        days = int(rest[0]) if rest and rest[0].isdigit() else 1
        print_unmatched(start - timedelta(days=days - 1), now)
        return
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
