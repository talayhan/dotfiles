#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

## @TODO add below packages
# - scan-build-9
# - Install rust/cargo - curl https://sh.rustup.rs -sSf | sh

# global variable definitions
pactools=(
'zsh'
'curl'
'httpie'
'cmus'
'vifm'
'vnstat'
'iftop'
'atop'
'tree'
'clang'
'sbcl'
'neovim'
'python-pynvim'
'python-pip'
'minicom'
'tftp-hpa'
'rdesktop'
'jq'				# JSON processor
'tidy'				# pretty-print HTML files
'rofi'
'tmux'
'redshift'
'unclutter'
'compton'
'zathura'
'feh'
'scrot'
'w3m'
'xclip'
'xsel'
'net-tools'
'mpv'
'pavucontrol'
'nmap'
'cmake'
'wireshark'
'patchelf'
'shellcheck'
'byzanz'			# Making a GIF screencast
'automake'
'pcmanfm'			# light file manager
'ripgrep'
'fd'
)

piptools=(
'grip'
'ptpython'
'sniffer'
'pyinotify'
'vim-vint'
'msgpack'
)

# functions
function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
}

sudo pacman -Syu

for tool in "${pactools[@]}" ; do
	if [[ ! $(which "$tool") ]]; then
		debug_log "[+] Installing ${tool} ... "
		sudo pacman -S "$tool"
		debug_log "[+] Done "
	fi
done

for tool in "${piptools[@]}" ; do
	if [[ ! $(which "$tool") ]]; then
		debug_log "[+] Installing ${tool} ... "
		pip install --user --upgrade "$tool"
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

# install vim plugin manager
if [[ ! -e ~/.local/share/nvim/site/autoload/plug.vim ]]; then
	debug_log "[+] Installing vim plugin manager ... "
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	debug_log "[+] Done "
fi

# clone tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
"

