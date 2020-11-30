# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# vim: et:ts=4:sw=4:ft=zsh

ZDIR=${ZDOTDIR:-$HOME}

### Added by Zinit's installer
if [[ ! -f $ZDIR/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$ZDIR/.zinit" && command chmod g-rwX "$ZDIR/.zinit"
    command git clone https://github.com/zdharma/zinit "$ZDIR/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$ZDIR/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

source $HOME/.dotfiles/zshrc.core.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local Settings --------

if command -v keychain > /dev/null 2&>1 ; then
    /usr/bin/keychain --nogui $HOME/.ssh/id_rsa
    source $HOME/.keychain/$(hostname)-sh
fi

# /Local Settings -------

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
