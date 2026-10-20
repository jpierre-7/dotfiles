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
| [Quarto](https://quarto.org/) | Notebooks (`.qmd`) rendered to PDF with outputs |
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

The script asks for your sudo password once and then runs unattended until the
final reboot prompt. It will:
- Update the system (`pacman -Syu`)
- Install [yay](https://github.com/Jguer/yay) (AUR helper) if not already present
- Install the packages listed in `packages/pacman.txt` and `packages/aur.txt`, plus cargo packages
- Stow all config directories into your home folder
- Install Claude Code and [herdr](https://herdr.dev) into `~/.local/bin`, plus herdr's Claude integration hook
- Write `/etc/keyd/default.conf` to remap Caps Lock to Escape
- Enable the `keyd` and `tailscaled` services, and `cosmic-greeter` if no display manager is set up
- Set fish as your login shell
- Print any remaining manual steps, then prompt you to reboot

The script is safe to re-run: packages are installed with `--needed` and configs
are re-stowed in place.

### Keeping the package lists current

Anything installed by hand is lost on the next reinstall unless it lands in
`packages/`. Run `./drift.sh` now and then: it lists packages installed here but
missing from the lists, and listed packages that aren't installed.
`packages/base.txt` holds what archinstall installs; bootstrap ignores it and
drift.sh uses it only to keep those packages out of the report.

## Structure

```
dotfiles/
├── claude/        # Claude Code settings, statusline, and vendored skills
├── fastfetch/     # fastfetch config
├── fish/          # Fish shell config & abbreviations
├── herdr/         # herdr terminal multiplexer config
├── lsd/           # lsd colors & icons
├── niri/          # Niri compositor config (keybinds, window rules, animations)
├── noctalia/      # Noctalia shell theme & settings
├── nvim/          # LazyVim config, Molten + Quarto notebook setup
├── starship/      # Starship prompt
├── vicinae/       # Vicinae launcher settings
├── wezterm/       # WezTerm config, keybinds, and custom color theme
├── docs/          # Agent docs for this repo (not stowed)
└── packages/      # Package lists read by bootstrap.sh and drift.sh (not stowed)
```

Every other top-level directory is a Stow package; `bootstrap.sh` stows them all into `$HOME`.

## Notes

- Caps Lock is remapped to Escape at the kernel level with [keyd](https://github.com/rvaiya/keyd),
  configured by `bootstrap.sh`. The equivalent `xkb` option is left commented out in the Niri config.
- Everything uses Gruvbox: the Starship `gruvbox_gradient` palette, Noctalia's
  built-in Gruvbox scheme, and WezTerm's `Gruvbox Dark (Gogh)`, with a custom
  `dank-theme` available as an alternative.
- Niri outputs (monitor modes, scale, position) are per machine and live in
  `niri/.config/niri/hosts/<hostname>.kdl`. `bootstrap.sh` links `host.kdl` to the
  file matching `uname -n`; a machine without one gets niri's automatic output setup.
- Fish runs `onefetch` automatically when entering a git repo, and `fastfetch` on shell start.
- Claude Code skills in `claude/.claude/skills/` are vendored: each skill's files
  are committed here, so a freshly cloned device gets them with no install step.
  `~/.claude` and `~/.claude/skills` are real directories (`bootstrap.sh` creates
  them before stowing) and Stow links each skill into them individually. If Stow
  linked the whole directory instead, Claude Code would write its credentials and
  history into this repo. `skills-lock.json` records where each skill came from so
  it can be refreshed by re-copying from source. Matt Pocock's skills come from the
  `mattpocock-skills` plugin instead (see `enabledPlugins` in `settings.json`).

## ⚠️ Noctalia v5 Configuration Architecture

With the update to Noctalia v5, this configuration now utilizes a dual-layered architecture, splitting the setup into a static foundation and a dynamic local state:

*   **The Declarative Foundation (`noctalia/.config/noctalia/noctalia-config.toml`):**
    The settings every machine shares: bar layout, theme, plugins, fonts, and the
    default wallpaper (from [jpierre-7/Wallpapers](https://github.com/jpierre-7/Wallpapers),
    cloned to `~/Pictures/Wallpapers` by `bootstrap.sh`). Version-controlled and stowed.
*   **The Local State Overrides (`~/.local/state/noctalia/settings.toml`):**
    Changes made in the Noctalia GUI land here. Anything tied to a monitor name
    (lockscreen widget positions, per-monitor wallpapers) belongs here, not in the
    repo, because output names differ between machines. Not version-controlled.

The same reasoning applies to `fish/.config/fish/fish_variables`: fish rewrites it at runtime and it stores absolute, machine-specific paths, so it is listed in `.gitignore`. Anything that belongs on every device (such as `$PATH` entries) goes in `config.fish` instead.

## Notebooks

Notebooks are Quarto markdown (`.qmd`) files: Molten runs cells inside Neovim
and `quarto render` produces a PDF with outputs. The full per-project workflow
is in [NOTEBOOKS.md](NOTEBOOKS.md).
