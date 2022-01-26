#!/bin/bash

source "functions.sh"

utils=(
"klavaro"
"deluge"
)

for util in "${utils[@]}" ; do
    if [[ ! $(which "$util") ]]; then
        debug_log "[+] Installing ${util} ... "
        sudo apt install "$util"
        debug_log "[+] Done "
    else
        debug_log "[+] ${util} is already installed!"
    fi
done
