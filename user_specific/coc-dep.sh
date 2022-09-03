#!/usr/bin/env bash

set -x

deps=(
"coc-clangd"
"coc-format-json"
"coc-json"
"coc-snippets"
"coc-spell-checker"
"coc-tsserver"
"coc-pyright"
"coc-html"
"coc-css"
#"coc-jedi"
#"coc-eslint"
#"coc-stylelint"
#"coc-vetur"
)

for dep in "${deps[@]}"; do
    nvim +"CocInstall -sync ${dep}" +qall
done

nvim +CocUpdateSync +qall
