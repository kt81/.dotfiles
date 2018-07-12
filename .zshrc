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
# dein
# ----------------------------------
if [ ! -e ~/.vim/dein ] ; then
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
    sh ./installer.sh .vim/dein
    rm -f installer.sh
fi

# ----------------------------------
# etc
# ----------------------------------
setopt NO_BEEP
export EDITOR=vim
export VISUAL=vim
# configure XDG Base Directory
[ ! -e ~/.config ] && mkdir ~/.config
export XDG_CONFIG_HOME=~/.config
# configure aliases
which nvim > /dev/null 2>&1 && alias vim=nvim
which htop > /dev/null 2>&1 && alias top=htop
# path configuration
if [ -e ~/.local/bin ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi
