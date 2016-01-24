#!/bash/bash

#TO-DO: check user permission is it root ?

sudo apt-get update

# install git
sudo apt-get install build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip
sudo apt-get install git gitk cmake

# install xubuntu
sudo apt-get install xubuntu-desktop

# install development tools
sudo apt-get install meld
sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer

# install terminal-emulator
sudo apt-get install terminator
sudo apt-get install tmux
sudo apt-get install guake
sudo apt-get install yakuake

# install ruby
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev \
libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
libcurl4-openssl-dev python-software-properties libffi-dev

# install virtual-box
sudo apt-get install virtualbox

# install oracle-jdk
# ref: http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

# automated installation
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 \ 
select true | sudo /usr/bin/debconf-set-selections

# setting java environment variables
sudo apt-get install oracle-java8-set-default
sudo su
echo JAVA_HOME=/usr/lib/jvm/java-8-oracle/ >> /etc/environment
echo "export JAVA_HOME" >> /etc/environment
. /etc/environment
exit

