#!/usr/bin/env bash
#
# Bootstrap for macOS / Linux. Clones the repo to ~/.dotfiles (if needed)
# then runs setup.sh. Intended for:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kt81/.dotfiles/HEAD/install.sh)"
#
set -euo pipefail

repo="https://github.com/kt81/.dotfiles.git"       # HTTPS: works before any SSH key exists
repoSsh="git@github.com:kt81/.dotfiles.git"         # switched to after clone (see below)
dest="$HOME/.dotfiles"

# macOS: until the Xcode Command Line Tools are installed, /usr/bin/git is a
# stub that pops up the GUI installer and exits non-zero, so the clone below
# would die. The Homebrew installer installs the CLT unattended (via
# softwareupdate), and setup.sh needs Homebrew anyway, so install it first.
if [[ "$(uname -s)" == Darwin ]] && ! xcode-select -p &>/dev/null ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v git &>/dev/null ; then
    echo "git is required to bootstrap the dotfiles. Please install git and retry." >&2
    exit 1
fi

if [ ! -d "$dest/.git" ] ; then
    git clone "$repo" "$dest"
else
    echo "Existing checkout found at $dest — leaving it as is."
fi

# Bootstrap clones over HTTPS (no SSH key needed yet); switch origin to SSH so
# day-to-day pull/push uses keys instead of prompting for a password/token.
git -C "$dest" remote set-url origin "$repoSsh"

exec "$dest/setup.sh"
