# AGENTS.md - Coding Agent Guidelines for arch-setup

## Project Overview

**arch-setup** is an interactive CLI tool for automating Arch Linux/Manjaro system setup. Built with Bash and [gum](https://github.com/charmbracelet/gum) for terminal UI.

**Architecture:** Clean Architecture (KISS principle) - modular, simple, no over-engineering.

---

## Project Structure

```
arch-setup/
├── arch-setup              # Main orchestrator (387 lines)
├── core/                   # Core utilities (11 modules)
│   ├── config.sh          # Global config + INSTALL_DIR detection
│   ├── colors.sh          # Arch Linux brand colors (81, 75, 69)
│   ├── logger.sh          # Logging system (~/.config/arch-setup/arch-setup.log)
│   ├── requirements.sh    # Dependency checker + pacman/yay setup
│   ├── user-config.sh     # User configuration (name/email/theme)
│   ├── themes.sh          # Theme management (btop, kitty, warp)
│   ├── install-utils.sh   # Universal install utilities (yay_install)
│   ├── zsh-config.sh      # ZSH modular configuration system
│   ├── terminal.sh        # Terminal tools orchestrator
│   ├── desktop.sh         # Desktop apps orchestrator
│   └── mise-install.sh    # Programming languages orchestrator
├── terminal/              # Terminal app installers (22 tools)
│   └── *.sh              # Each tool has install_<tool>() function
├── desktop/               # Desktop app installers (25 apps)
│   └── *.sh              # Each app has install_<app>() function
├── mise_installs/         # Programming language installers
│   └── flutter.sh        # Example: version selection + PATH config
├── configs/zsh/           # Modular ZSH configs (zshrc, init, aliases, shell)
├── themes/moonlight/      # Theme configs (btop, kitty, warp-terminal)
└── README.md
```

---

## Build, Test & Lint

### Run Application
```bash
./arch-setup                # Interactive CLI (main entry point)
```

### Test Individual Components
```bash
# Test a specific installer directly
bash -c "source core/config.sh && source core/colors.sh && source core/logger.sh && \
         source core/install-utils.sh && source terminal/fzf.sh && install_fzf"

# Test ZSH configuration system
bash -c "source core/config.sh && source core/colors.sh && source core/logger.sh && \
         source core/zsh-config.sh && check_zshrc_structure"

# Verify user config exists
cat ~/.config/arch-setup/user.conf

# Check installation status
./arch-setup  # Select option 6: "View Installation Status"
```

### Syntax Check
```bash
# Check syntax without executing (all scripts)
bash -n arch-setup
bash -n core/*.sh
bash -n terminal/*.sh
bash -n desktop/*.sh

# Check single file
bash -n terminal/fzf.sh
```

### Linting
```bash
# Install shellcheck
sudo pacman -S shellcheck

# Lint all scripts
shellcheck arch-setup core/*.sh terminal/*.sh desktop/*.sh mise_installs/*.sh

# Lint single file
shellcheck core/zsh-config.sh

# Ignore specific warnings
shellcheck -e SC2086 arch-setup  # Ignore double quote around $var
```

---

## Code Style Guidelines

### Bash Script Structure

**Every bash file MUST:**
1. Start with shebang: `#!/bin/bash`
2. Have descriptive header comment (module path + description)
3. Use `set -e` in main scripts ONLY (not in sourced libraries - breaks error handling)
4. Define functions before using them

**Example:**
```bash
#!/bin/bash

# terminal/fzf.sh
# Fuzzy finder installer

install_fzf() {
    local package="fzf"
    # implementation
}
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| **Files** | lowercase-with-dashes.sh | `user-config.sh`, `mise-install.sh` |
| **Functions** | snake_case | `check_requirements()`, `install_fzf()` |
| **Variables (local)** | snake_case | `local user_name="Bruno"` |
| **Constants (global)** | UPPER_SNAKE_CASE | `APP_VERSION="1.0.0"` |
| **Readonly** | readonly UPPER_SNAKE_CASE | `readonly COLOR_RESET='\033[0m'` |
| **Arrays** | UPPER_SNAKE_CASE | `REQUIRED_PACKAGES=()` |

### Variables

**Always:**
- Use `local` for all function-scoped variables
- Use `readonly` for constants that never change
- Quote all variables: `"$variable"` (prevents word splitting)
- Use `${variable}` for clarity in string interpolation

**Example:**
```bash
# Global constants (in config.sh)
readonly APP_NAME="arch-setup"
readonly APP_VERSION="1.0.0"

# Mutable globals
CONFIG_DIR="$HOME/.config/arch-setup"
LOG_FILE="$CONFIG_DIR/arch-setup.log"

# Function with locals
install_package() {
    local package=$1
    local version=${2:-"latest"}
    log_info "Installing $package@$version"
}
```

### Functions

**Standard signature with documentation:**
```bash
# Description of what function does
# Args:
#   $1 - package name
#   $2 - version (optional, default: latest)
# Returns:
#   0 on success, 1 on failure
install_package() {
    local package=$1
    local version=${2:-"latest"}
    
    # implementation
    
    return 0
}
```

**Guidelines:**
- One function = one responsibility
- Return 0 for success, non-zero for failure
- Use verb_noun pattern: `install_fzf`, `check_requirements`, `apply_theme`
- Keep under 50 lines (split complex logic into helpers)

### Error Handling & Logging

**Use logging system (core/logger.sh):**
```bash
log_info "Starting installation..."      # Info message
log_success "Installation completed"     # Success message
log_warning "Package already installed"  # Warning message
log_error "Installation failed"          # Error message
```

**Check command success:**
```bash
# Good - check if command exists
if ! command -v gum &> /dev/null; then
    log_error "gum not found"
    return 1
fi

# Good - check installation success
if yay_install "fzf"; then
    log_success "fzf installed"
else
    log_error "fzf installation failed"
    return 1
fi
```

**Avoid:**
- Silent failures (always log errors)
- Using `set -e` in sourced libraries

### Gum Integration (Terminal UI)

**Always use gum for user interaction:**

```bash
# Menu selection
choice=$(gum choose \
    --cursor.foreground 81 \
    --selected.foreground 48 \
    "Option 1" \
    "Option 2")

# Multi-select with pre-selection
selected=$(gum choose \
    --no-limit \
    --selected "tool1,tool2" \
    "${available_tools[@]}")

# User input with validation
name=$(gum input --placeholder "Full Name" --prompt "Name: ")
[ -z "$name" ] && return 1

# Styled output box
gum style \
    --border rounded \
    --border-foreground 81 \
    --padding "1 2" \
    "Title" "" "Content"

# Success/Error messages
gum style --foreground 48 "✓ Success message"
gum style --foreground 196 "✗ Error message"
gum style --foreground 214 "⚠ Warning message"
gum style --foreground 81 "→ Info message"
```

**Color palette (Arch Linux brand):**
- 81 = Cyan (primary, borders, info)
- 75 = Blue (secondary, descriptions)
- 69 = Dark blue (tertiary)
- 48 = Green (success)
- 196 = Red (errors)
- 214 = Orange (warnings)

### ZSH Configuration System

**Use `smart_append_to_zsh` for all ZSH modifications:**

```bash
# Add to ~/.init (tool initialization)
smart_append_to_zsh "init" \
    'eval "$(starship init zsh)"' \
    "starship - Shell prompt"

# Add to ~/.aliases (command aliases)
smart_append_to_zsh "aliases" \
    'alias ls="eza --icons"' \
    "eza - Modern ls replacement"

# Add to ~/.shell (environment variables)
smart_append_to_zsh "shell" \
    'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' \
    "Google Chrome - Browser executable"
```

**How it works:**
- Creates modular structure if missing (backs up existing .zshrc)
- Idempotent (checks first line before appending)
- Three modules: `~/.init`, `~/.aliases`, `~/.shell`

### Package Installation Pattern

**Use `yay_install` from install-utils.sh:**

```bash
install_fzf() {
    log_info "Installing fzf..."
    
    # yay_install handles: already installed check, installation, theming
    if ! yay_install "fzf"; then
        return 1
    fi
    
    # Add ZSH configuration
    smart_append_to_zsh "init" 'eval "$(fzf --zsh)"' "fzf"
    
    return 0
}
```

**For special cases:**
```bash
# Flatpak
flatpak install -y flathub com.example.App

# Custom URL download
curl -fsSL "https://example.com/install.sh" | bash

# Mise-managed languages
mise use -g python@latest
```

---

## Common Patterns

### Add Terminal Tool
1. Create `terminal/tool-name.sh`
2. Define `install_tool_name()` function
3. Use `yay_install "package-name"`
4. Add ZSH config with `smart_append_to_zsh`
5. Auto-discovered by `core/terminal.sh`

**Example (terminal/ripgrep.sh):**
```bash
#!/bin/bash

# terminal/ripgrep.sh
# Fast grep alternative

install_ripgrep() {
    log_info "Installing ripgrep..."
    
    if ! yay_install "ripgrep"; then
        return 1
    fi
    
    smart_append_to_zsh "aliases" \
        'alias rg="rg --smart-case"' \
        "ripgrep - Smart case search"
    
    return 0
}
```

### Add Desktop App
Same pattern, but in `desktop/` directory.

### Add Programming Language (mise)
1. Create `mise_installs/language.sh`
2. Check mise installed
3. Ask user for version (latest/custom)
4. Install: `mise use -g language@version`
5. Add PATH configs via `smart_append_to_zsh`

**Example structure:**
```bash
#!/bin/bash

# mise_installs/python.sh
# Python via mise

install_python() {
    # Check mise
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise not installed"
        return 1
    fi
    
    # Ask version
    local version=$(gum choose "latest (Recommended)" "Custom version")
    
    # Install
    mise use -g python@"$version"
    
    return 0
}
```

---

## Important Rules

**DO:**
- ✅ Use logging: `log_info`, `log_success`, `log_error`
- ✅ Use `smart_append_to_zsh` for all ZSH modifications
- ✅ Use `yay_install` for package installation
- ✅ Quote all variables: `"$variable"`
- ✅ Check command existence: `command -v tool &> /dev/null`
- ✅ Return 0 for success, 1 for failure
- ✅ Keep functions under 50 lines

**DON'T:**
- ❌ Use `echo` for user messages (use `gum style` + logging)
- ❌ Manually edit ~/.zshrc (use `smart_append_to_zsh`)
- ❌ Hardcode paths (use `$INSTALL_DIR`, `$CONFIG_DIR`)
- ❌ Use `set -e` in sourced libraries
- ❌ Skip error checking
- ❌ Break existing functionality

---

**Remember:** This project values simplicity, clarity, and user experience. When in doubt, keep it simple.