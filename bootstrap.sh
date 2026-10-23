#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo from this script's own location so the repo can live anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Package names from a packages/*.txt list: drop comments, one name per line
read_pkgs() { sed 's/#.*//' "$1" | tr -s ' \t' '\n' | sed '/^$/d'; }

mapfile -t PACMAN_PACKAGES < <(read_pkgs "$DOTFILES/packages/pacman.txt")
mapfile -t AUR_PACKAGES < <(read_pkgs "$DOTFILES/packages/aur.txt")

# Installed with cargo because they are not packaged in the repos or the AUR
CARGO_PACKAGES=(pyroclear)

# Python deps for neovim remote plugins (molten-nvim), kept in their own venv
# that nvim points at via vim.g.python3_host_prog. pynvim and jupyter_client
# are required; ipykernel provides a default python3 kernel; the rest add
# optional output support (notebook import/export, image popups, svg, clipboard).
NVIM_VENV="$HOME/.virtualenvs/neovim"
NVIM_PIP_PACKAGES=(pynvim jupyter_client ipykernel nbformat pillow cairosvg pyperclip)

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }

# Prompt for the sudo password once, up front, then keep the timestamp fresh so
# long AUR and cargo builds don't stop to ask again
sudo -v
while true; do
  sudo -n true
  sleep 60
done 2>/dev/null &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null' EXIT

log "Updating the system"
sudo pacman -Syu --noconfirm

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
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

log "Installing packages from the AUR"
yay -S --needed --noconfirm --answerclean None --answerdiff None --answeredit None "${AUR_PACKAGES[@]}"

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
# Stow links a whole directory when it doesn't exist yet. ~/.claude must be a
# real directory, or Claude Code would write credentials and history into this
# repo; skills/ too, so skill installers and claude.ai sync write beside the
# per-skill links instead of into the repo.
mkdir -p "$HOME/.claude/skills"
# Only directories holding dotfiles are stow packages
STOW_PACKAGES=()
for dir in */; do
  case "$dir" in packages/) continue ;; esac
  STOW_PACKAGES+=("$dir")
done
if ! stow -t "$HOME" -R "${STOW_PACKAGES[@]}"; then
  # Usually a freshly generated default config in the way. Adopt it, then let
  # the user review what changed before committing.
  log "Conflicts found, retrying with --adopt"
  stow -t "$HOME" -R --adopt "${STOW_PACKAGES[@]}"
  echo
  echo "WARNING: --adopt replaced repo files with the ones already on this machine."
  echo "Review and discard unwanted changes before committing:"
  echo "    git -C \"$DOTFILES\" diff"
  echo "    git -C \"$DOTFILES\" checkout -- ."
fi
echo "All packages stowed successfully!"

# niri includes host.kdl for per-machine outputs; without a hosts/ file for this
# machine, niri auto-configures them
HOST="$(uname -n)"
if [ -f "$HOME/.config/niri/hosts/$HOST.kdl" ]; then
  ln -sfn "hosts/$HOST.kdl" "$HOME/.config/niri/host.kdl"
else
  echo "No niri/.config/niri/hosts/$HOST.kdl; outputs will use niri's defaults"
fi

# Noctalia's default wallpaper lives here
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
  log "Cloning wallpapers"
  git clone --depth 1 https://github.com/jpierre-7/Wallpapers.git "$HOME/Pictures/Wallpapers"
fi

# Both install into ~/.local/bin and update themselves, so they live outside
# pacman. Runs after stowing so the herdr integration finds Claude's settings.
log "Installing Claude Code and herdr"
if [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
if [ ! -x "$HOME/.local/bin/herdr" ]; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi
# Writes ~/.claude/hooks/herdr-agent-state.sh, which settings.json's
# SessionStart hook runs
"$HOME/.local/bin/herdr" integration install claude

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
# Enable without --now: starting a greeter here would end this session. Skip if
# archinstall already set up a display manager.
if [ ! -e /etc/systemd/system/display-manager.service ]; then
  sudo systemctl enable cosmic-greeter
fi

# Make fish the login shell
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v fish)" ]; then
  log "Setting fish as the login shell"
  chsh -s "$(command -v fish)" "$USER"
fi

cat <<EOF

Bootstrap complete. Remaining manual steps:

  1. Authenticate Tailscale:  sudo tailscale up
  2. Log in to Claude Code:   claude
  3. Log out and back in for the fish login shell to take effect
  4. Launch nvim once to let lazy.nvim sync plugins, then run
     :UpdateRemotePlugins and restart nvim so Molten is registered

EOF

# End with a reboot prompt
read -rp "Reboot now? [y/N] " ans
case "$ans" in
[yY] | [yY][eE][sS]) reboot ;;
*) echo "Skipping reboot." ;;
esac
