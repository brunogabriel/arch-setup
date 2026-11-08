#!/usr/bin/env python3
"""Retrieve the configured OpenRouter key's usage without exposing secrets."""
import json
import urllib.error
import urllib.request

from openrouter_wallet import read_key


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def main():
    key = read_key()
    request = urllib.request.Request(
        "https://openrouter.ai/api/v1/key",
        headers={"Authorization": "Bearer " + key, "Accept": "application/json"},
    )
    with urllib.request.build_opener(NoRedirect).open(request, timeout=15) as response:
        data = json.load(response).get("data", {})
    print(json.dumps({
        "ok": True,
        "limit": data.get("limit"),
        "remaining": data.get("limit_remaining"),
        "usage": data.get("usage"),
        "reset": data.get("limit_reset"),
        "expiresAt": data.get("expires_at"),
    }))


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as error:
        message = ("OpenRouter rejected the API key (401). Replace an invalid, expired or revoked key."
                   if error.code == 401 else "OpenRouter returned HTTP " + str(error.code))
        print(json.dumps({"ok": False, "error": message}))
    except Exception:
        print(json.dumps({"ok": False, "error": "OpenRouter unavailable. Check the key, KDE Wallet and network connection."}))
