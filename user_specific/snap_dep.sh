#!/bin/bash

source ".logs.sh"

snaps=(
'irssi'
)

for snap in "${snaps[@]}" ; do
    if [[ ! $(which "${snap}") ]]; then
        debug_log "[+] Installing ${snap} ... "
        sudo snap install --edge "${snap}"
        debug_log "[+] Done "
    else
        debug_log "[+] ${snap} is already installed."
    fi
done

