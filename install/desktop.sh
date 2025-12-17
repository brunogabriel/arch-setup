gum style --foreground 212 "Installing desktop applications..."

# desktop apps
for desktop in ./install/desktop/*.sh; do
    app_name=$(basename "$desktop" .sh)
    
    if source "$desktop" 2>&1; then
        gum style --foreground 46 "✓ $app_name installed successfully"
    else
        gum style --foreground 196 "✗ Error installing $app_name"
    fi
done

gum style --foreground 212 "Desktop applications installation completed."