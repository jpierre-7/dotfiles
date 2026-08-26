#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/dotfiles/noctalia/.config/noctalia"
STATE_FILE="$HOME/.local/state/noctalia/settings.toml"

echo "Exporting Noctalia GUI settings..."
noctalia config export > "$DOTFILES_DIR/noctalia-config.toml"

echo "Clearing GUI state overrides..."
if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    echo "State file removed."
else
    echo "No state file found to remove."
fi

echo "Done! Your dotfiles are ready to be committed."