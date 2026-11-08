# AI Usage for Plasma

A Plasma 6 System Tray widget that displays AI provider quotas through a
normalized provider adapter contract. The initial adapter reads Codex limits through the
Codex CLI's local, read-only `app-server` interface. It does not use the
`ai-usagebar` executable or read/write Codex credential files directly.

## Install

Select **AI Usage for Plasma** in Arch Setup's **Plugins** list. Then open the
System Tray settings, enable **AI Usage**, and set it to always shown. Do not
add it separately through **Add or Manage Widgets**: doing both creates two
instances. The tray shows only an icon; click it for the popup with percentages
and bars. The Codex CLI must be installed and logged in for quota data to load.
The widget's catalog icon is separate from the active provider icon shown in
the tray. With one provider, the popup displays its name; the provider selector
appears when more adapters are available.

Open **AI Usage Settings → Providers** to enable or hide Codex (OpenAI) and
OpenRouter. Codex is enabled by default. The OpenRouter key editor saves the
key immediately to KDE Wallet (independent of Apply/Cancel). It requires
Python 3, PyQt6, `qdbus6`, `kwallet-query`, and an available KDE Wallet. The
widget uses the OpenRouter `/api/v1/key` endpoint; its percentage represents the
key's own spending limit, not account credits. Keys without a spending limit
have no percentage; a remaining dollar amount is shown only if the API returns
one. The account credits endpoint requires a separate management key and is
not queried. A rejected key must be replaced in settings; transient
network or wallet failures are shown without deleting the stored key.

## Provider contract

Each adapter normalizes its provider's response to this shape:

```json
{
  "id": "codex",
  "name": "Codex",
  "icon": "codex",
  "limits": [
    {
      "label": "5-hour limit",
      "description": "Resets in 4h 29m",
      "remaining": 99.0
    }
  ]
}
```

Add provider modules under `package/contents/code/adapters/` and register them
in `ProviderRegistry.js`. The UI only consumes the normalized object, so each
adapter can use its own HTTP endpoint, CLI, or local credential source.

Icons are resolved from `package/contents/images/<icon>.svg` and installed into
the user's hicolor icon theme; unknown icon names fall back to the system
`applications-development` icon.

The Codex icon is adapted from [Lobe Icons](https://github.com/lobehub/lobe-icons)
to use KDE's symbolic icon colors. Brand marks remain property of their owners.
