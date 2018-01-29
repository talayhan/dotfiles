#!/bin/bash

if [ $(id -u) -ne 0 ]; then exec sudo "$0"; fi

tools=(
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
'silversearcher-ag'
'rxvt-unicode-256color'
)

for tool in "${tools[@]}" ; do
	if [[ ! $(which "$tool") ]]; then
		apt-get install "$tool"
	fi
done

if [[ ! $(which grip) ]]; then
	pip install --upgrade grip
fi

if [[ ! -e ~/.fzf ]]; then
	git clone --depth 1 \
	https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi

if [[ ! -e ~/.oh-my-zsh ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

SOURCE_STR="
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_functions ] && source ~/.bash_functions
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.local/bin/bashmarks ] && source ~/.local/bin/bashmarks
"

# add source files to end of rc file
[ -f ~/.zshrc ] && echo "$SOURCE_STR" >> ~/.zshrc

