#!/bin/sh
exec >> /tmp/xkeysnail.log 2>&1
xhost +SI:localuser:xkeysnail
tmp=$(mktemp /tmp/CONFIG.XXXX)
cp $HOME/.config/etc/xkeysnail/config.py $tmp
chmod +r $tmp
sudo -u xkeysnail DISPLAY=$DISPLAY /usr/bin/xkeysnail $tmp

