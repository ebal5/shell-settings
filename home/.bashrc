#
# ~/.bashrc
#

source $HOME/bin/ssh-agent.sh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

if [ -f $HOME/.config/shellrc ]; then
    source $HOME/.config/shellrc
fi

exec fish
