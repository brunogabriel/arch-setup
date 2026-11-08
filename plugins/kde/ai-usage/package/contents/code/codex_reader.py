#!/usr/bin/env python3
"""Read Codex quota through its short-lived, read-only local app-server."""

import json
import os
import selectors
import shutil
import subprocess
import sys
import time


def rpc(proc, selector, pending, payload, request_id, timeout=20):
    proc.stdin.write((json.dumps(payload, separators=(",", ":")) + "\n").encode())
    proc.stdin.flush()
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        events = selector.select(max(0, deadline - time.monotonic()))
        if not events:
            break
        chunk = os.read(proc.stdout.fileno(), 65536)
        if not chunk:
            break
        pending.extend(chunk)
        while b"\n" in pending:
            line, _, rest = pending.partition(b"\n")
            pending[:] = rest
            try:
                message = json.loads(line)
            except (UnicodeDecodeError, json.JSONDecodeError):
                continue
            if message.get("id") == request_id:
                if "error" in message:
                    raise RuntimeError("rpc_error")
                return message.get("result", {})
    raise RuntimeError("rpc_timeout")


def window(raw):
    if not isinstance(raw, dict):
        return None
    return {
        "usedPercent": raw.get("usedPercent"),
        "windowDurationMins": raw.get("windowDurationMins"),
        "resetsAt": raw.get("resetsAt"),
    }


def codex_executable():
    executable = shutil.which("codex")
    if executable:
        return executable

    for candidate in (
        os.path.expanduser("~/.local/bin/codex"),
        os.path.expanduser("~/.cargo/bin/codex"),
        "/usr/bin/codex",
    ):
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return candidate
    raise FileNotFoundError("codex CLI not found")


def main():
    proc = subprocess.Popen(
        [
            codex_executable(), "-c", "approval_policy=never",
            "-c", "features.plugins=false", "-s", "read-only",
            "-a", "never", "app-server",
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        bufsize=0,
    )
    selector = selectors.DefaultSelector()
    selector.register(proc.stdout, selectors.EVENT_READ)
    pending = bytearray()
    try:
        rpc(proc, selector, pending, {
            "method": "initialize", "id": 1,
            "params": {"clientInfo": {"name": "arch-setup-ai-usage", "version": "0.1.0"}},
        }, 1)
        proc.stdin.write(b'{"method":"initialized","params":{}}\n')
        proc.stdin.flush()
        result = rpc(proc, selector, pending, {
            "method": "account/rateLimits/read", "id": 2, "params": {},
        }, 2)
        limits = result.get("rateLimits") or {}
        if not isinstance(limits, dict):
            raise RuntimeError("invalid_result")
        print(json.dumps({
            "ok": True,
            "primary": window(limits.get("primary")),
            "secondary": window(limits.get("secondary")),
            "readAt": int(time.time()),
        }, separators=(",", ":")))
    finally:
        selector.close()
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()


try:
    main()
except Exception as error:
    print(json.dumps({"ok": False, "error": str(error)}))
    sys.exit(1)
