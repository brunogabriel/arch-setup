#!/bin/bash

# terminal/fzf.sh
# Fuzzy finder

install_fzf() {
    log_info "Installing fzf..."
    
    if ! yay_install "fzf"; then
        return 1
    fi
    
    # Add fzf activation to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "init" \
            'if command -v fzf &> /dev/null; then
  [ -r /usr/share/bash-completion/completions/fzf ] && . /usr/share/bash-completion/completions/fzf
  [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
fi' \
            "fzf - Fuzzy finder"
        
        # Add fzf alias with bat preview (requires bat)
        append_to_zsh_module "aliases" \
            'alias ff="fzf --preview '\''bat --style=numbers --color=always {}'\''"' \
            "fzf - Fuzzy finder with bat preview"
    fi
    
    return 0
}
