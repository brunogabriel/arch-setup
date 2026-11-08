#!/bin/bash

# terminal/fzf.sh
# Fuzzy finder

install_fzf() {
    log_info "Installing fzf..."
    
    if ! pacman_install "fzf"; then
        return 1
    fi

    # Install the Tokyo Night Moon theme without overwriting other fzf settings.
    local config_dir="$HOME/.config/fzf"
    mkdir -p "$config_dir"
    if ! cp "$INSTALL_DIR/configs/fzf/tokyonight_moon.sh" "$config_dir/tokyonight_moon.sh"; then
        log_error "Failed to install the Tokyo Night Moon fzf theme"
        return 1
    fi
    
    # Add fzf activation to zsh
    smart_append_to_zsh "init" \
        'if command -v fzf &> /dev/null; then
  [ -r /usr/share/bash-completion/completions/fzf ] && . /usr/share/bash-completion/completions/fzf
  [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  [ -r "$HOME/.config/fzf/tokyonight_moon.sh" ] && . "$HOME/.config/fzf/tokyonight_moon.sh"
fi' \
        "fzf - Fuzzy finder"
    
    # Add fzf alias with bat preview (requires bat)
    smart_append_to_zsh "aliases" \
        'alias ff="fzf --preview '\''bat --style=numbers --color=always {}'\''"' \
        "fzf - Fuzzy finder with bat preview"
    
    return 0
}
