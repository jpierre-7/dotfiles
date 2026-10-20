#!/usr/bin/env bash
# Report where this machine's packages and packages/*.txt disagree, so the
# lists can be updated before the next reinstall. Read-only.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read_pkgs() { sed 's/#.*//' "$1" | tr -s ' \t' '\n' | sed '/^$/d' | sort -u; }

# makepkg's split debug packages and yay itself are never listed
installed_foreign() { pacman -Qqm | grep -vE -- '-debug$|^yay$' | sort -u; }

report() {
  local title="$1" body="$2"
  [ -z "$body" ] && return
  printf '\n%s\n' "$title"
  printf '%s\n' "$body" | sed 's/^/  /'
}

PACMAN_LISTED=$(read_pkgs "$DOTFILES/packages/pacman.txt")
BASE_LISTED=$(read_pkgs "$DOTFILES/packages/base.txt")
AUR_LISTED=$(read_pkgs "$DOTFILES/packages/aur.txt")
NATIVE_KNOWN=$(printf '%s\n%s\n' "$PACMAN_LISTED" "$BASE_LISTED" | sort -u)

report "Installed from the repos, not in pacman.txt or base.txt:" \
  "$(comm -23 <(pacman -Qqen | sort -u) <(echo "$NATIVE_KNOWN"))"
report "In pacman.txt, not installed:" \
  "$(comm -13 <(pacman -Qq | sort -u) <(echo "$PACMAN_LISTED"))"
report "Installed from the AUR, not in aur.txt:" \
  "$(comm -23 <(installed_foreign) <(echo "$AUR_LISTED"))"
report "In aur.txt, not installed:" \
  "$(comm -13 <(pacman -Qq | sort -u) <(echo "$AUR_LISTED"))"
