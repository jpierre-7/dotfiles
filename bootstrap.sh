#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"
PACKAGES=(fastfetch fish lsd niri noctalia vicinae wezterm)

# Install deps
sudo pacman -S --needed stow "${PACKAGES[@]}"

# Stow all packages
cd "$DOTFILES"
for pkg in "${PACKAGES[@]}"; do
    # Remove existing config dirs that would conflict
    if [ -d "$HOME/.config/$pkg" ] && [ ! -L "$HOME/.config/$pkg" ]; then
        echo "Backing up existing ~/.config/$pkg"
        mv "$HOME/.config/$pkg" "$HOME/.config/$pkg.bak"
    fi
    stow "$pkg"
    echo "✓ Stowed $pkg"
done
