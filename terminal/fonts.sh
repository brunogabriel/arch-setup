#!/bin/bash

# terminal/fonts.sh
# Install Nerd Fonts collection

install_fonts() {
    yay_install_multiple \
        "ttf-cascadia-mono-nerd" \
        "ttf-ia-writer" \
        "ttf-firacode-nerd" \
        "ttf-hack" \
        "ttf-meslo-nerd" \
        "ttf-jetbrains-mono"
}
