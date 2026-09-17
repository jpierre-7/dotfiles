#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo from this script's own location so the repo can live anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACMAN_PACKAGES=(
  # Desktop session
  niri xwayland-satellite noctalia wlsunset
  # Terminal and shell
  wezterm fish starship lsd fastfetch onefetch lazygit
  # Neovim and the tooling LazyVim's extras expect
  neovim ripgrep fd unzip wl-clipboard nodejs npm rustup
  # Molten (jupyter in neovim): python for the plugin venv, imagemagick for image.nvim
  python imagemagick
  # System
  git base-devel stow keyd tailscale github-cli
  # Apps and fonts
  vivaldi noto-fonts noto-fonts-emoji
)

AUR_PACKAGES=(vesktop vicinae-bin maplemono-ttf maplemono-nf-unhinted maplemono-nf-cn-unhinted)

# Installed with cargo because they are not packaged in the repos or the AUR
CARGO_PACKAGES=(pyroclear)

# Python deps for neovim remote plugins (molten-nvim), kept in their own venv
# that nvim points at via vim.g.python3_host_prog. pynvim and jupyter_client
# are required; ipykernel provides a default python3 kernel; the rest add
# optional output support (notebook import/export, image popups, svg, clipboard).
NVIM_VENV="$HOME/.virtualenvs/neovim"
NVIM_PIP_PACKAGES=(pynvim jupyter_client ipykernel nbformat pillow cairosvg pyperclip)

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

# Prompt for the sudo password once, up front
sudo -v

log "Updating the system"
sudo pacman -Syu

# Install yay
if ! command -v yay &>/dev/null; then
  log "Installing yay"
  sudo pacman -S --needed --noconfirm git base-devel
  rm -rf /tmp/yay
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
fi

log "Installing packages from the official repos"
sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"

log "Installing packages from the AUR"
yay -S --needed "${AUR_PACKAGES[@]}"

log "Installing cargo packages"
rustup default stable
rustup component add rust-analyzer
for pkg in "${CARGO_PACKAGES[@]}"; do
  cargo install --locked "$pkg"
done

log "Setting up the neovim python venv at $NVIM_VENV"
if [ ! -x "$NVIM_VENV/bin/python3" ]; then
  mkdir -p "$(dirname "$NVIM_VENV")"
  python -m venv "$NVIM_VENV"
fi
"$NVIM_VENV/bin/pip" install --upgrade "${NVIM_PIP_PACKAGES[@]}"
# Molten writes kernel connection files here but does not create the directory
mkdir -p "$HOME/.local/share/jupyter/runtime"

log "Stowing configs into $HOME"
cd "$DOTFILES"
if ! stow -t "$HOME" -R */; then
  # Usually a freshly generated default config in the way. Adopt it, then let
  # the user review what changed before committing.
  log "Conflicts found, retrying with --adopt"
  stow -t "$HOME" -R --adopt */
  echo
  echo "WARNING: --adopt replaced repo files with the ones already on this machine."
  echo "Review and discard unwanted changes before committing:"
  echo "    git -C \"$DOTFILES\" diff"
  echo "    git -C \"$DOTFILES\" checkout -- ."
fi
echo "All packages stowed successfully!"

# Bind esc to caps lock
log "Configuring keyd"
sudo tee /etc/keyd/default.conf >/dev/null <<EOF
[ids]
*

[main]
capslock = esc
EOF

log "Enabling services"
sudo systemctl enable --now keyd
sudo systemctl enable --now tailscaled

# Make fish the login shell
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]; then
  log "Setting fish as the login shell"
  chsh -s "$(command -v fish)" "$USER"
fi

cat <<EOF

Bootstrap complete. Remaining manual steps:

  1. Authenticate Tailscale:  sudo tailscale up
  2. Log out and back in for the fish login shell to take effect
  3. Launch nvim once to let lazy.nvim sync plugins, then run
     :UpdateRemotePlugins and restart nvim so Molten is registered

EOF

# End with a reboot prompt
read -rp "Reboot now? [y/N] " ans
case "$ans" in
[yY] | [yY][eE][sS]) reboot ;;
*) echo "Skipping reboot." ;;
esac
