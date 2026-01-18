#!/bin/bash

# terminal/docker.sh
# Docker container platform

install_docker() {
    log_info "Starting Docker installation..."
    
    # Install docker and docker-compose
    if ! yay_install_multiple "docker" "docker-compose"; then
        return 1
    fi
    
    # Add user to docker group
    gum style --foreground 81 "→ Adding user to docker group..."
    if sudo usermod -aG docker "${USER}"; then
        log_success "User added to docker group"
    else
        log_error "Failed to add user to docker group"
        return 1
    fi
    
    # Create docker directory
    sudo mkdir -p /etc/docker
    
    # Restart docker service
    gum style --foreground 81 "→ Starting docker service..."
    if sudo systemctl restart docker.service; then
        log_success "Docker service started"
    else
        log_warning "Failed to restart docker service"
    fi
    
    # Enable docker service
    if sudo systemctl enable docker.service; then
        log_success "Docker service enabled"
    else
        log_warning "Failed to enable docker service"
    fi
    
    # Activate group membership
    gum style --foreground 214 "Note: You may need to log out and back in for docker group to take effect"
    
    return 0
}
