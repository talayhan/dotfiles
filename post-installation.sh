#!/bash/bash

#TO-DO: check user permission is it root ?

sudo apt-get update

# install git
sudo apt-get install build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip
sudo apt-get install git gitk

# install xubuntu
sudo apt-get install xubuntu-desktop

# install development tools
sudo apt-get install meld
sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer

# install ruby
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev 
libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
