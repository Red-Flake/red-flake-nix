"""Break reminder: counts active minutes at the computer from the AFK bucket
that awatcher writes to ActivityWatch, and asks for a break after N minutes
without a real one.

awatcher dates an "afk" event back to the last input, so an afk event lasts as
long as the actual break. A gap without any events (suspend, shutdown, watcher
stopped) counts as a break too.
"""
import json
import os
import subprocess
import threading
import time
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

AW = os.environ.get("AW_URL", "http://127.0.0.1:5600")
NOTIFY = os.environ.get("NOTIFY_SEND", "notify-send")
GDBUS = os.environ.get("GDBUS", "gdbus")
ACTIVE_MIN = float(os.environ.get("ACTIVE_MINUTES", "90"))
BREAK_MIN = float(os.environ.get("BREAK_MINUTES", "10"))
REPEAT_MIN = float(os.environ.get("REPEAT_MINUTES", "15"))
CRITICAL_MIN = float(os.environ.get("CRITICAL_MINUTES", "120"))
SNOOZE_MIN = float(os.environ.get("SNOOZE_MINUTES", "30"))
POLL_S = 60
LOOKBACK = timedelta(hours=6)


def parse_ts(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def get_json(path):
    with urllib.request.urlopen(AW + path, timeout=10) as r:
        return json.load(r)


def afk_bucket():
    for bucket_id in get_json("/api/0/buckets/"):
        if bucket_id.startswith("aw-watcher-afk_"):
            return bucket_id
    return None


def active_streak_seconds(events, now):
    """Active seconds since the last real break (BREAK_MIN without input)."""
    brk = BREAK_MIN * 60
    streak = 0.0
    last_end = None
    last_status = None
    for e in sorted(events, key=lambda e: parse_ts(e["timestamp"])):
        start = parse_ts(e["timestamp"])
        end = min(start + timedelta(seconds=e["duration"]), now)
        dur = max((end - start).total_seconds(), 0)
        if last_end is not None and (start - last_end).total_seconds() >= brk:
            streak = 0.0
        status = e.get("data", {}).get("status")
        if status == "afk" and dur >= brk:
            streak = 0.0
        elif status == "not-afk":
            streak += dur
        if last_end is None or end >= last_end:
            last_end, last_status = end, status
    if last_end is None or (now - last_end).total_seconds() >= brk:
        return 0.0
    # While active, awatcher reports not-afk only up to now minus its idle
    # timeout. Still not-afk means active until now.
    if last_status == "not-afk":
        streak += (now - last_end).total_seconds()
    return streak


class Reminder:
    """Decides when to remind and keeps at most one reminder on screen."""

    def __init__(self):
        self.lock = threading.Lock()
        self.last_shown = None
        self.snooze_until = None
        self.notification_id = None
        self.proc = None

    def tick(self, streak_min, now):
        """Returns "close" after a real break, ("show", critical) when a
        reminder is due, else None."""
        with self.lock:
            if streak_min < ACTIVE_MIN:
                shown = self.last_shown is not None
                self.last_shown = None
                self.snooze_until = None
                return "close" if shown else None
            if self.snooze_until and now < self.snooze_until:
                return None
            if self.last_shown and now - self.last_shown < timedelta(minutes=REPEAT_MIN):
                return None
            self.last_shown = now
            self.snooze_until = None
        return "show", streak_min >= CRITICAL_MIN

    def close(self):
        with self.lock:
            notification_id, self.notification_id = self.notification_id, None
            proc, self.proc = self.proc, None
        if notification_id:
            subprocess.run(
                [GDBUS, "call", "--session", "--dest", "org.freedesktop.Notifications",
                 "--object-path", "/org/freedesktop/Notifications",
                 "--method", "org.freedesktop.Notifications.CloseNotification", str(notification_id)],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False,
            )
        if proc and proc.poll() is None:
            proc.terminate()

    def show(self, minutes, critical):
        self.close()
        cmd = [
            NOTIFY, "--app-name=Break reminder", "--icon=chronometer", "--print-id",
            "--urgency=" + ("critical" if critical else "normal"),
            "--action=ok=On it", f"--action=snooze=Later ({int(SNOOZE_MIN)} min)",
            "Time for a break",
            f"{int(minutes)} min of active work. Get up and step away from the screen for {int(BREAK_MIN)} min.",
        ]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        with self.lock:
            self.proc = proc
        threading.Thread(target=self._wait, args=(proc,), daemon=True).start()

    def _wait(self, proc):
        # notify-send prints the notification id right away, then the chosen
        # action once the notification is clicked or closed.
        first = proc.stdout.readline().strip()
        if first.isdigit():
            with self.lock:
                if self.proc is proc:
                    self.notification_id = int(first)
        action = proc.stdout.readline().strip()
        proc.wait()
        with self.lock:
            if self.proc is proc:
                self.proc = None
                self.notification_id = None
            if action == "snooze":
                self.snooze_until = datetime.now(timezone.utc) + timedelta(minutes=SNOOZE_MIN)


def main():
    reminder = Reminder()
    bucket = None
    while True:
        try:
            bucket = bucket or afk_bucket()
            if bucket:
                now = datetime.now(timezone.utc)
                start = urllib.parse.quote((now - LOOKBACK).isoformat())
                events = get_json(f"/api/0/buckets/{bucket}/events?start={start}&limit=-1")
                streak_min = active_streak_seconds(events, now) / 60
                result = reminder.tick(streak_min, now)
                if result == "close":
                    reminder.close()
                elif result:
                    reminder.show(streak_min, critical=result[1])
        except Exception as exc:  # ActivityWatch not up yet, restarted, ...
            bucket = None
            print(f"break-reminder: {exc}", flush=True)
        time.sleep(POLL_S)


if __name__ == "__main__":
    main()
