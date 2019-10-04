#!/usr/bin/env bash
if pgrep xkeysnail > /dev/null; then
    return 2>&- || exit
fi
if [ ! -x /usr/bin/xkeysnail ]; then
    return 2>&- || exit
fi
xhost +SI:localuser:xkeysnail > /dev/null
tmp=$(mktemp /tmp/xkeysnail.XXXX.py)
cp $HOME/.config/xkeysnail/hhkjplite.py $tmp
chmod o+r $tmp
sudo -u xkeysnail /usr/bin/xkeysnail $tmp > /dev/null &
eval "sleep 5 && rm $tmp" &

