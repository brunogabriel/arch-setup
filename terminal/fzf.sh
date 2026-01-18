#!/bin/bash

# terminal/fzf.sh
# Fuzzy finder

install_fzf() {
    log_info "Installing fzf..."
    
    if ! yay_install "fzf"; then
        return 1
    fi
    
    # Add fzf activation to zsh
    smart_append_to_zsh "init" \
        'if command -v fzf &> /dev/null; then
  [ -r /usr/share/bash-completion/completions/fzf ] && . /usr/share/bash-completion/completions/fzf
  [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
fi' \
        "fzf - Fuzzy finder"
    
    # Add fzf alias with bat preview (requires bat)
    smart_append_to_zsh "aliases" \
        'alias ff="fzf --preview '\''bat --style=numbers --color=always {}'\''"' \
        "fzf - Fuzzy finder with bat preview"
    
    return 0
}
