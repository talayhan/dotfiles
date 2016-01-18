#!/bin/bash

# Declare global variable
GEN_SSH_KEY=false

usage() {
  echo "
Usage

  gitset -s <user.name> -e <user.email> -g -h

SYNOPSIS
  s - Specify a git user.name
  e - Specify a git user.email
  g - Generate a new SSH key for authentication with Github
  h - Print this help message
"
}

setup_complete() {
  echo
  echo "*** gitset is now set up! ***"
}

generate_ssh_key(){
  ssh-keygen -t rsa -b 4096 -C $GIT_USER_EMAIL
}

# if less than two arguments supplied, display usage 
if [  $# -lt 4 ] 
then 
  usage
  exit 1
fi 

while getopts ":s:e:gh" opt; do
  case $opt in
    s)
      GIT_USER_NAME=$OPTARG
      ;;
    e)
      GIT_USER_EMAIL=$OPTARG
      ;;
    g)
      GEN_SSH_KEY=true
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo "------- Starting Gitset --------"
git config --global color.ui true
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL
if [[ $GEN_SSH_KEY ]]; then
  echo "[+]Generating SSH key ..."
  generate_ssh_key
fi
echo "[+]Github username: $GIT_USER_NAME"
echo "[+]Github userpass: $GIT_USER_EMAIL"
echo "------------- Done -------------"

setup_complete
