# ----------------------------------
# zplug
# ----------------------------------
[ -e ~/.zplug ] || (curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh)
source ~/.zplug/init.zsh

zplug "modules/environment", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/history", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/spectrum", from:prezto
zplug "modules/utility", from:prezto
zplug "modules/completion", from:prezto
zplug "modules/git", from:prezto
zplug "modules/tmux", from:prezto
zplug "modules/prompt", from:prezto
zstyle ':prezto:module:prompt' theme 'paradox'
zstyle ':prezto:module:utility:ls' color 'yes'
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

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
# path configuration
if [ -e ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [ -e ~/.config/composer/vendor/bin ] ; then
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"
fi
if [ -e ~/Library/Android/sdk/platform-tools/ ] ; then
    export PATH="$HOME/Library/Android/sdk/platform-tools/:$PATH"
fi
[ -e "$HOME/Library/Python/3.7/bin" ] && export PATH="$HOME/Library/Python/3.7/bin:$PATH"

# vim: et:ts=4:sw=4
