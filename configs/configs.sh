echo -e "Configuring your tools $(gum style --foreground 212 "$settings")."

gum spin -s line --title "Copy zshrc..." -- sleep 1 && cp ./configs/zshrc ~/.zshrc

gum spin -s line --title "Copy kitty configs..." -- sleep 1 && cp -r ./configs/kitty ~/.config

gum spin -s line --title "Copy fastfetch configs..." -- sleep 1 && cp -r ./fastfetch ~/.config
