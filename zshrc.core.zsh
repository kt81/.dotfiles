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
# Jump quickly to directories that you have visited "frecently."
# A native Zsh port of z.sh with added features.
zinit light agkozak/zsh-z
# Friendly bindings for ZSH's vi mode.
zinit light softmoth/zsh-vim-mode
# fzf extension
zinit pack"default+keys" for fzf
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
export EDITOR=vim
export GIT_EDITOR=vim
export VISUAL=vim

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
cex nvim    && alias vim=nvim
cex htop    && alias top=htop
cex python3 && alias python=python3
cex pip3    && alias pip=pip3
cex fdfind  && alias fd=fdfind

# ls -> exa
if [ -e $HOME/.cargo/env ] ; then
    source $HOME/.cargo/env
fi
if cex exa ; then 
    alias ls='exa -F'
    alias ll='exa -alF'
    alias la='exa -aF'
fi

# anyenv or asdf
cex anyenv && eval "$(anyenv init -)"
[ -f ~/.asdf/asdf.sh ] && . ~/.asdf/asdf.sh

# path configuration
if [ -d ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# local configuration
if [ -f ~/.zshrc.local ] ; then
    source ~/.zshrc.local
else
    touch ~/.zshrc.local
fi

# keychain
if cex keychain && [ -f $HOME/.ssh/id-rsa ]; then
  /usr/bin/keychain --nogui $HOME/.ssh/id_rsa -q
  source $HOME/.keychain/$(hostname)-sh
fi

# vim: et:ts=4:sw=0:sts=-1
