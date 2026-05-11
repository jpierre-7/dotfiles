#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"
PACMAN_PACKAGES=(fastfetch fish lsd niri stow)
AUR_PACKAGES=(noctalia-shell vicinae)

# Install yay if not present
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd - && rm -rf /tmp/yay
fi

sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"
yay -S --needed "${AUR_PACKAGES[@]}"

# Stow all packages
cd "$DOTFILES"
for pkg in fastfetch fish lsd niri noctalia vicinae wezterm; do
  if [ -d "$HOME/.config/$pkg" ] && [ ! -L "$HOME/.config/$pkg" ]; then
    echo "Backing up existing ~/.config/$pkg"
    mv "$HOME/.config/$pkg" "$HOME/.config/$pkg.bak"
  fi
  stow "$pkg"
  echo "✓ Stowed $pkg"
done
