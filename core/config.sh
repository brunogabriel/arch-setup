# arch-setup configuration file
# This file contains global settings for the arch-setup CLI

# Application metadata
APP_NAME="arch-setup"
APP_VERSION="1.0.0"
APP_AUTHOR="Bruno"
APP_DESCRIPTION="Interactive CLI for Arch Linux setup"

# Directories
CONFIG_DIR="$HOME/.config/arch-setup"
BACKUP_DIR="$HOME/.arch-setup-backups"
LOG_FILE="$HOME/.arch-setup.log"

# Requirements
REQUIRED_PACKAGES=(
    "gum"
)

# flags
ENABLE_BACKUP=true
ENABLE_LOGGING=true
AUTO_INSTALL_REQUIREMENTS=true
