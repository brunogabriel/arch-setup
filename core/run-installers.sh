#!/bin/bash

# core/run-installers.sh
# Shared installer execution engine — scan directories, run scripts, track results

# Scan a subdirectory for installer scripts
# Args:
#   $1 - subdirectory name (terminal, desktop, extras)
# Returns: newline-separated list of tool names
scan_installers() {
    local subdir=$1
    local items=()

    if [ -d "$INSTALL_DIR/$subdir" ]; then
        for script in "$INSTALL_DIR/$subdir"/*.sh; do
            if [ -f "$script" ]; then
                items+=("$(basename "$script" .sh)")
            fi
        done
    fi

    printf '%s\n' "${items[@]}"
}

# Execute installer loop — source each script, call install_<name>, track results
# Args:
#   $1 - newline-separated item list (from scan_installers or custom-built)
#   $2 - subdirectory to source scripts from (terminal, desktop)
#   $3 - show progress counter [true/false] (default: false)
# Sets global vars: SUCCESS_COUNT, FAIL_COUNT
run_installers() {
    local items=$1
    local subdir=$2
    local show_progress=${3:-false}
    local total
    total=$(echo "$items" | grep -c .)
    local current=0

    SUCCESS_COUNT=0
    FAIL_COUNT=0

    while IFS= read -r item; do
        [ -z "$item" ] && continue
        ((current++))

        # Parse optional prefix: "[T] tool-name" or "[D] app-name"
        local has_prefix=false
        local name=""
        local script=""

        if [[ "${item:0:1}" == "[" ]]; then
            has_prefix=true
            local subdir_hint="${item:1:1}"
            name="${item:4}"
        else
            name="$item"
        fi

        # Resolve script path
        if [ "$has_prefix" = true ]; then
            if [ "$subdir_hint" = "T" ]; then
                script="$INSTALL_DIR/terminal/${name}.sh"
            else
                script="$INSTALL_DIR/desktop/${name}.sh"
            fi
        elif [ -n "$subdir" ]; then
            script="$INSTALL_DIR/$subdir/${name}.sh"
        fi

        if [ -f "$script" ]; then
            local func_name
            func_name=$(echo "$name" | tr '-' '_')

            if [ "$show_progress" = true ]; then
                log_info "[$current/$total] Installing $name..."
                gum style --foreground 81 "[$current/$total] → Installing $name..."
            else
                log_info "Installing $name..."
                gum style --foreground 81 "→ Installing $name..."
            fi

            if source "$script" && "install_${func_name}"; then
                gum style --foreground 48 "✓ $name installed successfully"
                log_success "$name installed successfully"
                ((SUCCESS_COUNT++))
            else
                gum style --foreground 196 "✗ Failed to install $name"
                log_error "Failed to install $name"
                ((FAIL_COUNT++))
            fi

            echo ""
        else
            gum style --foreground 196 "✗ Script not found: $script"
            log_error "Script not found: $script"
            ((FAIL_COUNT++))
        fi
    done <<< "$items"
}

# Show installation summary box
# Args:
#   $1 - title
#   $2 - border style (rounded or double, default: rounded)
#   $3 - extra lines (optional, newline-separated gum styled text)
show_install_summary() {
    local title=$1
    local border_style=${2:-rounded}
    local extra_lines=$3

    local border_flag="--border $border_style"
    local bold_flag=""
    [ "$border_style" = "double" ] && bold_flag="--bold"

    gum style \
        $border_flag \
        --border-foreground 81 \
        --padding "1 2" \
        $bold_flag \
        "$title" \
        "" \
        "$(gum style --foreground 48 "✓ Success: $SUCCESS_COUNT")" \
        "$(gum style --foreground 196 "✗ Failed: $FAIL_COUNT")" \
        ${extra_lines:+$(printf '\n%s' "$extra_lines")}

    log_info "$title: $SUCCESS_COUNT success, $FAIL_COUNT failed"
}
