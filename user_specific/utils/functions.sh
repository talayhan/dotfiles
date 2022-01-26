#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function debug_log() {
	echo -e "${GREEN}${1}${NC}"
}

function error_log() {
	echo -e "${RED}${1}${NC}"
}
