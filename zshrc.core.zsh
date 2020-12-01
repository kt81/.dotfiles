# ----------------------------------
# Plugins
# ----------------------------------
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma/fast-syntax-highlighting
zinit light agkozak/zsh-z
zinit light softmoth/zsh-vim-mode
zinit pack for fzf
# From Prezto
zinit snippet PZT::modules/environment/init.zsh
zinit snippet PZT::modules/completion/init.zsh

# ----------------------------------
# Setting with zinit
# ----------------------------------
zinit ice wait"0" atinit"zicompinit; zicdreplay"

# ----------------------------------
# etc
# ----------------------------------

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
command -v nvim > /dev/null 2>&1 && alias vim=nvim
command -v htop > /dev/null 2>&1 && alias top=htop
command -v python3 > /dev/null 2>&1 && alias python=python3
command -v pip3 > /dev/null 2>&1 && alias pip=pip3
# anyenv
command -v anyenv > /dev/null 2>&1 && eval "$(anyenv init -)"
[ -e ~/.asdf/asdf.sh ] && . ~/.asdf/asdf.sh

# path configuration
if [ -e ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# vim: et:ts=4:sw=4
