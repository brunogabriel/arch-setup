echo -e "Configuring your tools $(gum style --foreground 212 "$settings")."

gum spin -s line --title "Copy zshrc configs..." -- bash -c 'for file in ./configs/zsh/*; do cp -v "$file" ~/."$(basename "$file")"; done'

if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] || [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
  gum spin -s line --title "Copy kitty configs..." -- sleep 1 && cp -r ./configs/kitty ~/.config

  gum spin -s line --title "Copy fastfetch configs..." -- sleep 1 && cp -r ./configs/fastfetch ~/.config

  gum spin -s line --title "Copy warp terminal configs..." -- sleep 1 && cp -r ./configs/warp-terminal ~/.local/share
fi