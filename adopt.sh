#!/bin/sh

zrcpos="$HOME/.zshrc"
trcpos="$HOME/.tmux.conf"
srcpos="$HOME/.config/shellrc"
pystpos="$HOME/.config/pythonstartup.py"
gitpos="$HOME/.gitconfig"
texmf="$HOME/.texmf"
[[ -f $zrcpos ]] && mv $zrcpos ${zrcpos}.orig
[[ -f $trcpos ]] && mv $trcpos ${trcpos}.orig
[[ -f $srcpos ]] && mv $srcpos ${srcpos}.orig
[[ -f $pystpos ]] && mv $pystpos ${pystpos}.orig
[[ -f $gitpos ]] && mv $gitpos ${gitpos}.orig
[[ -d $texmf ]] && mv $texmf ${texmf}.orig

dir=$(cd $(dirname $0); pwd)
ln -s $dir/.zshrc $zrcpos
ln -s $dir/.tmux.conf $trcpos
ln -s $dir/shellrc $srcpos
ln -s $dir/.latexmkrc $HOME/
ln -s $dir/pythonstartup.py $pystpos
ln -s $dir/.gitconfig $gitpos
ln -s $dir/.texmf $HOME/.texmf

[ ! -d $HOME/bin ] && mkdir $HOME/bin
ln -s $dir/git-home $HOME/bin
ln -s $dir/git-cdtop $HOME/bin

[ ! -d $HOME/.config/fish/ ] && mkdir -p $HOME/.config/fish
ln -s $dir/config.fish $HOME/.config/fish/
