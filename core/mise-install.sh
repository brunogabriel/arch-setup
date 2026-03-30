#!/bin/bash

# core/mise-install.sh
# Programming languages installation orchestrator via mise

# Generic language installer via mise
#
# Usage:
#   mise_install_language \
#     --name        "Display Name"          (required) e.g. "Flutter"
#     --package     "mise-package"          (required) e.g. "flutter"
#     --default     "latest"               (optional, default: "latest")
#     --placeholder "e.g., 3.16.0, stable" (optional)
#     --description "Extra info line"      (optional, shown in header box)
#     --post-install "callback_function"   (optional, called after success)
#     --version-cmd "flutter --version"    (optional, shown after install)
#
# Returns: 0 on success, 1 on failure
mise_install_language() {
    local name="" package="" default_version="latest"
    local placeholder="" description="" post_install_cb="" version_cmd=""

    # Parse named arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --name)        name="$2";            shift 2 ;;
            --package)     package="$2";         shift 2 ;;
            --default)     default_version="$2"; shift 2 ;;
            --placeholder) placeholder="$2";     shift 2 ;;
            --description) description="$2";     shift 2 ;;
            --post-install) post_install_cb="$2"; shift 2 ;;
            --version-cmd) version_cmd="$2";     shift 2 ;;
            *) shift ;;
        esac
    done

    log_info "Installing $name via mise..."

    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install $name"
        return 1
    fi

    # Build header box lines
    local header_lines=("$name Installation" "" "$(gum style --foreground 75 "Choose version to install:")")
    [ -n "$description" ] && header_lines+=("$(gum style --foreground 69 "$description")")

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "${header_lines[@]}"

    echo ""

    # Determine label for recommended option
    local recommended_label="$default_version (Recommended)"

    local version_choice
    version_choice=$(gum choose \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        "$recommended_label" \
        "Custom version")

    local version=""
    case "$version_choice" in
        "$recommended_label")
            version="$default_version"
            ;;
        "Custom version")
            local ph="${placeholder:-"e.g., version number"}"
            version=$(gum input \
                --placeholder "$ph" \
                --prompt "Version: ")

            if [ -z "$version" ]; then
                gum style --foreground 196 "✗ No version provided"
                log_error "No $name version provided"
                return 1
            fi
            ;;
        *)
            gum style --foreground 196 "✗ Invalid choice"
            return 1
            ;;
    esac

    echo ""
    gum style --foreground 81 "→ Installing $name@$version via mise..."
    log_info "Installing $name@$version via mise..."

    if mise use -g "${package}@${version}" 2>&1 | tee -a "$LOG_FILE"; then
        echo ""
        gum style --foreground 48 "✓ $name@$version installed successfully"
        log_success "$name@$version installed via mise"

        # Run post-install callback if provided
        if [ -n "$post_install_cb" ] && declare -f "$post_install_cb" > /dev/null; then
            "$post_install_cb"
        fi

        # Show installed version
        if [ -n "$version_cmd" ]; then
            echo ""
            local installed_version
            installed_version=$(eval "$version_cmd" 2>/dev/null | head -n1)
            [ -n "$installed_version" ] && gum style --foreground 75 "Installed: $installed_version"
        fi

        return 0
    else
        echo ""
        gum style --foreground 196 "✗ Failed to install $name@$version"
        log_error "Failed to install $name@$version"
        return 1
    fi
}

# Get list of available languages in mise_installs directory
get_mise_languages() {
    local languages=()
    
    # Find all .sh files in mise_installs directory
    if [ -d "$INSTALL_DIR/mise_installs" ]; then
        for file in "$INSTALL_DIR/mise_installs"/*.sh; do
            if [ -f "$file" ]; then
                # Extract filename without extension
                local lang=$(basename "$file" .sh)
                languages+=("$lang")
            fi
        done
    fi
    
    echo "${languages[@]}"
}

# Install programming language via mise
install_programming_language() {
    log_info "Starting programming language installation menu..."
    
    clear
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Install Programming Languages" \
        "" \
        "$(gum style --foreground 75 "Manage language versions via mise")"
    
    echo ""
    
    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install programming languages"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Get available languages
    local languages=($(get_mise_languages))
    
    if [ ${#languages[@]} -eq 0 ]; then
        gum style --foreground 196 "✗ No languages available"
        log_error "No language installers found in mise_installs/"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Show menu to select language
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Available Languages (${#languages[@]} total)"
    
    echo ""
    
    local choice=$(gum choose \
        --cursor.foreground 81 \
        --header "Select language to install:" \
        --header.foreground 81 \
        "${languages[@]}")
    
    if [ -z "$choice" ]; then
        gum style --foreground 214 "No language selected"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 0
    fi
    
    echo ""
    log_info "Selected language: $choice"
    
    # Source and execute the installer
    local script="$INSTALL_DIR/mise_installs/${choice}.sh"
    
    if [ ! -f "$script" ]; then
        gum style --foreground 196 "✗ Installer not found: $script"
        log_error "Installer script not found: $script"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Convert language name to function name (replace - with _)
    local func_name=$(echo "$choice" | tr '-' '_')
    
    # Source the script and call install function
    if source "$script" && install_${func_name}; then
        log_success "$choice installation completed"
    else
        log_error "$choice installation failed"
    fi
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    return 0
}
