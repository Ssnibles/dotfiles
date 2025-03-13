#!/bin/bash

while [[ true ]]; do
  echo -e "\033[10;30H" # Set cursor position to row;collumn
  echo -e "\033[s" # Save cursor position on screen
  echo -e "\033[10;30H\033[K"
  echo -e " /\_/\ \n( o.o )\n > ^ <"
  sleep 1.0
  clear
  echo -e "|\---/|\n| o_o |\n \_^_/\n"
  sleep 1.0
  clear
done
