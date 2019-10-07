#!/usr/bin/env bash

commands="fzf ssh git xkeysnail rofi qalc"
for cmd in $commands; do
    which $cmd > /dev/null || uncmd="$cmd, $uncmd"
done
echo Lack commands: $uncmd

mv=mv
ln=ln

pwd=$(cd $(dirname $0); pwd)
rm -rf $pwd/old
mkdir -p $pwd/old/.config $pwd/old/bin

echo making dirs
for dn in bin .config; do
    [ ! -d $HOME/$dn ] && mkdir $HOME/$dn
done

echo create link to directory under config dir
for dn in $(find $(pwd)/home/.config/ -maxdepth 1 -type d | sed 's|.*home/\.config/||'); do
    [ -d $HOME/.config/$dn ] && $mv $HOME/.config/$dn $pwd/old/.config
    $ln -s $pwd/home/.config/$dn $HOME/.config/
done

echo create link to file under config dir
for fn in $(find $(pwd)/home/.config -maxdepth 1 -type f | sed 's|.*home/\.config/||'); do
    [ -e $HOME/.config/$fn ] && $mv $HOME/.config/$fn $pwd/old/.config/
    $ln -s $pwd/home/.config/$fn $HOME/.config/
done

echo create link to file in bin dir
for fn in $(find $(pwd)/home/bin -maxdepth 1 -type f | sed 's|.*home/bin/||'); do
    [ -e $HOME/bin/$fn ] && $mv $HOME/bin/$fn old/bin
    [ -L $HOME/bin/$fn ] && unlink $HOME/bin/$fn
    $ln -s $pwd/home/bin/$fn $HOME/bin/
done

echo create link to file in home dir
for fn in $(find $(pwd)/home/ -maxdepth 1 -type f | sed 's|.*home/||'); do
    [ -e $HOME/$fn ] && $mv $HOME/$fn $pwd/old
    [ -L $HOME/$fn ] && unlink $HOME/$fn
    $ln -s $pwd/home/$fn $HOME/$fn
done

echo cloning anyenv...
[ ! -d $HOME/.anyenv ] && git clone https://github.com/anyenv/anyenv ~/.anyenv

echo all done

