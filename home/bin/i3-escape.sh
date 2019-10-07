#!/usr/bin/env bash
commands="exit|suspend|poweroff|reboot|lock"
cmd=$(echo $commands | rofi -dmenu -sep "|")
case "$cmd" in
	"exit" ) i3-msg exit ;;
	"poweroff" ) systemctl poweroff ;;
	"reboot" ) systemctl reboot ;;
	"lock" ) i3lock ;;
	"suspend" ) i3lock && systemctl suspend ;;
	* ) i3-navbar -m "invalid command name"
esac

