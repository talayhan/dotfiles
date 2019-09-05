#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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
'xclip'
'xsel'
'net-tools'
'nicstat'
'mpv'
'pavucontrol'
)

repos=(
'ppa:neovim-ppa/stable'
'ppa:jasonpleau/rofi'
'ppa:mc3man/mpv-tests'
)

piptools=(
'grip'
'neovim'
)

# functions
function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
}

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

if ! [[ -x "$(command -v diff-so-fancy)" ]]; then
	echo "[+] Installing diff-so-fancy ... "
	wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
	chmod +x diff-so-fancy
	sudo mv diff-so-fancy /usr/local/sbin
	echo  "[+] Done "
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
if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
	debug_log "[+] Installing vim plugin manager ... "
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	debug_log "[+] Done "
else
	error_log "[-] You need to install Vim first! "
fi

# install rust
#curl https://sh.rustup.rs -sSf | sh
#cargo install fd-find
#cargo install ripgrep

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.local/bin/bashmarks ] && source ~/.local/bin/bashmarks
"
#sudo update-alternatives --config x-terminal-emulator

# add source files to end of rc file
#[ -f ~/.zshrc ] && echo "$SOURCE_STR" >> ~/.zshrc

