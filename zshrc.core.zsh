# ----------------------------------
# zinit
# ----------------------------------

# ----------------------------------
# Plugins
# ----------------------------------
#
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit pack for fzf

# ----------------------------------
# etc
# ----------------------------------
setopt NO_BEEP
export EDITOR=vim
export VISUAL=vim
export LC_ALL='en_US.UTF-8'
# configure XDG Base Directory
[ ! -e ~/.config ] && mkdir ~/.config
export XDG_CONFIG_HOME=~/.config
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
