#!/bin/bash

# terminal/fonts.sh
# Install Nerd Fonts collection

install_fonts() {
    pacman_install \
        "ttf-cascadia-mono-nerd" \
        "ttf-firacode-nerd" \
        "ttf-hack" \
        "ttf-meslo-nerd" \
        "ttf-jetbrains-mono"

    yay_install "ttf-ia-writer"
}
