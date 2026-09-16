#!/bin/sh

old_tty=$(stty -g)

trap 'stty "$old_tty"; printf "\n"' EXIT HUP INT TERM
stty -echo
printf 'Restic password: '
IFS= read -r RESTIC_PASSWORD
stty "$old_tty"
trap - EXIT HUP INT TERM
printf '\n'
export RESTIC_PASSWORD
