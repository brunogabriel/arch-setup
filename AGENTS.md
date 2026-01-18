# AGENTS.md - Coding Agent Guidelines for arch-setup

## Project Overview

**arch-setup** is an interactive CLI tool for automating Arch Linux/Manjaro system setup. Built with Bash and [gum](https://github.com/charmbracelet/gum) for beautiful terminal UI.

**Architecture:** Clean Architecture (KISS principle) - modular, simple, no over-engineering.

---

## 🏗️ Project Structure

```
arch-setup/
├── arch-setup              # Main entry point (orchestrator)
├── core/                   # Core utilities (shared/reusable)
│   ├── config.sh          # Global configuration & constants
│   ├── colors.sh          # Terminal color definitions (Arch brand colors)
│   ├── requirements.sh    # Dependency checker (gum, etc.)
│   └── user-config.sh     # User configuration management
├── .gitignore
└── README.md
```

---

## 🚀 Running the Application

### Main Command
```bash
./arch-setup                # Run the interactive CLI
```

### Testing Individual Components
```bash
# Test requirements check
bash -c "source core/config.sh && source core/colors.sh && source core/requirements.sh && check_requirements"

# Test user configuration
bash -c "source core/config.sh && source core/colors.sh && source core/user-config.sh && configure_user"

# Verify config file exists
cat ~/.config/arch-setup/user.conf

# Check syntax without running
bash -n arch-setup
bash -n core/*.sh
```

### Linting
```bash
# Install shellcheck
sudo pacman -S shellcheck

# Lint all scripts
shellcheck arch-setup core/*.sh

# Lint specific file
shellcheck core/user-config.sh
```

---

## 📝 Code Style Guidelines

### Bash Script Structure

**Every bash file MUST:**
1. Start with shebang: `#!/bin/bash`
2. Have descriptive header comment
3. Use `set -e` in main scripts (not in sourced libraries)
4. Define functions before using them

**Example:**
```bash
#!/bin/bash

# core/example.sh
# Brief description of what this module does

# Function description
function_name() {
    local param=$1
    # implementation
}
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| **Files** | lowercase-with-dashes.sh | `user-config.sh` |
| **Functions** | snake_case | `check_requirements()` |
| **Variables (local)** | snake_case | `local user_name="Bruno"` |
| **Constants (global)** | UPPER_SNAKE_CASE | `APP_VERSION="1.0.0"` |
| **Readonly** | readonly UPPER_SNAKE_CASE | `readonly COLOR_RESET='\033[0m'` |
| **Arrays** | UPPER_SNAKE_CASE | `REQUIRED_PACKAGES=()` |

### Variables

**Always:**
- Use `local` for function-scoped variables
- Use `readonly` for constants that never change
- Quote variables: `"$variable"` (prevent word splitting)
- Use `${variable}` for clarity in complex strings

**Example:**
```bash
# Global config
readonly APP_NAME="arch-setup"
USER_CONFIG_FILE="$CONFIG_DIR/user.conf"  # Can change

# Function
configure_user() {
    local name=$1
    local email=$2
    echo "User: $name ($email)"
}
```

### Functions

**Function signature:**
```bash
# Description of what function does
# Args:
#   $1 - description of first arg
#   $2 - description of second arg
# Returns:
#   0 on success, 1 on failure
function_name() {
    local arg1=$1
    local arg2=$2
    
    # implementation
    
    return 0
}
```

**Function guidelines:**
- One function = one responsibility
- Return 0 for success, non-zero for failure
- Use meaningful names (verb_noun pattern: `save_user_config`)

### Error Handling

**Check command success:**
```bash
# Good - check exit code
if ! command -v gum &> /dev/null; then
    echo "Error: gum not found"
    return 1
fi

# Good - inline check
sudo pacman -S gum || {
    echo "Failed to install"
    exit 1
}
```

**Avoid:**
- Ignoring errors silently
- Using `set -e` in sourced libraries (breaks error handling)

### Gum Integration

**Always use gum for:**
- User input: `gum input`
- Menus: `gum choose`
- Confirmations: `gum confirm`
- Styled output: `gum style`
- Multi-select: `gum choose --no-limit`

**Colors:** Use Arch Linux brand colors (81, 75, 69 - cyan/blue palette)

**Example:**
```bash
# Menu
choice=$(gum choose \
    --cursor.foreground 81 \
    --header "Select option:" \
    "Option 1" \
    "Option 2")

# Styled box
gum style \
    --border rounded \
    --border-foreground 81 \
    --padding "1 2" \
    "Title" \
    "" \
    "Content here"

# Input with validation
name=$(gum input --placeholder "Full Name" --prompt "Name: ")
if [ -z "$name" ]; then
    gum style --foreground 196 "✗ Name cannot be empty"
    return 1
fi
```

### File Operations

**User config location:** `~/.config/arch-setup/`
**Backup location:** `~/.arch-setup-backups/`
**Log file:** `~/.arch-setup.log`

**Always:**
- Create directories before writing: `mkdir -p "$CONFIG_DIR"`
- Set proper permissions: `chmod 600 "$USER_CONFIG_FILE"`
- Check if file exists: `[ -f "$file" ]`

### Sourcing Modules

**Main script loads core utilities:**
```bash
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$INSTALL_DIR/core/config.sh"      # Always first (defines constants)
source "$INSTALL_DIR/core/colors.sh"
source "$INSTALL_DIR/core/requirements.sh"
source "$INSTALL_DIR/core/user-config.sh"
```

**Order matters:** Load `config.sh` first as it defines constants used by others.

---

## ⚠️ Important Rules

### DO:
- ✅ Keep functions under 50 lines
- ✅ Use descriptive variable names
- ✅ Add comments for complex logic
- ✅ Quote all variables
- ✅ Check command existence before using: `command -v tool`
- ✅ Return meaningful exit codes
- ✅ Use `gum` for all user interaction
- ✅ Follow Arch Linux cyan/blue color scheme

### DON'T:
- ❌ Use `echo` for user-facing messages (use `gum style` instead)
- ❌ Hardcode paths (use variables from config.sh)
- ❌ Hardcode version numbers (use `$APP_VERSION`)
- ❌ Ask user for confirmation on simple actions (just do it)
- ❌ Over-engineer solutions (KISS principle)
- ❌ Add features not explicitly requested
- ❌ Create new files without asking first
- ❌ Break existing functionality

---

## 🎯 Development Workflow

1. **Understand the request** - Ask clarifying questions if needed
2. **Plan the changes** - Think through the implementation
3. **Make minimal changes** - Only what's needed, nothing more
4. **Test the change** - Run `./arch-setup` and test the feature
5. **Lint the code** - Run `shellcheck` on modified files
6. **Verify integration** - Ensure it works with existing code

---

## 📦 Dependencies

**Required:**
- `gum` - Installed automatically by `check_requirements()`
- `bash` 4.0+
- Arch Linux or Manjaro

**Development:**
- `shellcheck` - For linting

---

## 🔍 Common Tasks

### Add New Core Module
1. Create `core/new-module.sh`
2. Add shebang and header
3. Define functions
4. Source in `arch-setup`: `source "$INSTALL_DIR/core/new-module.sh"`

### Add Menu Option
1. Add entry to `gum choose` in `main_menu()`
2. Add case in switch statement
3. Call appropriate function

### Add Configuration Field
1. Edit `core/user-config.sh`
2. Update `save_user_config()` to include new field
3. Update `display_user_config()` to show new field

---

**Remember:** This project values simplicity, clarity, and user experience. When in doubt, keep it simple.
