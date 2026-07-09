#
# Core zsh configuration (tracked by dotfiles).
# Sourced from the local, untracked ~/.zshrc so that tool installers
# (nvm, fzf, ...) append to ~/.zshrc without ever touching this repo.
#

# ----------------------------------
# Plugin manager (zinit)
# ----------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ----------------------------------
# Plugins
# ----------------------------------
# Friendly bindings for zsh's vi mode.
zinit light softmoth/zsh-vim-mode

# Deferred (turbo): syntax highlighting, extra completions, autosuggestions.
# `zicompinit` here runs compinit once — no separate compinit elsewhere.
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# directory jumping -> zoxide, fzf keybindings -> `fzf --zsh` (both near the bottom)

# completion behaviour (replaces Prezto's completion module; compinit runs above)
[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# ----------------------------------
# etc
# ----------------------------------

source ${HOME}/.dotfiles/lib/libxnix.sh

# Common Env
if cex nvim ; then
    VIM_BIN=nvim
    alias vim=nvim
else
    VIM_BIN=vim
fi
export EDITOR=$VIM_BIN
export GIT_EDITOR=$VIM_BIN
export VISUAL=$VIM_BIN

# configure XDG Base Directory
[ ! -e ~/.config ] && mkdir ~/.config
export XDG_CONFIG_HOME=~/.config

# Locale: prefer en_US.UTF-8, fall back to C.UTF-8 when it isn't generated
# (avoids "setlocale: cannot change locale" warnings on a fresh Ubuntu/WSL).
if locale -a 2>/dev/null | grep -qix 'en_US.utf-\?8'; then
    export LANG='en_US.UTF-8'
    export LC_ALL='en_US.UTF-8'
else
    export LANG='C.UTF-8'
    export LC_ALL='C.UTF-8'
fi

# Common Options (a few sane defaults formerly pulled from Prezto's environment module)
setopt NO_BEEP
setopt autocd
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups
setopt automenu
setopt INTERACTIVE_COMMENTS   # allow `#` comments at the interactive prompt
setopt COMBINING_CHARS        # combine accents with the base character
setopt RC_QUOTES              # '' means a literal ' inside single quotes
setopt LONG_LIST_JOBS         # verbose job list
unsetopt HUP                  # don't SIGHUP background jobs when the shell exits
bindkey -v

# History
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=10000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

# configure aliases
cex htop    && alias top=htop
cex python3 && alias python=python3
cex pip3    && alias pip=pip3
cex fdfind  && alias fd=fdfind

function start() {
    nohup xdg-open $1 2>/dev/null &
}

# ls -> eza
if [ -e $HOME/.cargo/env ] ; then
    source $HOME/.cargo/env
fi
if cex eza ; then 
    alias ls='eza -F'
    alias ll='eza -alF'
    alias la='eza -aF'
fi

# path configuration
if [ -d /opt/homebrew/bin ] ; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# mise (runtime version manager; replaces asdf + nvm) — needs Homebrew on PATH first
cex mise && eval "$(mise activate zsh)"

# zoxide (smart cd; replaces zsh-z) — provides `z` / `zi`
cex zoxide && eval "$(zoxide init zsh)"

# prompt: starship (config tracked at ~/.dotfiles/starship.toml)
export STARSHIP_CONFIG="$HOME/.dotfiles/starship.toml"
cex starship && eval "$(starship init zsh)"

# fzf integration (keybindings + completion)
if cex fzf && fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)"          # modern (fzf >= 0.48, e.g. Homebrew)
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh            # legacy fallback (git-install)
fi

# atuin: SQLite-backed shell history (Ctrl-R). Init LAST so it owns Ctrl-R;
# fzf keeps Ctrl-T / Alt-C. Sync stays off (local only). Up-arrow left to zsh.
export ATUIN_CONFIG_DIR="$HOME/.dotfiles/atuin"
cex atuin && eval "$(atuin init zsh --disable-up-arrow)"

# WSL: clipboard (win32yank), Windows interop, and a trimmed PATH re-add.
# Sourced last so its start()/PATH tweaks win. Config in zshrc.wsl.zsh.
if [[ -n "$WSL_DISTRO_NAME" ]] && [ -f "${HOME}/.dotfiles/zshrc.wsl.zsh" ]; then
    source "${HOME}/.dotfiles/zshrc.wsl.zsh"
fi

# Machine-specific settings & tool-installer output live in ~/.zshrc
# (the local file that sources this one), not here.

# keychain
if cex keychain && [ -f $HOME/.ssh/id_rsa ]; then
  /usr/bin/keychain --nogui $HOME/.ssh/id_rsa -q
  source $HOME/.keychain/$(hostname)-sh
fi

# vim: et:ts=4:sw=0:sts=-1
