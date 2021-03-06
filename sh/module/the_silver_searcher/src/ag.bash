#! /usr/bin/env bash

_ag_init() {
    if [[ ! -d "$MY_DOTFILES_RESOURCES/the_silver_searcher" ]];then
        git clone --depth 1 https://github.com/ggreer/the_silver_searcher "$MY_DOTFILES_RESOURCES/the_silver_searcher"
    fi
} 

export PATH="$MY_DOTFILES_RESOURCES/the_silver_searcher:$PATH"

alias ag='ag -p "$MY_SH_MODULE/the_silver_searcher/script/.ignore"'

# completion
[[ -f "$MY_DOTFILES_RESOURCES/the_silver_searcher/ag.bashcomp.sh" ]] && source "$MY_DOTFILES_RESOURCES/the_silver_searcher/ag.bashcomp.sh"
