#!/bin/bash

#Program Name                 | Little description if necessary  |
#URL                          | stalayhan.github.io              |
#---------------------------- | --------------------------------
#Total number of program      | 9                                |

if [ $(id -u) -ne 0 ]; then exec sudo $0; fi

#Httpie                       | HTTP Client                                   |
#URL                          | https://github.com/jakubroztocil/httpie#linux |
#---------------------------- | --------------------------------
if [[ ! $(which http) ]]; then
	apt-get install httpie
fi

#Cmus                         | Command line music player        |
#URL                          | https://github.com/cmus/cmus     |
#---------------------------- | --------------------------------
if [[ ! $(which cmus) ]]; then
	apt-get install cmus
fi

#Grip                         | Preview markdown files           |
#URL                          | https://github.com/joeyespo/grip |
#---------------------------- | --------------------------------
if [[ ! $(which grip) ]]; then
	pip install --upgrade grip
fi

#fzf                          | fuzzy finder                     |
#URL                          | https://github.com/junegunn/fzf  |
#---------------------------- | --------------------------------
if [[ ! -e ~/.fzf ]]; then
	git clone --depth 1 \
	https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi

#vifm                         | vim like file manager            |
#URL                          | https://github.com/vifm/vifm     |
#---------------------------- | --------------------------------
if [[ ! $(which vifm) ]]; then
	apt-get install vifm
fi

#dnstop                       | display various tables of dns traffic            |
#URL                          | http://dns.measurement-factory.com/tools/dnstop/ |
#---------------------------- | --------------------------------
if [[ ! $(which dnstop) ]]; then
	apt-get install dnstop
fi

#vnstat                       | console-based network traffic monitor tool |
#URL                          | http://humdi.net/vnstat/                   |
#---------------------------- | --------------------------------
if [[ ! $(which vnstat) ]]; then
	apt-get install vnstat
fi

#iftop                        | display bandwidth usage on an interface |
#URL                          | http://www.ex-parrot.com/pdw/iftop/     |
#---------------------------- | --------------------------------
if [[ ! $(which dnstop) ]]; then
	apt-get install iftop
fi

#atop                         | atop is a top                    |
#URL                          | https://www.atoptool.nl/         |
#---------------------------- | --------------------------------
if [[ ! $(which atop) ]]; then
	apt-get install atop
fi
