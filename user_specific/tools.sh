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


# global variable definitions
apttools=(
'git-core'
'zsh'
'curl'
'httpie'
'cmus'
'vifm'
'dnstop'
'vnstat'
'iftop'
'atop'
'tree'
'clang-format'
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
)

repos=(
'ppa:neovim-ppa/stable'
'ppa:jasonpleau/rofi'
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
)

# functions
function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
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
		pip3 install --upgrade "$tool"
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
else
	error_log "[-] You need to install Vim first! "
fi

# clone tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
"
#sudo update-alternatives --config x-terminal-emulator

# add source files to end of rc file
#[ -f ~/.zshrc ] && echo "$SOURCE_STR" >> ~/.zshrc

