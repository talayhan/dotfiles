#!/usr/bin/env bash
#
# Ubuntu / Debian tooling setup.
#
#   ./user_specific/ubuntu_tools.sh
#
# Safe to re-run.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=user_specific/common_tools.sh
. "${SCRIPT_DIR}/common_tools.sh"

## @TODO add below packages
# - scan-build-9
# - clang-9 clang-format-9 clang-tidy-9 clangd-9 clang-tools-9
# - Install rust/cargo - curl https://sh.rustup.rs -sSf | sh
#   - exas
#   - fd-find
#   - ripgrep
# - Install some packages from snap

# global variable definitions
apttools=(
'git-core'
'zsh'
'curl'
'httpie'
'ranger'
'dnstop'
'vnstat'
'iftop'
'atop'
'tree'
'clang-format'
'clangd'
'sbcl'
'neovim'
'silversearcher-ag'
'rxvt-unicode-256color'
'exuberant-ctags'
'universal-ctags'   # for rust-tagbar compatibility
'minicom'
'tftpd-hpa'
'tftp-hpa'
'rdesktop'
'jq'                # JSON processor
'tidy'              # pretty-print HTML files
'rofi'
'python3-pip'
'python3-venv'
'tmux'
'tmuxinator'            # A session manager for tmux
'i3'
'redshift'
'unclutter'
'compton'
'zathura'
'feh'
'scrot'
'w3m'
'taskwarrior'
'xclip'
'xsel'
'net-tools'
'nicstat'
'mpv'
'pavucontrol'
'nmap'
'build-essential'
'cmake'
'wireshark'
'openssh-server'
'patchelf'
'shellcheck'
'byzanz'            # Making a GIF screencast
'rainbowstream'         # twitter cli
'automake'
'pcmanfm'           # light file manager
'wavemon'           # detailed network monitoring tool
'nodejs'
'npm'
'mpg123'
'broot'
'bashtop'
'htop'
'dog'
'arandr'
'ripgrep'
'fd-find'
'cloc'
'doxygen'
'sdcv'
'bat'
'newsboat'          # text mode rss reader
'remind'            # calendar and alarm program
'thunar'
'numix-icon-theme-circle'
'plantuml'
'fonts-hack'
'fonts-cascadia-code'
)

#sudo apt-get install pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev

repos=(
'ppa:git-core/ppa'
'ppa:neovim-ppa/unstable'
'ppa:mc3man/mpv-tests'
'ppa:numix/ppa'
)

piptools=(
'grip'
'neovim'
'pynvim'
'ptpython'
'sniffer'
'pyinotify'
'vim-vint'
'requests'
'netifaces'
'python-language-server[all]'
'yamllint'
'gpt-command-line' #check config under ~/.config/gpt-cli
#'pycparser'
)

# https://packages.azlux.fr/
# * broot
# * bashtop
# * dog
function add_azlux_repo() {
    echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
    wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
}

function add_node19_repo() {
    curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
}

sudo apt update

for repo in "${repos[@]}" ; do
    find_string=$(echo ${repo} | cut -d ':' -f 2 | cut -d '/' -f 1)
    if [[ ! $(ls "/etc/apt/sources.list.d/" | grep ${find_string}) ]]; then
        debug_log "[+] Add repository ${repo} ... "
        sudo add-apt-repository "$repo"
        debug_log "[+] Done "
    fi
done

# needed for Node.js 19 installation
#add_node19_repo

sudo apt update

for tool in "${apttools[@]}" ; do
    if [[ ! $(which "$tool") ]]; then
        debug_log "[+] Installing ${tool} ... "
        sudo apt-get install "$tool"
        debug_log "[+] Done "
    fi
done

for tool in "${piptools[@]}" ; do
    if [[ ! $(which "$tool") ]]; then
        debug_log "[+] Installing ${tool} ... "
        pip3 install --user --upgrade "$tool"
        debug_log "[+] Done "
    fi
done

# oh-my-zsh, zsh plugins, tpm, fzf, rustup, vim-plug and the nvim bootstrap are
# shared with the other platforms.
run_common_bootstrap

# install custom rofi based launchers
if [[ ! -e ~/.config/rofi/launchers ]]; then
    debug_log "[+] Installing custom rofi launchers ... "
    git clone --depth=1 https://github.com/adi1090x/rofi.git
    chmod +x rofi/setup.sh
    ./rofi/setup.sh
    debug_log "[+] Done "
fi

#make alacritty default terminal
if command -v alacritty >/dev/null 2>&1; then
    sudo update-alternatives --install /usr/bin/x-terminal-emulator \
        x-terminal-emulator "$(which alacritty)" 50
fi

#set python3 as default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

xdg-mime default thunar.desktop inode/directory

#query default file manager
#xdg-mime query default inode/directory

debug_log "[+] Ubuntu setup complete. Run './install' to link the configs."

