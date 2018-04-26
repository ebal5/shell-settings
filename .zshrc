fzf -h 2> /dev/null
if [ $? -eq 0 ]; then
    if [[ ! $- == *l* ]] ; then
	choices="New session with name\nNew session\nPlain"
	sessions=$(tmux ls -F "#{session_name}" 2> /dev/null | sort -r)
	if [ ! -z $sessions ]; then
	    choices="$choices\n$sessions"
	fi
	choise=$(echo $choices | fzf)
	case $choise in
	    "Plain")
		;;
	    "New session")
		tmux new
		;;
	    "New session with name")
		printf "Name: "
		read name
		tmux new -t $name
		;;
	    ?*)
		tmux a -t $choise
		;;
	    *)
		;;
	esac
    fi
fi



[[ -f ~/.config/shellrc ]] && . ~/.config/shellrc

bindkey -e			# Use emacs-like key bind

# zplug settings
if [ -f ~/.zplug/init.zsh ]; then 
    source ~/.zplug/init.zsh
    zplug "zsh-users/zsh-autosuggestions"
    zplug 'zsh-users/zaw'
    zplug 'zsh-users/zsh-syntax-highlighting', defer:2
    zplug "zsh-users/zsh-completions"
fi
if ! zplug check --verbose; then
    printf 'Install? [y/N]: '
    if read -q; then
	echo; zplug install
    fi
fi
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook is-at-least
if is-at-least 4.3.10; then
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5000
zstyle ':chpwd:*' recent-dirs-default yes
fi
zplug load

# global aliases

setopt extended_glob
typeset -A abbreviations
abbreviations=(
    "@g"	'| grep'
    "@l"	'| less'
    "@x"	'| xargs'
    "@s"	'| sed -e'
    "@u"	'| sort | uniq'
    "@t"	'| tail'
    "@h"	'| head'
    "@w"	'| wc'
    "@a"	'| awk'
)
magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[-.@_a-zA-Z0-9]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    echo $LBUFFER >> /tmp/shell
    zle self-insert
}
no-magic-abbrev-expand() {
  LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x " no-magic-abbrev-expand
alias -g ...="../.."
alias -g ....="../../.."

# suffix aliases

alias -s txt="cat"
alias -s rb="ruby"
alias -s py="python"
function runcpp() {
    clang -O2 $1
    shift
    ./a.out $@
}
alias -s {c,cpp}="runcpp"
function runjava() {
    ccl=$1
    ccln=${ccl%.java}
    javac $ccl
    shift
    java $ccln $@
}
alias -s java="runjava"

# Hisotry settings

autoload history-search-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt appendhistory
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt incappendhistory
setopt sharehistory
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

zshaddhistory () {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    [[ ${#line} -ge 5 \
	&& ${cmd} != (c|cd) \
	&& ${cmd} != (m|man) \
	&& ${cmd} != (l|l[lsah])
     ]]
}
setopt inc_append_history


# completion

autoload -U compinit; compinit
setopt correct
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups	# ignore if dups
setopt auto_list
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both
## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
## 詳細な情報を使わない
zstyle ':completion:*' verbose no
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
       /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Prompt settings
autoload -Uz colors; colors
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn hg
setopt prompt_subst
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
setopt PROMPT_SUBST     # allow funky stuff in prompt
color="cyan"
if [ "$USER" = "root" ]; then
    color="red"         # root is red, user is blue
fi

PROMPT="%{$fg[green]%}%n%{$reset_color%}@%m: %{$fg[cyan]%}%~%{$reset_color%}
%{$fg[green]%}>%{$reset_color%} "
echo -ne "\033]0;${USER}@${HOST} (*･ω･*)\007"
precmd() {
    vcs_info
    local pd
    pd=$(pwd | sed -e "s|${HOME}|~|" -e "s|\([^~/]\)[^/]*/|\1/|g")
    PROMPT="%{$fg[$color]%}%n%{$reset_color%}@%m: %{$fg[cyan]%}$pd%{$reset_color%}
%{%(?.$fg[green].$fg[red])%}%(?.(*'v'*%) >.(-_-##%) >)%{$reset_color%} "
    RPROMPT="${vcs_info_msg_0_}"
}

# zmv

autoload -Uz zmv
alias zmv='noglob zmv -w'

# zed

autoload -Uz zed

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && 
source "${HOME}/.sdkman/bin/sdkman-init.sh"
