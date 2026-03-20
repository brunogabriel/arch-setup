#!/bin/bash

# mise_installs/dotnet.sh
# .NET installation via mise

install_dotnet() {
    log_info "Installing .NET via mise..."

    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install .NET"
        return 1
    fi

    # Ask user for version
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        ".NET Installation" \
        "" \
        "$(gum style --foreground 75 "Choose version to install:")" \
        "$(gum style --foreground 69 "latest installs the most recent stable .NET SDK")"

    echo ""

    local version_choice=$(gum choose \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        "latest (Recommended)" \
        "Custom version")

    local version=""

    case "$version_choice" in
        "latest (Recommended)")
            version="latest"
            ;;
        "Custom version")
            version=$(gum input \
                --placeholder "e.g., 8.0, 9.0" \
                --prompt "Version: ")

            if [ -z "$version" ]; then
                gum style --foreground 196 "✗ No version provided"
                log_error "No .NET version provided"
                return 1
            fi
            ;;
        *)
            gum style --foreground 196 "✗ Invalid choice"
            return 1
            ;;
    esac

    echo ""
    gum style --foreground 81 "→ Installing .NET@$version via mise..."
    log_info "Installing .NET@$version via mise..."

    # Install .NET via mise
    if mise use -g dotnet@"$version" 2>&1 | tee -a "$LOG_FILE"; then
        echo ""
        gum style --foreground 48 "✓ .NET@$version installed successfully"
        log_success ".NET@$version installed via mise"

        # Add DOTNET_ROOT to ~/.shell
        smart_append_to_zsh "shell" \
            'export DOTNET_ROOT="$(mise where dotnet 2>/dev/null)"' \
            ".NET - DOTNET_ROOT"

        # Show installed version
        echo ""
        if command -v dotnet &> /dev/null; then
            local dotnet_version=$(dotnet --version 2>&1)
            gum style --foreground 75 "Installed: .NET $dotnet_version"
        fi

        return 0
    else
        echo ""
        gum style --foreground 196 "✗ Failed to install .NET@$version"
        log_error "Failed to install .NET@$version"
        return 1
    fi
}
