#!/bin/bash

# Install ruby if there is no
./rubyset.sh

# Install ExecJS
gem install execjs

# Setup Octopress
git clone git://github.com/imathis/octopress.git octopress
cd octopress

# Install dependencies
gem install bundler
rbenv rehash    # If you use rbenv, rehash to be able to run the bundle command
bundle install

# Install default octopress theme
rake install
