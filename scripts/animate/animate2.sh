#!/bin/bash

animation_frames=( ' /\_/\ \n( o.o )\n > ^ <' '|\---/|\n| o_o |\n \_^_/\n' )
delay=0.5

# Function to draw the animation frame
draw_frame() {
    echo -ne "\033[0;0H${1}"  # Move to row 5, column 10 and draw the frame
}

# Main animation loop
while true; do
    for frame in "${animation_frames[@]}"; do
        draw_frame "$frame"
        sleep "$delay"
    done
done

