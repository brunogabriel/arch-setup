#!/bin/bash

# core/requirements.sh
# Check and install required dependencies for arch-setup CLI

# Check and install requirements
check_requirements() {
    echo -e "${COLOR_INFO}Checking requirements...${COLOR_RESET}"
    
    # Check if gum is installed
    if ! command -v gum &> /dev/null; then
        echo -e "${COLOR_WARNING}⚠ gum is not installed${COLOR_RESET}"
        echo -e "${COLOR_INFO}Installing gum...${COLOR_RESET}"
        
        if sudo pacman -S --needed --noconfirm gum; then
            echo -e "${COLOR_SUCCESS}✓ gum installed successfully${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}✗ Failed to install gum${COLOR_RESET}"
            echo -e "${COLOR_ERROR}Please install gum manually: sudo pacman -S gum${COLOR_RESET}"
            exit 1
        fi
    else
        echo -e "${COLOR_SUCCESS}✓ gum is installed${COLOR_RESET}"
    fi
    
    echo ""
    sleep 1
}
