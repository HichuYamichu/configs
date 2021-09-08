#!/bin/sh
#
# ~/.xinitrc
xsetroot -cursor_name left_ptr &
setxkbmap pl -option caps:ctrl_modifier &
exec dbus-run-session -- xmonad
