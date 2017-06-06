#!/bin/bash

if [ $(id -u) -ne 0 ]; then exec sudo $0; fi

tools=(
'httpie'
'cmus'
'vifm'
'dnstop'
'vnstat'
'iftop'
'atop'
'clang-format'
'sbcl'
)

if [[ ! $(which grip) ]]; then
	pip install --upgrade grip
fi

if [[ ! -e ~/.fzf ]]; then
	git clone --depth 1 \
	https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi

for tool in "${tools[@]}" ; do
	if [[ ! $(which $tool) ]]; then
		apt-get install $tool
	fi
done
