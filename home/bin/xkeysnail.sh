#!/usr/bin/env bash

if [ ! -x /usr/bin/xkeysnail ]; then
    return 2>&- || exit
fi
if ! pgrep xkeysnail > /dev/null; then
    exec >> /tmp/xkeysnail.log 2>&1
    xhost +SI:localuser:xkeysnail > /dev/null
    tmp=$(mktemp /tmp/xkeysnail.XXXX.py)
    cp $HOME/.config/xkeysnail/config.py $tmp
    chmod o+r $tmp
    sudo -u xkeysnail DISPLAY=$DISPLAY /usr/bin/xkeysnail $tmp > /dev/null &
    eval "sleep 5 && rm $tmp" &
fi
