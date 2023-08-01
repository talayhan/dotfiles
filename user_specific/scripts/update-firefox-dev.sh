#!/usr/bin/env bash

#Ref: https://linux.how2shout.com/how-to-install-firefox-developer-edition-on-ubuntu-22-04-or-20-04/#6_Create_an_Application_shortcut

set -x
cd /tmp

wget "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" -O Firefox-dev.tar.bz2

sudo tar xjf  Firefox-dev.tar.bz2 -C /opt/

rm -r Firefox-dev.tar.bz2
set +x
