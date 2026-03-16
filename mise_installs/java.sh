#!/bin/bash

# mise_installs/java.sh
# Java installation via mise (Eclipse Temurin recommended)

readonly JAVA_DEFAULT_VERSION="temurin-25.0.2+10.0.LTS"

install_java() {
    log_info "Installing Java via mise..."

    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install Java"
        return 1
    fi

    # Ask user for version
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Java Installation" \
        "" \
        "$(gum style --foreground 75 "Choose version to install:")" \
        "$(gum style --foreground 69 "Temurin is the recommended OpenJDK distribution (open-source, LTS)")"

    echo ""

    local version_choice=$(gum choose \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        "$JAVA_DEFAULT_VERSION (Recommended)" \
        "Custom version")

    local version=""

    case "$version_choice" in
        "$JAVA_DEFAULT_VERSION (Recommended)")
            version="$JAVA_DEFAULT_VERSION"
            ;;
        "Custom version")
            version=$(gum input \
                --placeholder "e.g., temurin-21.0.5+11.0.LTS, graalvm-21, corretto-21" \
                --prompt "Version: ")

            if [ -z "$version" ]; then
                gum style --foreground 196 "✗ No version provided"
                log_error "No Java version provided"
                return 1
            fi
            ;;
        *)
            gum style --foreground 196 "✗ Invalid choice"
            return 1
            ;;
    esac

    echo ""
    gum style --foreground 81 "→ Installing Java@$version via mise..."
    log_info "Installing Java@$version via mise..."

    # Install Java via mise
    if mise use -g java@"$version" 2>&1 | tee -a "$LOG_FILE"; then
        echo ""
        gum style --foreground 48 "✓ Java@$version installed successfully"
        log_success "Java@$version installed via mise"

        # Add JAVA_HOME to ~/.shell
        smart_append_to_zsh "shell" \
            'export JAVA_HOME="$(mise where java 2>/dev/null)"' \
            "Java - JAVA_HOME"

        # Show installed version
        echo ""
        if command -v java &> /dev/null; then
            local java_version=$(java -version 2>&1 | head -n1)
            gum style --foreground 75 "Installed: $java_version"
        fi

        return 0
    else
        echo ""
        gum style --foreground 196 "✗ Failed to install Java@$version"
        log_error "Failed to install Java@$version"
        return 1
    fi
}
