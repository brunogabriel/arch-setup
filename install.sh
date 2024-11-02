source ./ascii.sh

source ./install/terminal/required/app-gum.sh

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Hello, there! Welcome to $(gum style --foreground 212 'Arch Hisoka')."

GITHUB_NAME=$(gum input --placeholder "What's your fullname?")
GITHUB_EMAIL=$(gum input --placeholder "What's your email?")
NAME=$(echo "$GITHUB_NAME" | awk '{print $1}')

sleep 1; clear

gum spin --spinner monkey --title "Well, it's time do configure your Arch $(gum style --foreground 212 "$NAME")..." -- sleep 2

# installs
source ./install/terminal.sh
source ./install/desktop.sh

# configs
source ./configs/configs.sh

# git setup
git config --global user.name "$GITHUB_NAME"
git config --global user.email "$GITHUB_EMAIL"

echo -e "Your setup is finished, $(gum style --foreground 212 "$NAME")"


