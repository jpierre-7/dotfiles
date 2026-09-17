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
| [Molten](https://github.com/benlubas/molten-nvim) | Jupyter kernels inside Neovim |
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
- Install all packages from the official repos, the AUR, and cargo
- Stow all config directories into your home folder
- Write `/etc/keyd/default.conf` to remap Caps Lock to Escape
- Enable the `keyd` and `tailscaled` services
- Set fish as your login shell
- Print any remaining manual steps, then prompt you to reboot

The script is safe to re-run: packages are installed with `--needed` and configs
are re-stowed in place.

## Structure

```
dotfiles/
├── claude/        # Claude Code agent skills
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

- Caps Lock is remapped to Escape at the kernel level with [keyd](https://github.com/rvaiya/keyd),
  configured by `bootstrap.sh`. The equivalent `xkb` option is left commented out in the Niri config.
- The Starship prompt uses the Catppuccin Frappé palette.
- The Noctalia color scheme is set to Gruvbox.
- WezTerm uses the Catppuccin Frappé color scheme with a custom `dank-theme` available as an alternative.
- Fish runs `onefetch` automatically when entering a git repo, and `fastfetch` on shell start.
- Claude Code skills in `claude/.claude/skills/` are vendored: each skill's `SKILL.md`
  is committed here rather than symlinked into a skill manager's store. Skill
  installers write *relative* symlinks (`../../.agents/skills/...`) that assume
  `~/.claude/skills` is a real directory; because Stow makes it a symlink into this
  repo, those links resolve against the repo instead of `$HOME` and dangle. Vendoring
  also means a freshly cloned device gets the skills with no extra install step.
  `skills-lock.json` records each skill's upstream repo, path, and pinned commit so a
  skill can be refreshed by re-copying from source.

## ⚠️ Noctalia v5 Configuration Architecture

With the update to Noctalia v5, this configuration now utilizes a dual-layered architecture, splitting the setup into a static foundation and a dynamic local state:

*   **The Declarative Foundation (`~dotfiles/noctalia/.config/noctalia/`):** 
    This repository strictly manages the base, non-negotiable foundations of the desktop shell. This includes core keybinds, window rules, and custom terminal integrations (like the Gruvbox Starship prompt). These `.toml` files are version-controlled and symlinked globally via GNU Stow.
*   **The Local State Overrides (`~/.local/state/noctalia/settings.toml`):** 
    Any minor layout tweaks, scaling adjustments, or visual changes made via the Noctalia GUI are saved to this state file. This file acts as an ephemeral, device-specific cache and is intentionally excluded from version control to prevent display conflicts across different hardware setups.

The same reasoning applies to `fish/.config/fish/fish_variables`: fish rewrites it at runtime and it stores absolute, machine-specific paths, so it is listed in `.gitignore`. Anything that belongs on every device (such as `$PATH` entries) goes in `config.fish` instead.
    
## AI Disclosure

AI was used as a learning tool not a replacement for critical thinking. Even during troubleshooting each line and choice was reviewed, understood, and questioned before implementation. Although AI was used to generate a boilerplate for this README, I reviewed every line :)
