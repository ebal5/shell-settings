[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
dirfile=$(mktemp -p /tmp tmuxdir.XXXXX)

# definition of fuzzy method
if fzf -h 2> /dev/null ; then
	fuzzy=fzf
	if gibo help > /dev/null 2>&1; then
		function genignore() {
			gibo dump $(gibo list | fzf --multi | tr "\n" " ") >> .gitignore
		}
	fi
elif fzy -h 2> /dev/null ; then
	fuzzy=fzy
elif peco -h 2> /dev/null ; then
	fuzzy=peco
fi

if [ ! -z $fuzzy ]; then
    if [[ ! -n $TMUX ]] ; then
	    choices="New session with name\nNew session\nPlain"
	    sessions=$(tmux ls -F "#{session_name}" 2> /dev/null | sort -r)
	    if [ ! -z $sessions ]; then
	        choices="$choices\n$sessions"
	    fi
	    choise=$(echo $choices | $fuzzy)
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
    function __chpwd_savepath() {
        $(pwd > $dirfile)
    }
    function __exit_rmpath() {
        rm $dirfile
    }
    preexec() {
        local line=${1%%$'\n'}
        local cmd=${line%% *}
        if [ ${line} = 'exec ${SHELL}' -o $line = 'exec $SHELL' ] ; then
            if [ -f $dirfile ]; then
                rm $dirfile
            fi
        fi
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd __chpwd_savepath
    function cdt() {
        if [ $# -eq 1 ] ; then
            cd $1
            return
        elif [ ! $# -eq 0 ] ; then
            >&2 echo "too many arguments"
            return 1
        fi
        dlist=$(cat /tmp/tmuxdir* | sort | uniq | grep -vEw "^$(pwd)$")
        d=$(echo $dlist | $fuzzy)
        cd $d
    }
    function cdf() {
        choise=$(cdr -l | sed -e "s/^..*  *//" | sort | uniq | fzf)
        hs=$(echo $choise | grep -oE "~[a-zA-Z]+" | tr -d "~")
        for h in ${hs}; do
            rep=$(hash -d | grep -E "^${h}=" | cut -d "=" -f 2)
            choise=${choise/"~${h}"/${rep}}
        done
        choise=$(echo $choise | sed -e "s!^~/!${HOME}/!")
        cd $choise
    }
fi

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
    "@gc"	'| grep --color=always'
    "@l"	'| less'
    "@x"	'| xargs'
    "@s"	'| sed -e'
    "@u"	'| sort | uniq'
    "@t"	'| tail'
    "@h"	'| head'
    "@w"	'| wc'
    "@wl"	'| wc -l'
    "@a"	'| awk'
    "@j"	'| jq'
    "@jc"	'| jq -C'
    "@r"	'| rg'
    "@rc"	'| rg --color=always'
    "@cp"	'| xsel -b'
    "@c"	'| cut'
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
color="080"
hcolor="033"
if [ ! -z $SSH_CLIENT -o ! -z $SSH_CONNECTION ]; then
    color="220"
    hcolor="222"
fi
if [ "$USER" = "root" ]; then
    color="124"         # root is red, user is blue
fi

PROMPT="%F{$color}%n%f@%F{$hcolor}%m%f: %F{014}$pd%f
%F{040}>%f "
echo -ne "\033]0;${USER}@${HOST} (*'v'*)\007"
precmd() {
    vcs_info
    local pd
    pd=$(pwd | sed -e "s|${HOME}|~|" -e "s|\([^~/]\)[^/]*/|\1/|g")
    PROMPT="%F{014}%n%f@%F{$hcolor}%m%f: %F{014}$pd%f
%{%(?.%F{040}.%F{124})%}%(?.(*'v'*%) >.(-_-##%) >)%f "
    RPROMPT="${vcs_info_msg_0_}"
}

# zmv

autoload -Uz zmv
alias zmv='noglob zmv -w'

# zed

autoload -Uz zed

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

[ -d ~/.anyenv/bin ] && export PATH="$HOME/.anyenv/bin:$PATH" && \
    eval "$(anyenv init -)"

# load user settings

[[ -f ~/.config/shellrc ]] && . ~/.config/shellrc
