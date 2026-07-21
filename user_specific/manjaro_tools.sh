#!/usr/bin/env bash
#
# Manjaro / Arch tooling setup.
#
#   ./user_specific/manjaro_tools.sh
#
# Safe to re-run.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=user_specific/common_tools.sh
. "${SCRIPT_DIR}/common_tools.sh"
# shellcheck source=user_specific/os.sh
. "${SCRIPT_DIR}/os.sh"

if [ "${DOTFILES_OS}" != "manjaro" ]; then
    error_log "[-] This script is for Manjaro/Arch. Detected: ${DOTFILES_OS}"
    exit 1
fi

pacman_packages=(
    'pulseaudio'
    'pavucontrol'
    'tilda'
    'zsh'
    'neovim'
    'python-pynvim'
    'ripgrep'
    'ripgrep-all'
    'git-delta'
    'go'
    'gopls'
    'typescript-language-server'
    'npm'
    'vifm'
    'clang'
    'tmux'
    'rofi'
    'redshift'
    'zathura'
    'xclip'
    'sdcv'
    'newsboat'
    'task'
    'shellcheck'
    'alacritty'
)

npm_packages=(
    'aws-cdk'
)

debug_log "[+] Syncing package databases ..."
sudo pacman -Sy --noconfirm

for pkg in "${pacman_packages[@]}"; do
    if pacman -Qi "${pkg}" >/dev/null 2>&1; then
        debug_log "[+] ${pkg} already installed"
    else
        debug_log "[+] Installing ${pkg} ..."
        sudo pacman -S --needed --noconfirm "${pkg}" || error_log "[-] Failed to install ${pkg}"
    fi
done

for pkg in "${npm_packages[@]}"; do
    if npm list -g --depth 0 "${pkg}" >/dev/null 2>&1; then
        debug_log "[+] ${pkg} already installed"
    else
        debug_log "[+] Installing ${pkg} ..."
        sudo npm install -g "${pkg}" || error_log "[-] Failed to install ${pkg}"
    fi
done

run_common_bootstrap

debug_log "[+] Manjaro setup complete. Run './install' to link the configs."
