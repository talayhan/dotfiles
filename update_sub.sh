#!/bin/bash
git submodule foreach git pull origin master
git submodule update --recursive
