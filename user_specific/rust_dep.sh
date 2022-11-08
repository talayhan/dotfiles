#!/bin/bash

source ".logs.sh"

if [[ ! $(command -v "rustup") ]]; then
    debug_log "[+] Installing  rustup... "
    curl https://sh.rustup.rs -sSf | sh
    debug_log "[+] Done "
fi

pkgs=(
'alacritty'
'git-delta'
'cargo-bloat' #find out what takes most of the space in your executable
)

for package in "${pkgs[@]}" ; do
    if [[ ! $(cargo install --list | grep "$package") ]]; then
        debug_log "[+] Installing ${package} ... "
        cargo install "$package"
        debug_log "[+] Done "
    fi
done

