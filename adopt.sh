#!/bin/sh

zrcpos="$HOME/.zshrc"
trcpos="$HOME/.tmux.conf"
srcpos="$HOME/.config/shellrc"
pystpos="$HOME/.config/pythonstartup.py"
gitpos="$HOMOE/.gitconfig"
[[ -f $zrcpos ]] && mv $zrcpos ${zrcpos}.orig
[[ -f $trcpos ]] && mv $trcpos ${trcpos}.orig
[[ -f $srcpos ]] && mv $srcpos ${srcpos}.orig
[[ -f $pystpos ]] && mv $pystpos ${pystpos}.orig
[[ -f $gitpos ]] && mv $gitpos ${gitpos}.orig

dir=$(cd $(dirname $0); pwd)
ln -s $dir/.zshrc $zrcpos
ln -s $dir/.tmux.conf $trcpos
ln -s $dir/shellrc $srcpos
ln -s $dir/.latexmkrc $HOME/
ln -s $dir/pythonstartup.py $pystpos
ln -s $dir/.gitconfig $gitpos
