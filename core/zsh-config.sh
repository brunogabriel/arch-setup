#!/bin/bash

# core/zsh-config.sh
# ZSH configuration management utilities

# Check if .zshrc follows the modular structure
# Returns: 0 if modular, 1 if not
check_zshrc_structure() {
    local zshrc="$HOME/.zshrc"
    
    # If .zshrc doesn't exist, it's not modular
    [ ! -f "$zshrc" ] && return 1
    
    # Check if it sources the three required modules
    local has_init=$(grep -c "source.*\.init" "$zshrc")
    local has_aliases=$(grep -c "source.*\.aliases" "$zshrc")
    local has_shell=$(grep -c "source.*\.shell" "$zshrc")
    
    if [ "$has_init" -gt 0 ] && [ "$has_aliases" -gt 0 ] && [ "$has_shell" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Convert existing .zshrc to modular structure
# Backs up original and creates modular files
convert_to_modular_structure() {
    local zshrc="$HOME/.zshrc"
    local backup_dir="$HOME/.arch-setup-backups/zsh"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    log_info "Converting .zshrc to modular structure..."
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Backup existing files
    if [ -f "$zshrc" ]; then
        cp "$zshrc" "$backup_dir/zshrc.backup.$timestamp"
        log_info "Backed up existing .zshrc to $backup_dir/zshrc.backup.$timestamp"
    fi
    
    [ -f "$HOME/.init" ] && cp "$HOME/.init" "$backup_dir/init.backup.$timestamp"
    [ -f "$HOME/.aliases" ] && cp "$HOME/.aliases" "$backup_dir/aliases.backup.$timestamp"
    [ -f "$HOME/.shell" ] && cp "$HOME/.shell" "$backup_dir/shell.backup.$timestamp"
    
    # Copy modular structure from configs
    cp "$INSTALL_DIR/configs/zsh/zshrc" "$HOME/.zshrc"
    cp "$INSTALL_DIR/configs/zsh/init" "$HOME/.init"
    cp "$INSTALL_DIR/configs/zsh/aliases" "$HOME/.aliases"
    cp "$INSTALL_DIR/configs/zsh/shell" "$HOME/.shell"
    
    log_success "Converted to modular structure: ~/.zshrc → ~/.init, ~/.aliases, ~/.shell"
    
    return 0
}

# Append content to a zsh module if not already present
# Args:
#   $1 - module name (init, aliases, shell)
#   $2 - content to append
#   $3 - comment/description (optional)
append_to_zsh_module() {
    local module="$1"
    local content="$2"
    local comment="$3"
    local module_file="$HOME/.$module"
    
    # Validate module name
    if [[ ! "$module" =~ ^(init|aliases|shell)$ ]]; then
        log_error "Invalid module name: $module (must be: init, aliases, or shell)"
        return 1
    fi
    
    # Create module file if it doesn't exist
    if [ ! -f "$module_file" ]; then
        log_warning "Module file $module_file does not exist, creating..."
        touch "$module_file"
    fi
    
    # Check if content already exists (exact match)
    if grep -qF "$content" "$module_file"; then
        log_info "Content already exists in ~/.$module, skipping"
        return 0
    fi
    
    # Append content
    echo "" >> "$module_file"
    [ -n "$comment" ] && echo "# $comment" >> "$module_file"
    echo "$content" >> "$module_file"
    
    log_success "Appended to ~/.$module"
    return 0
}

# Setup zsh with modular structure
# Creates or converts to modular structure
setup_zsh_config() {
    log_info "Setting up ZSH configuration..."
    
    # Check if already modular
    if check_zshrc_structure; then
        log_info "ZSH already using modular structure"
        return 0
    fi
    
    # Convert to modular structure
    if ! convert_to_modular_structure; then
        log_error "Failed to convert ZSH to modular structure"
        return 1
    fi
    
    return 0
}

# Install zsh plugins
install_zsh_plugins() {
    log_info "Installing ZSH plugins..."
    
    local plugins=(
        "zsh-autosuggestions"
        "zsh-history-substring-search"
        "zsh-syntax-highlighting"
    )
    
    if ! yay_install_multiple "${plugins[@]}"; then
        log_error "Failed to install ZSH plugins"
        return 1
    fi
    
    log_success "ZSH plugins installed"
    return 0
}
