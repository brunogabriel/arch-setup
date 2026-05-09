#!/bin/bash

# menu_actions/view-status.sh
# View Installation Status - shows which tools and apps are installed

view_installation_status() {
    log_info "Checking installation status..."
    
    clear
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Installation Status" \
        "" \
        "$(gum style --foreground 75 "Checking installed tools and applications...")"
    
    echo ""
    
    # Get all tools and apps
    local terminal_tools=($(get_terminal_tools))
    local desktop_apps=($(get_desktop_apps))
    
    local installed_count=0
    local not_installed_count=0
    
    # Check Terminal Tools
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Terminal Tools (${#terminal_tools[@]} total)"
    echo ""
    
    for tool in "${terminal_tools[@]}"; do
        local check_cmd=""
        local display_name="$tool"
        local is_installed=false
        
        # Special cases for command names and checks
        case "$tool" in
            "github-copilot-cli") check_cmd="copilot" ;;
            "github-cli") check_cmd="gh" ;;
            "opencode") check_cmd="opencode" ;;
            "ripgrep") check_cmd="rg" ;;
            "fonts") 
                # Check if any nerd font is installed
                if fc-list | grep -qi "nerd"; then
                    gum style --foreground 48 "  ✓ $display_name (nerd fonts installed)"
                    ((installed_count++))
                    is_installed=true
                else
                    gum style --foreground 245 "  ○ $display_name (not installed)"
                    ((not_installed_count++))
                    is_installed=true
                fi
                ;;
            *) check_cmd="$tool" ;;
        esac
        
        # Skip if already processed
        [ "$is_installed" = true ] && continue
        
        if command -v "$check_cmd" &> /dev/null; then
            local version=$(command $check_cmd --version 2>/dev/null | head -n1 | cut -d' ' -f1-3 || echo "installed")
            gum style --foreground 48 "  ✓ $display_name ($version)"
            ((installed_count++))
        else
            gum style --foreground 245 "  ○ $display_name (not installed)"
            ((not_installed_count++))
        fi
    done
    
    echo ""
    
    # Check Desktop Applications
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Desktop Applications (${#desktop_apps[@]} total)"
    echo ""
    
    for app in "${desktop_apps[@]}"; do
        local check_cmd=""
        local display_name="$app"
        local is_installed=false
        
        # Special cases for command/package names
        case "$app" in
            "chrome") check_cmd="google-chrome-stable" ;;
            "vscode") check_cmd="code" ;;
            "brave") check_cmd="brave" ;;
            "cursor") check_cmd="cursor" ;;
            "jetbrains-toolbox") check_cmd="jetbrains-toolbox" ;;
            "bitwarden") check_cmd="bitwarden-desktop" ;;
            "heroic-games-launcher") check_cmd="heroic" ;;
            "xournal-app") check_cmd="xournalpp" ;;
            "lsfg-vk") check_cmd="lsfg-vk-ui" ;;
            "pinta") 
                # Check via flatpak (com.github.PintaProject.Pinta)
                if flatpak list --app 2>/dev/null | grep -qi "PintaProject.Pinta"; then
                    gum style --foreground 48 "  ✓ $display_name (flatpak)"
                    ((installed_count++))
                else
                    gum style --foreground 245 "  ○ $display_name (not installed)"
                    ((not_installed_count++))
                fi
                is_installed=true
                ;;
            "podman-desktop") 
                # Check via flatpak (io.podman_desktop.PodmanDesktop)
                if flatpak list --app 2>/dev/null | grep -qi "podman_desktop.PodmanDesktop"; then
                    gum style --foreground 48 "  ✓ $display_name (flatpak)"
                    ((installed_count++))
                elif command -v podman-desktop &> /dev/null; then
                    gum style --foreground 48 "  ✓ $display_name (installed)"
                    ((installed_count++))
                else
                    gum style --foreground 245 "  ○ $display_name (not installed)"
                    ((not_installed_count++))
                fi
                is_installed=true
                ;;
            "tk") 
                # Check via flatpak or command
                if flatpak list --app 2>/dev/null | grep -qi "tk"; then
                    gum style --foreground 48 "  ✓ $display_name (flatpak)"
                    ((installed_count++))
                elif command -v tk &> /dev/null; then
                    gum style --foreground 48 "  ✓ $display_name (installed)"
                    ((installed_count++))
                else
                    gum style --foreground 245 "  ○ $display_name (not installed)"
                    ((not_installed_count++))
                fi
                is_installed=true
                ;;
            *) check_cmd="$app" ;;
        esac
        
        # Skip if already processed
        [ "$is_installed" = true ] && continue
        
        if command -v "$check_cmd" &> /dev/null; then
            gum style --foreground 48 "  ✓ $display_name (installed)"
            ((installed_count++))
        else
            gum style --foreground 245 "  ○ $display_name (not installed)"
            ((not_installed_count++))
        fi
    done
    
    echo ""
    
    # Summary
    local total=$((installed_count + not_installed_count))
    local percentage=0
    if [ $total -gt 0 ]; then
        percentage=$((installed_count * 100 / total))
    fi
    
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        "Summary" \
        "" \
        "$(gum style --foreground 48 "✓ Installed: $installed_count")" \
        "$(gum style --foreground 245 "○ Not Installed: $not_installed_count")" \
        "" \
        "$(gum style --foreground 81 "Progress: $percentage%")"
    
    log_info "Installation status checked: $installed_count installed, $not_installed_count not installed"
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    return 0
}
