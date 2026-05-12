#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
PACMAN_PACKAGES=(discord starship neovim onefetch stow wezterm fish lsd fastfetch)
AUR_PACKAGES=(noctalia-shell vicinae onlyoffice maplemono-ttf maplemono-nf-unhinted maplemono-nf-cn-unhinted)

#Quick update
sudo pacman -Syu

# Install yay if not present
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd - && rm -rf /tmp/yay
fi

# Install all packages
sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"
yay -S --needed "${AUR_PACKAGES[@]}"

# Confirm dotfiles dir exists before stowing
if [ ! -d "$DOTFILES" ]; then
  echo "Dotfiles not found at $DOTFILES, skipping stow"
  exit 1
fi

# Stow all packages
cd "$DOTFILES"
stow */
echo "All packages stowed successfully!"

# End with a reboot prompt
read -rp "Done! Reboot now? [y/N] " ans
[[ "$ans" == "y" ]] && reboot
