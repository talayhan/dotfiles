#!/usr/bin/env bash

set -x

deps=(
"coc-clangd"
"coc-format-json"
"coc-json"
"coc-snippets"
"coc-spell-checker"
"coc-tsserver"
)

for dep in "${deps[@]}"; do
    nvim +"CocInstall -sync ${dep}" +qall
done

nvim +CocUpdateSync +qall
