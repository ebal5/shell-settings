#!/bin/sh

zrcpos="$HOME/.zshrc"
trcpos="$HOME/.tmux.conf"
srcpos="$HOME/.config/shellrc"
[[ -f $zrcpos ]] && mv $zrcpos ${zrcpos}.orig
[[ -f $trcpos ]] && mv $trcpos ${trcpos}.orig
[[ -f $srcpos ]] && mv $srcpos ${srcpos}.orig

dir=$(cd $(dirname $0); pwd)
ln -s $dir/.zshrc $zrcpos
ln -s $dir/.tmux.conf $trcpos
ln -s $dir/shellrc $srcpos
ln -s $dir/.latexmkrx $HOME/
