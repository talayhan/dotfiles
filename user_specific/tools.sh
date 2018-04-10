#!/bin/bash

# check user power
if [ $(id -u) -ne 0 ]; then exec sudo "$0"; fi

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
'clang-format'
'sbcl'
'neovim'
'silversearcher-ag'
'rxvt-unicode-256color'
)

repos=(
'ppa:neovim-ppa/stable'
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
	debug_log "[+] Add repository ${repo} ... "
	add-apt-repository "$repo"
	debug_log "[+] Done "
done

for tool in "${apttools[@]}" ; do
	debug_log "[+] Installing ${tool} ... "
	if [[ ! $(which "$tool") ]]; then
		apt-get install "$tool"
	fi
	debug_log "[+] Done "
done

for tool in "${piptools[@]}" ; do
	debug_log "[+] Installing ${tool} ... "
	if [[ ! $(which "$tool") ]]; then
		pip3 install --upgrade "$tool"
	fi
	debug_log "[+] Done "
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
	mv diff-so-fancy /usr/local/sbin
	echo  "[+] Done "
fi

if [[ ! -e ~/.oh-my-zsh ]]; then
	debug_log "[+] Installing oh-my-zsh ... "
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	debug_log "[+] Done "
fi

# install vim plugin manager
if [[ -e ~/.vim && ! -e ~/.vim/plugged ]]; then
	debug_log "[+] Installing vim plugin manager ... "
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	debug_log "[+] Done "
else
	debug_error "[-] You need to install Vim first! "
fi

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.local/bin/bashmarks ] && source ~/.local/bin/bashmarks
"

# add source files to end of rc file
[ -f ~/.zshrc ] && echo "$SOURCE_STR" >> ~/.zshrc

