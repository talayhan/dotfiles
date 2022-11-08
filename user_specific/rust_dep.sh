#!/bin/bash

source ".logs.sh"

curl https://sh.rustup.rs -sSf | sh

pkgs=(
'alacritty'
'git-delta'
'cargo-bloat' #find out what takes most of the space in your executable
)

for package in "${pkgs[@]}" ; do
    if [[ ! $(which "$package") ]]; then
        debug_log "[+] Installing ${package} ... "
        cargo install "$package"
        debug_log "[+] Done "
    fi
done

