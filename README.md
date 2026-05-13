# dotfiles

My personal Arch Linux dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stack

| Tool | Purpose |
|------|---------|
| [Niri](https://github.com/YaLTeR/niri) | Wayland compositor |
| [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) | Shell / bar |
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal emulator |
| [Fish](https://fishshell.com/) | Shell |
| [Neovim](https://neovim.io/) | Editor |
| [Starship](https://starship.rs/) | Prompt |
| [lsd](https://github.com/lsd-rs/lsd) | `ls` replacement |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info |
| [Vicinae](https://docs.vicinae.com) | App launcher |
| [Maple Mono](https://github.com/subframe7536/maple-font) | Font |

## How to Run

### 0. Configure Wifi if Needed

Launch ```iwctl``` wireless control tool

```bash
iwctl
```

Find your wireless device (typically wlan0)

```bash
device list
```

Scan for networks

```bash
station wlan0 scan
```

List the available networks

```bash
station wlan0 get-networks
```

Connect to your network

```bash
station wlan0 connect "YourNetworkName"
```

Exit iwctl

```bash
exit
```

### 1. Install Arch Linux

Boot from an Arch ISO and run the guided installer:

```bash
archinstall
```

Follow the prompts. Recommended options: ext4 or btrfs filesystem, pipewire for audio, and your preferred desktop profile (or none, since niri is installed via bootstrap).

\* Be sure to select git and your browser of choice from additional packages during install.

### 2. Clone This Repo

```bash
git clone https://github.com/jpierre-7/dotfiles.git ~/dotfiles
```

### 3. Run the Bootstrap Script

```bash
cd ~/dotfiles
bash bootstrap.sh
```

The script will:
- Update the system (`pacman -Syu`)
- Install [yay](https://github.com/Jguer/yay) (AUR helper) if not already present
- Install all packages from both the official repos and the AUR
- Stow all config directories into your home folder
- Prompt you to reboot

## Structure

```
dotfiles/
├── fastfetch/     # fastfetch config
├── fish/          # Fish shell config & abbreviations
├── lsd/           # lsd colors & icons
├── niri/          # Niri compositor config (keybinds, window rules, animations)
├── noctalia/      # Noctalia shell theme & settings
├── starship/      # Starship prompt
├── vicinae/       # Vicinae launcher settings
└── wezterm/       # WezTerm config, keybinds, and custom color theme
```

Each directory is a Stow package. Running `stow */` from the repo root symlinks everything into `$HOME`.

## Notes

- Caps Lock is remapped to Escape via `xkb` in the Niri config.
- The Starship prompt uses the Catppuccin Frappé palette.
- The Noctalia color scheme is set to Gruvbox.
- WezTerm uses the Catppuccin Frappé color scheme with a custom `dank-theme` available as an alternative.
- Fish runs `onefetch` automatically when entering a git repo, and `fastfetch` on shell start.

## AI Disclosure

AI was used as a learning tool not a replacement for critical thinking. Even during troubleshooting each line and choice was reviewed, understood, and questioned before implementation. AI was used to generate a boilerplate for this README (ofc I was sure to review though ;) )