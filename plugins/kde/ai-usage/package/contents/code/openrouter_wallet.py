#!/usr/bin/env python3
"""Edit the OpenRouter credential without passing it in process arguments."""
import subprocess
import sys


def wallet_name():
    result = subprocess.run(
        ["qdbus6", "org.kde.kwalletd6", "/modules/kwalletd6", "org.kde.KWallet.networkWallet"],
        capture_output=True, text=True, timeout=10, check=True,
    )
    name = result.stdout.strip()
    if not name:
        raise RuntimeError("KDE Wallet is unavailable")
    return name


def read_key():
    result = subprocess.run(
        ["kwallet-query", "-f", "Passwords", "-r", "arch-setup-ai-usage-openrouter", wallet_name()],
        capture_output=True, text=True, timeout=60, check=True,
    )
    key = result.stdout.strip()
    if not key:
        raise RuntimeError("No OpenRouter key configured")
    return key


def edit_key():
    from PyQt6.QtWidgets import QApplication, QInputDialog, QLineEdit

    app = QApplication(sys.argv)
    key, ok = QInputDialog.getText(None, "OpenRouter", "API key:", QLineEdit.EchoMode.Password)
    if not ok:
        print("Cancelled")
        return
    key = key.strip()
    if not key or "\n" in key or "\r" in key:
        raise RuntimeError("Enter a non-empty single-line API key")
    subprocess.run(
        ["kwallet-query", "-f", "Passwords", "-w", "arch-setup-ai-usage-openrouter", wallet_name()],
        input=key, text=True, capture_output=True, timeout=60, check=True,
    )
    print("Key saved in KDE Wallet. Refresh OpenRouter to check it.")


if __name__ == "__main__":
    try:
        edit_key()
    except Exception:
        print("Could not save the key. Check KDE Wallet, kwallet-query and PyQt6.", file=sys.stderr)
        sys.exit(1)
