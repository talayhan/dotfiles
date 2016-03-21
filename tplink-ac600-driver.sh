#!/bin/bash

# install Tp-Link AC-600 - Wireless Adapter driver for x64 debian systems
# >= gcc 4.9.2 
# >= kernel 3.16.0.57-generic
#
# Ref: http://salmorejogeek.com/2015/08/18/tp-link-ac600-archer-t2uh-funcionando-en-linux-impossible-is-nothing/


mkdir ~/src
cd ~/src
git clone https://github.com/Myria-de/mt7610u_wifi_sta_v3002_dpo_20130916.git
cd mt7610u_wifi_sta_v3002_dpo_20130916
make clean
make
sudo make install