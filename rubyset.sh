#!/bin/bash

#
# Install Ruby on Ubuntu 14.04 
# Reference: https://gorails.com/setup/ubuntu/14.04
#

# Update system and install dependencies
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev \
libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
libcurl4-openssl-dev python-software-properties libffi-dev

# Installing with rbenv is a simple two step process. First you install rbenv, and then ruby-build:
cd
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

# Install ruby-build
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

rbenv install 2.2.3
rbenv global 2.2.3
ruby -v

# Now we tell Rubygems not to install the documentation for each package locally and then install Bundler

echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler
