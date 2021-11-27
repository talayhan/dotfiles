#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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
'minicom'
'tftpd-hpa'
'tftp-hpa'
'rdesktop'
'jq'				# JSON processor
'tidy'				# pretty-print HTML files
'rofi'
'python3-pip'
'python3-venv'
'tmux'
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
'byzanz'			# Making a GIF screencast
'rainbowstream'			# twitter cli
'automake'
'pcmanfm'			# light file manager
'wavemon'			# detailed network monitoring tool
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
)

#sudo apt-get install pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev

repos=(
'ppa:neovim-ppa/unstable'
'ppa:mc3man/mpv-tests'
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
#'pycparser'
)

# functions
function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
}

# https://packages.azlux.fr/
# * broot
# * bashtop
# * dog
function add_azlux_repo() {
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
}

function add_node14_repo() {
	curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
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

# needed for Node.js 14 installation
add_node14_repo

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

if [[ ! -e ~/.fzf ]]; then
	debug_log "[+] Installing fzf ... "
	git clone --depth 1 \
	https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	debug_log "[+] Done "
fi


if [[ ! -e ~/.oh-my-zsh ]]; then
	debug_log "[+] Installing oh-my-zsh ... "
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	debug_log "[+] Done "
fi

if [[ ! -e ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
	debug_log "[+] Installing zsh-autosuggestions ... "
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	debug_log "[+] Done "
fi

#git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# install vim plugin manager
if [[ ! -e ~/.local/share/nvim/site/autoload/plug.vim ]]; then
	debug_log "[+] Installing vim plugin manager ... "
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	debug_log "[+] Done "
else
	error_log "[-] You need to install Vim first! "
fi

# install custom rofi based launchers
if [[ ! -e ~/.config/rofi/launchers ]]; then
	debug_log "[+] Installing custom rofi launchers ... "
	git clone --depth=1 https://github.com/adi1090x/rofi.git
	chmod +x rofi/setup.sh
	./rofi/setup.sh
	debug_log "[+] Done "
fi

# clone tpm
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	# source tmux conf
	tmux source ~/.tmux.conf

	# install tmux plugins
	~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
"

#make alacritty default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which alacritty) 50

#set python3 as default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

nvim +'PlugInstall --sync' +qa

# add source files to end of rc file
#[ -f ~/.zshrc ] && echo "$SOURCE_STR" >> ~/.zshrc

