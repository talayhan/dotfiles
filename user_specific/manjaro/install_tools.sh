#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# functions
function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
}

tools=(
    '(pulseaudio, pulseaudio)'
    '(pavucontrol, pavucontrol)'
    '(tilda, tilda)'
    '(zsh, zsh)'
    '(neovim, nvim)'
    '(neovim-lspconfig, nvim)'
    '(python-pynvim, nvim)'
    '(nvm, nvm)'
    '(ripgrep-all, rg)'
    '(git-delta, delta)'
);

if [ ! -d "$HOME/.oh-my-zsh/" ]; then
    debug_log "[+] Oh-my-zsh installing ..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    debug_log "[+] done"
else
    debug_log "[+] Oh-my-zsh has already installed!";
fi

if [[ ! $(which rustc) ]]; then
    debug_log "[+] Installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup-init
    chmod +x rustup-init
    ./rustup-init -y
    rm rustup-init
    debug_log "[+] done"
fi

for tool in "${tools[@]}"; do
    eval "read -r a b <<< '$tool'"
    length=${#b}
    stripped=$(echo "${b:0:$((length-1))}")
    if [[ ! $(which "$stripped") ]]; then
        debug_log "[+] Installing ${stripped} ..."
        sudo pacman -S "$stripped"
        debug_log "[+] done "
    else
        debug_log "[+] ${stripped} is already available!"
    fi
done

#clone plugins
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-nvm" ]; then
    git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
fi
