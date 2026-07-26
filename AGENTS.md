# AGENTS.md - arch-setup

Interactive CLI for Arch Linux setup (EndeavourOS, Manjaro). Bash + [gum](https://github.com/charmbracelet/gum) UI.

## Architecture

`arch-setup` sources all `core/*.sh` modules in order, then enters a menu loop. Each menu action calls a function defined in one of those modules.

**Source order matters.** Modules depend on functions defined earlier. `config.sh` → `colors.sh` → `logger.sh` → `requirements.sh` → ... → `install-utils.sh` → `run-installers.sh`.

### Auto-discovery

Installer scripts in `terminal/`, `desktop/`, `extras/`, `mise_installs/` are auto-discovered by scanning `*.sh` files. **Adding a new tool = creating a new file.** No other files need modification.

The file `foo-bar.sh` must define `install_foo_bar()` (dashes → underscores). `run-installers.sh` handles sourcing + calling + result tracking.

### Core modules

| Module | Role |
|--------|------|
| `config.sh` | Global vars (`INSTALL_DIR`, `CONFIG_DIR`, etc.) |
| `colors.sh` | Arch brand colors (81 cyan, 75 blue, 48 green, 196 red, 214 orange) |
| `logger.sh` | `log_info` / `log_success` / `log_warning` / `log_error` → `~/.config/arch-setup/arch-setup.log` |
| `requirements.sh` | Installs `gum` (via raw `echo` before gum exists), then `check_installation_requirements()` for curl/git/unzip/base-devel/yay |
| `install-utils.sh` | `pacman_install`, `yay_install`, `pacman_uninstall`, `yay_uninstall`, `is_installed` |
| `run-installers.sh` | `scan_installers(subdir)`, `run_installers(items, subdir, show_progress)`, `show_install_summary()` |
| `zsh-config.sh` | `smart_append_to_zsh(module, code, description)` — idempotent, modular (`~/.init`, `~/.aliases`, `~/.shell`) |
| `themes.sh` | `apply_app_theme(name)`, `apply_theme_for_app(name, dir)` |

### Package installation

**Use `pacman_install` for official repos (default). Use `yay_install` only for AUR packages.**

```bash
# Official repos
pacman_install "fzf"

# Multiple packages at once
pacman_install "docker" "docker-compose"

# AUR only (proprietary binaries, niche apps)
yay_install "cursor-bin"
```

Both accept one or more package names and handle: already-installed check, installation, theme application, logging.

## Verification

```bash
# Syntax check (all scripts)
bash -n arch-setup && bash -n core/*.sh && bash -n terminal/*.sh && bash -n desktop/*.sh
```

No CI, no test suite, no linter configured.

## Conventions

- **No `set -e`** in sourced libraries (breaks error handling in loops). Only the main script could use it.
- **Quote all variables:** `"$variable"` — prevents word splitting.
- **`local` for all function-scoped variables.**
- **Return 0 for success, 1 for failure.** Orchestrators count success/fail and show summary.
- **gum for all user-facing output.** Never raw `echo` for messages (exception: `requirements.sh` lines 56-62 fire before gum is installed).
- **`smart_append_to_zsh` for all ZSH changes.** Never manually edit `~/.zshrc`.
- **No hardcoded paths** for user dirs — use `$INSTALL_DIR`, `$CONFIG_DIR`. System paths (`/etc/docker`, `/usr/share/...`) are fine.

### Adding a terminal tool

```bash
#!/bin/bash
# terminal/tool-name.sh
# Short description

install_tool_name() {
    log_info "Installing tool-name..."

    if ! pacman_install "package-name"; then
        return 1
    fi

    smart_append_to_zsh "aliases" \
        "alias tn='tool-name'" \
        "tool-name - Description"

    return 0
}
```

### Adding a desktop app

Same pattern in `desktop/`. Use `yay_install` only if the package is AUR-only.

### Adding a programming language (mise)

```bash
#!/bin/bash
# mise_installs/language.sh
# Language via mise

install_language() {
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise not installed"
        return 1
    fi

    local version
    version=$(gum choose "latest (Recommended)" "Custom version")

    mise use -g language@"$version"

    return 0
}
```

## Gum color palette

81 = Cyan (primary) · 75 = Blue (secondary) · 69 = Dark blue · 48 = Green (success) · 196 = Red (error) · 214 = Orange (warning)
