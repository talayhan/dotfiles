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
'tokei' # count line of code
)

for package in "${pkgs[@]}" ; do
    if [[ ! $(cargo install --list | grep "$package") ]]; then
        debug_log "[+] Installing ${package} ... "
        cargo install "$package"
        debug_log "[+] Done "
    fi
done

rustup component add rust-src
rustup component add rust-analyzer

# check installed source
echo "[+] Print installed targets ..."
rustup target list | grep installed
echo "[+] done"
echo "[+] Print rust-analyzer version ..."
rust-analyzer --version
echo "[+] done"
