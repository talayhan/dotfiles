#!/usr/bin/env bash
#
# macOS tooling setup. Terminal-first: no window manager, no X11.
#
#   ./user_specific/macos_tools.sh
#
# Safe to re-run. Homebrew is installed if missing, into /opt/homebrew on
# Apple Silicon and /usr/local on Intel.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=user_specific/common_tools.sh
. "${SCRIPT_DIR}/common_tools.sh"
# shellcheck source=user_specific/os.sh
. "${SCRIPT_DIR}/os.sh"

if [ "${DOTFILES_FAMILY}" != "darwin" ]; then
    error_log "[-] This script is for macOS. Detected: ${DOTFILES_OS}"
    exit 1
fi

# Homebrew formulae. Mostly the Manjaro list, minus anything X11-only.
brew_formulae=(
    'git'
    'zsh'
    'curl'
    'httpie'
    'neovim'
    'tmux'
    'tmuxinator'
    'ranger'
    'vifm'
    'tree'
    'jq'
    'ripgrep'
    'ripgrep-all'
    'fd'
    'bat'
    'git-delta'
    'the_silver_searcher'
    'universal-ctags'
    'cmake'
    'automake'
    'llvm'              # clang, clang-format, clangd
    'go'
    'gopls'
    'node'
    'npm'
    'python@3.12'
    'shellcheck'
    'htop'
    'nmap'
    'mpv'
    'w3m'
    'sdcv'
    'newsboat'
    'task'              # taskwarrior
    'cloc'
    'doxygen'
    'plantuml'
    'typescript-language-server'
    'coreutils'         # GNU tools, so the shared scripts behave like on Linux
    'gnu-sed'
    'gnu-tar'
    'make'
)

brew_casks=(
    'alacritty'
    'font-hack-nerd-font'
    'font-caskaydia-cove-nerd-font'
)

npm_packages=(
    'aws-cdk'
)

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        debug_log "[+] Homebrew already installed"
        return
    fi
    debug_log "[+] Installing Homebrew ..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_xcode_clt() {
    if xcode-select -p >/dev/null 2>&1; then
        debug_log "[+] Xcode command line tools already installed"
        return
    fi
    debug_log "[+] Installing Xcode command line tools ..."
    xcode-select --install || true
    # xcode-select --install is asynchronous; wait for it to finish.
    until xcode-select -p >/dev/null 2>&1; do sleep 10; done
}

install_xcode_clt
install_homebrew

# Make brew available in this shell even on a fresh install.
if prefix="$(brew_prefix)"; then
    eval "$("${prefix}/bin/brew" shellenv)"
else
    error_log "[-] Homebrew is not on PATH; aborting"
    exit 1
fi

debug_log "[+] Updating Homebrew ..."
brew update

for formula in "${brew_formulae[@]}"; do
    if brew list --formula "${formula}" >/dev/null 2>&1; then
        debug_log "[+] ${formula} already installed"
    else
        debug_log "[+] Installing ${formula} ..."
        brew install "${formula}" || error_log "[-] Failed to install ${formula}"
    fi
done

for cask in "${brew_casks[@]}"; do
    if brew list --cask "${cask}" >/dev/null 2>&1; then
        debug_log "[+] ${cask} already installed"
    else
        debug_log "[+] Installing ${cask} ..."
        brew install --cask "${cask}" || error_log "[-] Failed to install ${cask}"
    fi
done

for pkg in "${npm_packages[@]}"; do
    if npm list -g --depth 0 "${pkg}" >/dev/null 2>&1; then
        debug_log "[+] ${pkg} already installed"
    else
        debug_log "[+] Installing ${pkg} ..."
        npm install -g "${pkg}" || error_log "[-] Failed to install ${pkg}"
    fi
done

run_common_bootstrap

debug_log "[+] macOS setup complete. Run './install' to link the configs."
