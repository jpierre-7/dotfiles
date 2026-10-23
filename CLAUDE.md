# CLAUDE.md

Personal Arch Linux dotfiles (Niri + Noctalia, WezTerm, Fish, LazyVim), managed
with GNU Stow and synced between a laptop and a desktop. `README.md` is the
human-facing guide; this file covers what an agent needs to avoid breaking things.

## How the repo is laid out

- Every top-level directory except `packages/` is a Stow package.
  Paths inside mirror `$HOME`: `fish/.config/fish/config.fish` →
  `~/.config/fish/config.fish`. A new tool's config goes in a new top-level
  directory with the same shape; `bootstrap.sh` picks it up automatically.
- `.claude/settings.json` at the root is Claude Code's project config for this
  repo, not a Stow package (bootstrap's `*/` loop skips dotdirs). It turns the
  `mattpocock-skills` plugin off here while it stays on globally.
- The files in `~` are symlinks into this repo. Editing either side edits the
  same file, and so does any program that rewrites its own config (Claude Code,
  herdr, Noctalia). Check `git status` for changes you didn't make before committing.
- `bootstrap.sh`: full provisioning of a fresh Arch install (packages, stow,
  services, Claude Code, herdr). Must stay idempotent and unattended: `--needed`,
  `--noconfirm`, guard every one-time step with an existence check.
- `drift.sh`: read-only report of installed packages vs `packages/*.txt`.
- `packages/pacman.txt`, `packages/aur.txt`: what bootstrap installs. One or more
  names per line, `#` comments, grouped by purpose. `packages/base.txt` is what
  archinstall installs; bootstrap ignores it and drift.sh uses it only as an
  exclusion list. Cargo and pip packages are arrays in `bootstrap.sh`.

## Rules

- **Shared config only.** Anything that differs per machine stays out of shared files:
  - Niri outputs go in `niri/.config/niri/hosts/<hostname>.kdl` (hostname from
    `uname -n`). `host.kdl` is a per-machine symlink made by bootstrap and is gitignored.
  - Noctalia: shared settings in `noctalia-config.toml`; anything tied to a
    monitor name belongs in `~/.local/state/noctalia/settings.toml` (not in the repo).
  - Fish: put `$PATH` and globals in `config.fish`, never in `fish_variables` (gitignored).
- **New package → add it to the right list** in `packages/` in the same change,
  with a comment if the reason isn't obvious. Otherwise it's lost on the next reinstall.
- **`~/.claude` must stay a real directory**, as must `~/.claude/skills`. Stow
  links individual files and skill folders into them. Never restructure
  `claude/` so Stow would link the whole directory; Claude Code would then
  write credentials and history into this repo.
- **Skills in `claude/.claude/skills/` are vendored.** Don't edit third-party
  skill files in place; refresh by re-copying from the source at a newer commit
  and updating the pinned commit in `skills-lock.json`. Matt Pocock's skills come
  from the `mattpocock-skills` plugin (`enabledPlugins` in `settings.json`), not
  from this folder, except `claude-handoff`. `skills/synced/` is managed by
  Claude Code and gitignored.
- **This repo is public.** Don't commit secrets, tokens, hostnames/IPs of private
  machines, or details of private work projects. `claude/.claude/settings.json`
  is the usual risk because tools write into it.
- Theme is Gruvbox everywhere (Starship, Noctalia, WezTerm). Keep new configs consistent.
- Keep `README.md` in sync when you change bootstrap steps, the stack, or the structure.

## Checking changes

Nothing here has tests. Validate what you touched:

```bash
bash -n bootstrap.sh drift.sh && shellcheck bootstrap.sh drift.sh
fish -n fish/.config/fish/config.fish
niri validate -c niri/.config/niri/config.kdl
stow -n -v -t ~ <package>      # dry run: shows links, reports conflicts
./drift.sh                     # after package list changes
```

Don't run `bootstrap.sh` to test it: it upgrades the system, installs packages,
writes `/etc`, and can reboot. Ask first.

## Commits

Short imperative subject in sentence case, no prefix: `Put rustup's
rust-analyzer proxy on PATH`, `Split per-machine display config out of shared
configs`. Larger changes go on a branch and a PR.
