#
# Core zsh configuration (tracked by dotfiles).
# Sourced from the local, untracked ~/.zshrc so that tool installers
# (nvm, fzf, ...) append to ~/.zshrc without ever touching this repo.
#

# Enable Powerlevel10k instant prompt. Must stay near the top; nothing above
# it may print to the console or read input. (~/.zshrc sources this file first.)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Powerlevel10k is a theme for Zsh. It emphasizes speed, flexibility and out-of-the-box experience.
zinit ice depth=1; zinit light romkatv/powerlevel10k
# (directory jumping handled by zoxide — see `zoxide init` near the bottom)
# Friendly bindings for ZSH's vi mode.
zinit light softmoth/zsh-vim-mode
# (fzf keybindings come from `fzf --zsh` near the bottom, not a zinit pack —
#  the pack builds fzf from source and needs Go, which broke first-run setup)
# Sets general shell options and defines environment variables.
zinit snippet PZTM::environment

# fast-syntax-highlighting: Feature-rich syntax highlighting for ZSH
# zsh-completions: Additional completion definitions for Zsh.
# zsh-autosuggentions: Fish-like autosuggestions for zsh
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions
# provides additional completions from the zsh-completions project.
zinit snippet PZTM::completion

#zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
#zinit light zsh-users/zsh-syntax-highlighting
zinit ice as:program cp:"httpstat.sh -> httpstat" pick:httpstat
zinit light b4b4r07/httpstat

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

# Locale
export LC_ALL='en_US.UTF-8'

# Common Options
setopt NO_BEEP
setopt autocd
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups
setopt automenu
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

#  asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# path configuration
if [ -d /opt/homebrew/bin ] ; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# zoxide (smart cd; replaces zsh-z) — provides `z` / `zi`
cex zoxide && eval "$(zoxide init zsh)"

# prompt (Powerlevel10k) — customize via `p10k configure`
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf integration (keybindings + completion)
if cex fzf && fzf --zsh &>/dev/null; then
    eval "$(fzf --zsh)"          # modern (fzf >= 0.48, e.g. Homebrew)
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh            # legacy fallback (git-install)
fi

# Machine-specific settings & tool-installer output live in ~/.zshrc
# (the local file that sources this one), not here.

# keychain
if cex keychain && [ -f $HOME/.ssh/id_rsa ]; then
  /usr/bin/keychain --nogui $HOME/.ssh/id_rsa -q
  source $HOME/.keychain/$(hostname)-sh
fi

# vim: et:ts=4:sw=0:sts=-1
