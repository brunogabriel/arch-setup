echo "Installing desktop applications..."

# desktop apps
for desktop in ./install/desktop/*.sh; do source $desktop; done

echo "Finished installing all desktop applications"