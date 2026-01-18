# arch-setup

Interactive CLI tool for automated Arch Linux/Manjaro system setup.

This project draws inspiration from the following repositories:
- [basecamp/omakub](https://github.com/basecamp/omakub)
- [akitaonrails/omakub-mj](https://github.com/akitaonrails/omakub-mj)

While arch-setup is almost a fork, I created my own to practice terminal skills and bash scripting, with some different applications and architectural decisions. If you're looking for a complete Ubuntu experience, please consider using [omakub](https://github.com/basecamp/omakub). For Manjaro, check out [omakub-mj](https://github.com/akitaonrails/omakub-mj).

---

## Features

- Interactive terminal UI powered by [gum](https://github.com/charmbracelet/gum)
- Modular architecture following KISS principles
- Automatic ZSH configuration system
- Smart dependency resolution
- Theme support for select applications
- Programming language version management via mise
- Installation status tracking
- Idempotent operations

---

## Quick Start

### Prerequisites

- Arch Linux or Manjaro
- Bash 4.0+
- Internet connection

### Installation

```bash
git clone https://github.com/yourusername/arch-setup.git
cd arch-setup
./arch-setup
```

---

## Project Structure

```
arch-setup/
├── arch-setup              # Main entry point
├── core/                   # Core utilities
│   ├── config.sh
│   ├── colors.sh
│   ├── logger.sh
│   ├── requirements.sh
│   ├── user-config.sh
│   ├── themes.sh
│   ├── install-utils.sh
│   ├── zsh-config.sh
│   ├── terminal.sh
│   ├── desktop.sh
│   └── mise-install.sh
├── terminal/               # Terminal tool installers
├── desktop/                # Desktop app installers
├── mise_installs/          # Programming language installers
├── configs/                # Application configurations
│   ├── fastfetch/
│   └── zsh/
├── themes/                 # Theme configurations
│   └── moonlight/
├── AGENTS.md
└── README.md
```

---

## Main Menu

1. **Install All** - Install all terminal tools and desktop applications
2. **Configure System** - Set up Git, user info, and preferences
3. **Install Terminal Tools** - Select and install CLI tools
4. **Install Desktop Applications** - Select and install desktop apps
5. **Install Programming Languages** - Manage language versions via mise
6. **View Installation Status** - Check what's installed
7. **Exit**

---

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

---

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
    
    # Optional: ZSH integration
    smart_append_to_zsh "aliases" \
        "alias tn='toolname'" \
        "toolname - Description"
    
    return 0
}
```

The tool automatically appears in the menu.

### Adding a Programming Language

Create `mise_installs/language.sh`:

```bash
#!/bin/bash

install_language() {
    # Check if mise is installed
    # Prompt for version (latest or custom)
    # Install: mise use -g language@version
    # Add any PATH configurations
}
```

The language automatically appears in the languages menu.

### Adding a Desktop Application

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

The application automatically appears in the menu.

---

## Package Sources

- **pacman** - Official Arch/Manjaro repositories
- **yay** - AUR (Arch User Repository)
- **flatpak** - For select applications
- **mise** - Language version management
- **curl** - Direct installation for select tools

All dependencies are installed automatically when needed.

---

## Logging

All operations are logged to `~/.config/arch-setup/arch-setup.log`

---

## Contributing

Contributions are welcome! See [AGENTS.md](AGENTS.md) for coding guidelines.

---

## License

arch-setup is released under the [MIT License](https://opensource.org/license/MIT).

---

## Credits

This project was inspired by:
- [basecamp/omakub](https://github.com/basecamp/omakub) - The original Ubuntu setup tool
- [akitaonrails/omakub-mj](https://github.com/akitaonrails/omakub-mj) - Manjaro adaptation

Special thanks to:
- [Charm](https://charm.sh/) for [gum](https://github.com/charmbracelet/gum)
- The Arch Linux and Manjaro communities
- All open-source tool maintainers
