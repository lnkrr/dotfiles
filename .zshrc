ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

eval "$(zoxide init zsh --cmd cd)"

if [[ -z "$DISPLAY" ]] && [[ "$(tty)" == /dev/tty1 ]]; then
    dbus-run-session niri --session
fi

if [[ $(id -u) -eq 0 ]]; then
    PROMPT='%F{red}%~ %(?.%F{blue}.%F{red})❯ %f'
else
    PROMPT='%F{blue}%~ %(?.%F{blue}.%F{red})❯ %f'
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light MichaelAquilina/zsh-you-should-use

ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red

autoload -U +X bashcompinit && bashcompinit
autoload -U compinit; compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zcache

bindkey -v

_insert_mode() {
    echo -ne '\e[5 q'
}

precmd_functions+=(_insert_mode)

zle-keymap-select() {
    if [[ ${KEYMAP} = vicmd ]] ||
       [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
    elif [[ ${KEYMAP} = main ]] ||
         [[ ${KEYMAP} = viins ]] ||
         [[ ${KEYMAP} = '' ]] ||
         [[ $1 = 'beam' ]]; then
        _insert_mode
    fi
}

zle -N zle-keymap-select

_alias() {
    cmd=$1; shift

    alias $cmd="$*"
    compdef "_$1" "$cmd"
}

_alias v nvim
_alias xbi xbps-install -y
_alias xbr xbps-remove -Ryo
_alias xbc xbps-remove -RyoO
_alias xbq xbps-query
_alias xbs xbps-query -Rs
_alias xbu xbps-install -Suy
_alias s "doas "
_alias doas "doas "
_alias less less -RI
_alias g git
_alias ga git add
_alias gc git commit
_alias gl git log
_alias gp git push
_alias gcm git commit --amend
_alias gs git status
_alias gd git diff
_alias gdc git diff --cached
_alias gds git diff --stat
_alias gdcs git diff --cached --stat
_alias ls ls --color=auto
_alias l ls -lh
_alias m make -j$(nproc)
_alias n ninja
_alias py python
_alias cat bat --theme=ansi --style=plain

bindkey -s "^Z" 'fg^M'
bindkey '^F' autosuggest-accept

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt CORRECT
setopt NOCASEGLOB
setopt NUMERICGLOBSORT

export EDITOR=nvim
export WINEPREFIX=/media/data/games/wine
export HISTFILE=/home/lnkrr/.zhistory
export SAVEHIST=5000
export HISTSIZE=5000
