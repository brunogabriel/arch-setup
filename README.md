# arch-setup

Interactive CLI tool for automated Arch Linux-based system setup (EndeavourOS, Manjaro, etc.).

Inspired by [omakub](https://github.com/basecamp/omakub) and [omakub-mj](https://github.com/akitaonrails/omakub-mj).

## Features

- Interactive terminal UI powered by [gum](https://github.com/charmbracelet/gum)
- Modular architecture following KISS principles
- Automatic ZSH configuration system
- Smart dependency resolution
- Theme support for select applications
- Programming language version management via mise
- Installation status tracking
- Idempotent operations

## Quick Start

### Prerequisites

- Arch Linux, EndeavourOS, or Manjaro
- Bash 4.0+
- Internet connection

### Installation

```bash
git clone https://github.com/brunogabriel/arch-setup.git
cd arch-setup
./arch-setup
```

## What You Get

### Terminal Tools

fzf, ripgrep, bat, eza, zoxide, starship, fastfetch, lazydocker, github-cli, mise, uv, and more

### Desktop Apps

ghostty, kitty, brave, chrome, vscode, cursor, obsidian, steam, bitwarden, gimp, and more

### Languages (via mise)

node, bun, dotnet, flutter, java

### Extras

bluetooth setup, firmware updates, kernel cleanup

## Project Structure

```
arch-setup/
├── arch-setup              # Main entry point
├── core/                   # Core utilities, sourced in order by the main script
├── terminal/               # Terminal tool installers (one .sh per tool)
├── desktop/                # Desktop app installers (one .sh per app)
├── mise_installs/          # Programming language installers (one .sh per language)
├── extras/                 # System/hardware extras
├── configs/                # Application configurations
├── themes/                 # Theme configurations
└── AGENTS.md
```

## ZSH Configuration

arch-setup uses a modular ZSH configuration system:

```
~/.zshrc     # Main file (sources all modules)
~/.init      # Tool initialization code
~/.aliases   # Command aliases
~/.shell     # Shell configuration and environment variables
```

Tools automatically add their configurations when installed. The system:

- Converts existing `.zshrc` to modular structure
- Prevents duplicate entries
- Keeps configurations organized by purpose

## Extending arch-setup

### Adding a Terminal Tool

Create `terminal/toolname.sh`:

```bash
#!/bin/bash

install_toolname() {
    log_info "Installing toolname..."

    if ! yay_install "package-name"; then
        return 1
    fi

    smart_append_to_zsh "aliases" \
        "alias tn='toolname'" \
        "toolname - Description"

    return 0
}
```

### Adding a Desktop App

Create `desktop/appname.sh`:

```bash
#!/bin/bash

install_appname() {
    log_info "Installing appname..."

    if ! yay_install "package-name"; then
        return 1
    fi

    return 0
}
```

### Adding a Programming Language

Create `mise_installs/language.sh`:

```bash
#!/bin/bash

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

## Package Sources

- **pacman** - Official Arch-based repositories
- **yay** - AUR (Arch User Repository)
- **flatpak** - For select applications
- **mise** - Language version management
- **curl** - Direct installation for select tools

## Logging

All operations are logged to `~/.config/arch-setup/arch-setup.log`

## Contributing

Contributions are welcome! See [AGENTS.md](AGENTS.md) for coding guidelines.

## License

arch-setup is released under the [MIT License](https://opensource.org/license/MIT).

## Credits

Inspired by:

- [basecamp/omakub](https://github.com/basecamp/omakub) - The original Ubuntu setup tool
- [akitaonrails/omakub-mj](https://github.com/akitaonrails/omakub-mj) - Manjaro adaptation

Special thanks to:

- [Charm](https://charm.sh/) for [gum](https://github.com/charmbracelet/gum)
- The Arch Linux, EndeavourOS, and Manjaro communities
- All open-source tool maintainers
