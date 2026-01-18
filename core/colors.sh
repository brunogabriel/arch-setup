#!/bin/bash

# shared/colors.sh
# Color definitions for arch-setup CLI
# Based on Arch Linux brand colors (cyan/blue palette)

# Reset
readonly COLOR_RESET='\033[0m'

# Arch Linux brand colors (cyan/blue gradient)
readonly COLOR_ARCH_CYAN='\033[38;5;81m'        # Main Arch cyan
readonly COLOR_ARCH_LIGHT_BLUE='\033[38;5;75m'  # Light blue
readonly COLOR_ARCH_SKY_BLUE='\033[38;5;69m'    # Sky blue
readonly COLOR_ARCH_DODGER_BLUE='\033[38;5;63m' # Dodger blue
readonly COLOR_ARCH_DEEP_BLUE='\033[38;5;57m'   # Deep sky blue
readonly COLOR_ARCH_CORN_BLUE='\033[38;5;51m'   # Cornflower blue
readonly COLOR_ARCH_ROYAL_BLUE='\033[38;5;45m'  # Royal blue

# Standard colors for UI
readonly COLOR_PRIMARY=$COLOR_ARCH_CYAN         # Primary brand color
readonly COLOR_SECONDARY=$COLOR_ARCH_SKY_BLUE   # Secondary color

# Semantic colors
readonly COLOR_SUCCESS='\033[0;32m'             # Green
readonly COLOR_ERROR='\033[0;31m'               # Red
readonly COLOR_WARNING='\033[0;33m'             # Yellow
readonly COLOR_INFO='\033[0;36m'                # Cyan
readonly COLOR_MUTED='\033[0;37m'               # Gray/White

# Text styles
readonly STYLE_BOLD='\033[1m'
readonly STYLE_DIM='\033[2m'
readonly STYLE_UNDERLINE='\033[4m'

# Arch Linux color palette (array for gradients)
readonly ARCH_COLORS=(
    '\033[38;5;81m'  # Cyan
    '\033[38;5;75m'  # Light Blue
    '\033[38;5;69m'  # Sky Blue
    '\033[38;5;63m'  # Dodger Blue
    '\033[38;5;57m'  # Deep Sky Blue
    '\033[38;5;51m'  # Cornflower Blue
    '\033[38;5;45m'  # Royal Blue
)

# Helper function to print colored text
color_print() {
    local color=$1
    shift
    echo -e "${color}$*${COLOR_RESET}"
}

# Export all color variables
export COLOR_RESET
export COLOR_ARCH_CYAN COLOR_ARCH_LIGHT_BLUE COLOR_ARCH_SKY_BLUE
export COLOR_ARCH_DODGER_BLUE COLOR_ARCH_DEEP_BLUE COLOR_ARCH_CORN_BLUE COLOR_ARCH_ROYAL_BLUE
export COLOR_PRIMARY COLOR_SECONDARY
export COLOR_SUCCESS COLOR_ERROR COLOR_WARNING COLOR_INFO COLOR_MUTED
export STYLE_BOLD STYLE_DIM STYLE_UNDERLINE
export ARCH_COLORS
