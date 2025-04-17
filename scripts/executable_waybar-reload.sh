#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/new-hypr $HOME/.config/waybar/style.css"

trap "killall waybar" EXIT

while true; do
    waybar -c $HOME/.config/waybar/new-hypr
    inotifywait -e create,modify $CONFIG_FILES
    killall waybar
done
