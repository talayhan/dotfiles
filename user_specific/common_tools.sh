#!/usr/bin/env bash
#
# Platform-independent part of the tooling setup: oh-my-zsh and its plugins,
# tpm, fzf, rustup, vim-plug and the nvim plugin/treesitter bootstrap.
#
# Sourced by user_specific/{ubuntu,manjaro,macos}_tools.sh after that script has
# installed the platform's native packages. Everything here is idempotent.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

debug_log() { echo -e "${GREEN}${1}${NC}"; }
error_log() { echo -e "${RED}${1}${NC}"; }

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        debug_log "[+] oh-my-zsh already installed"
        return
    fi
    debug_log "[+] Installing oh-my-zsh ..."
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# clone_plugin <destination> <repo-url>
clone_plugin() {
    local dest="${1}" url="${2}"
    if [ -d "${dest}" ]; then
        debug_log "[+] $(basename "${dest}") already installed"
        return
    fi
    debug_log "[+] Installing $(basename "${dest}") ..."
    git clone --depth 1 "${url}" "${dest}"
}

install_zsh_plugins() {
    clone_plugin "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" \
        https://github.com/zsh-users/zsh-autosuggestions
    clone_plugin "${ZSH_CUSTOM}/plugins/zsh-nvm" \
        https://github.com/lukechilds/zsh-nvm
    clone_plugin "${ZSH_CUSTOM}/plugins/zsh-fzf-history-search" \
        https://github.com/joshskidmore/zsh-fzf-history-search
}

install_tpm() {
    clone_plugin "$HOME/.tmux/plugins/tpm" https://github.com/tmux-plugins/tpm
}

install_fzf() {
    if [ -d "$HOME/.fzf" ]; then
        debug_log "[+] fzf already installed"
        return
    fi
    debug_log "[+] Installing fzf ..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
}

install_rustup() {
    if command -v rustc >/dev/null 2>&1; then
        debug_log "[+] rust already installed"
        return
    fi
    debug_log "[+] Installing rustup ..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_vim_plug() {
    local plug="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    if [ -f "${plug}" ]; then
        debug_log "[+] vim-plug already installed"
        return
    fi
    debug_log "[+] Installing vim-plug ..."
    curl -fLo "${plug}" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

bootstrap_nvim() {
    if ! command -v nvim >/dev/null 2>&1; then
        error_log "[-] nvim not found, skipping plugin bootstrap"
        return
    fi
    debug_log "[+] Bootstrapping nvim plugins ..."
    nvim --headless +'PlugInstall --sync' +qa
    nvim --headless +'TSInstall c cpp java python rust vim go html css javascript typescript' +qa
    nvim --headless +'TSInstall cmake make bash json toml yaml latex regex markdown proto http dockerfile' +qa
    nvim --headless +'TSUpdate' +qa
}

run_common_bootstrap() {
    install_oh_my_zsh
    install_zsh_plugins
    install_tpm
    install_fzf
    install_rustup
    install_vim_plug
    bootstrap_nvim
    debug_log "[+] Common bootstrap complete"
}
