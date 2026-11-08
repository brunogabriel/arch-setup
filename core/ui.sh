#!/bin/bash

# Shared terminal UI. ANSI colors 0–15 follow the terminal's configured palette;
# symbols and text, rather than color alone, communicate selection and status.
UI_ACCENT=6
UI_SECONDARY=4
UI_SUCCESS=2
UI_ERROR=1
UI_WARNING=3

ui_header() {
    local title=$1
    local subtitle=${2:-}
    gum style --border rounded --border-foreground "$UI_ACCENT" --padding "1 2" \
        "$(gum style --bold --foreground "$UI_ACCENT" "$title")" "$subtitle"
}

ui_multiselect_toggle_key() {
    local major
    major=$(gum --version 2>/dev/null | sed -nE 's/.*version ([0-9]+).*/\1/p')
    if [[ "$major" =~ ^[0-9]+$ ]] && [ "$major" -ge 2 ]; then
        printf 'x'
    else
        printf 'Space'
    fi
}

# Args: prompt, select-all (true/false), then options.
ui_multiselect() {
    local prompt=$1
    local select_all=$2
    shift 2
    local key
    key=$(ui_multiselect_toggle_key)
    local options=(
        --no-limit --height 15 --padding "0 1"
        --cursor '› ' --selected-prefix '[x] ' --unselected-prefix '[ ] '
        --cursor.foreground "$UI_ACCENT" --selected.foreground "$UI_SUCCESS"
        --header.foreground "$UI_SECONDARY"
        --header "$prompt · $key: toggle · Enter: confirm · Esc: back"
    )
    if [ "$select_all" = true ]; then
        options+=(--selected '*')
    fi
    gum choose "${options[@]}" "$@"
}
