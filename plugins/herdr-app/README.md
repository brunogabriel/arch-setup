# Arch Setup — Herdr App plugin

This plugin installs Arch Setup's Herdr App integration:

- A personal layout with the Codex usage bar above Settings.
- The Codex usage mod and its read-only local Codex App Server helper.
- A personal workspace footer mod that preserves the layout's Settings separator.

The visible usage item remains **Codex**. This package is named **Arch Setup**
so more Herdr App features can be added here later.

## Installation

The main `desktop/herdr-app.sh` installer runs `install.sh` automatically after
installing Herdr App. To install or update only this integration:

```bash
bash plugins/herdr-app/install.sh
```

Files are installed under `${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-~/.config}/herdr-app}`.
If Herdr App is running, the installer switches to the `codex-usage` layout. If
it is not running, open Herdr App and select **codex-usage** in Settings → Layout.

The Codex usage bar requires the Codex CLI to be installed and authenticated.
It reads quota through a temporary read-only local Codex App Server process; it
does not send a model prompt or use the private `wham` endpoint.
