#!/usr/bin/env bash

# If not running interactively, don't do anything
# this line has to be placed at this front-pos,
# otherwise the rsync will not work
case "$-" in
    *i*) ;;
    *) return;; # exit also causing the scp command malfunction
esac

#
export MY_BIN="$HOME/bin" # 1. executable 2. does not concerns privacy
export MY_DOTFILES="$HOME/.dotfiles"
export MY_LOG_DIR="$MY_DOTFILES/log"
export MY_BUNDLED_BIN="$MY_DOTFILES/bin" # 1. executable/does not concerns privacy 2. built-in for this setup
export MY_SH="$MY_DOTFILES/sh"
export MY_SH_MODULE="$MY_SH/module"
export MY_DOTFILES_RESOURCES="$HOME/.dotfiles_resources"
export MY_PRIVATE_BIN="$MY_DOTFILES_RESOURCES/bin" # 1. executable 2. concerns privacy 3. will be deleted in cleanup-process.

if [[ ! -d "$MY_BIN" ]];then
    mkdir -p "$MY_BIN"
fi

if [[ ! -d "$MY_DOTFILES_RESOURCES" ]];then
    mkdir -p "$MY_DOTFILES_RESOURCES"
fi

if [[ ! -d "$MY_PRIVATE_BIN" ]];then
    mkdir -p "$MY_PRIVATE_BIN"
fi

# unset to avoid issue caused by repeatly sourcing .bashrc
unset PROMPT_COMMAND

export PATH="$MY_BUNDLED_BIN:$PATH"

# bash boolean support
_true() {
    [[ "true" =~ "true" ]]
}

_false() {
    ! _true
}

_set_true() {
    declare -g -n ref="${1}"

    local -r hook="_true"
    local -r function_body="$(declare -f $hook)"
    local -r definition="${!ref} ${function_body#$hook}"
    eval "$definition"
}

_set_false() {
    declare -g -n ref="${1}"

    local -r hook="_false"
    local -r function_body="$(declare -f $hook)"
    local -r definition="${!ref} ${function_body#$hook}"
    eval "$definition"
}

_is_command_exist() {
    [[ "$#" -eq 1 ]] && command -v "$1" > /dev/null
}

declare -fx _is_command_exist

# format is : command1|command1_alternative1|command1_alternative2|...;command2;...;commandX
# must end with ';'
prerequisite_commands='awk|gawk|;cut|gcut|;python|python2|python3|;sed|gsed|;'

while read -d ';' item;do
    _set_false 'command_exist'
    while read -d '|' cmd; do
        if _is_command_exist "$cmd";then
            _set_true 'command_exist'
            break
        fi
    done< <(echo ${item})
    if ! command_exist;then
        echo "$item: command not exist"
        return 1
    fi
done< <(echo ${prerequisite_commands})

# http://mivok.net/2009/09/20/bashfunctionoverrist.html
_overrideFunction() {
    local -r functionBody=$(declare -f $1)
    local -r newDefinition="${1}_super ${functionBody#$1}"
    eval "$newDefinition"
}

# https://stackoverflow.com/questions/5431909/bash-functions-return-boolean-to-be-used-in-if
_is_shell_variable_setted() {
    [[ "$#" -eq 1 ]] && [[ -v "$1" ]]
}

_is_darwin() {
    [[ "$#" -eq 0 ]] && [[ "$(uname -s)" =~ "Darwin" ]]
}

_is_linux() {
    [[ "$#" -eq 0 ]] && [[ "$(uname -s)" =~ "Linux" ]]
}

_is_mingw32_nt() {
    [[ "$#" -eq 0 ]] && [[ "$(uname -s)" =~ "MINGW32_NT" ]]
}

_getent_wrapper() {
    if _is_darwin;then
        _getent "$@"
    else
        getent "$@"
    fi
}

_expand_path() {
    # https://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash
    local path
    local -a pathElements resultPathElements
    IFS=':' read -r -a pathElements <<<"$1"
    : "${pathElements[@]}"
    for path in "${pathElements[@]}"; do
        : "$path"
        case $path in
            "~+"/*)
                path=$PWD/${path#"~+/"}
                ;;
            "~-"/*)
                path=$OLDPWD/${path#"~-/"}
                ;;
            "~"/*)
                path=$HOME/${path#"~/"}
                ;;
            "~"*)
                username=${path%%/*}
                username=${username#"~"}
                homedir=$(_getent_wrapper passwd "${username}" | cut -d : -f6)
                if [[ $path = */* ]]; then
                    path=${homedir}/${path#*/}
                else
                    path=$homedir
                fi
                ;;
        esac
        resultPathElements+=( "$path" )
    done
    local result
    printf -v result '%s:' "${resultPathElements[@]}"
    printf '%s\n' "${result%:}"
}

# https://docstore.mik.ua/orelly/unix3/upt/ch29_13.htm
# export function to subshell
declare -fx _expand_path

_is_dir_exist() {
    # here we use _expand_path to avoid the case: "$1" contains '~' and cannot do tilde-expansion correctly because of the use of single-quote or double-quote
    [[ "$#" -eq 1 ]] && [[ -d "$(_expand_path ${1})" ]]
}
declare -fx _is_dir_exist

_is_file_exist() {
    [[ "$#" -eq 1 ]] && [[ -e "$(_expand_path ${1})" ]]
}
declare -fx _is_file_exist

_is_root() {
    [[ "$#" -eq 0 ]] && [[ "$(id -u)" -ne 0 ]]
}
declare -fx _is_root

_is_not_root() {
    [[ "$#" -eq 0 ]] && [[ "$(whoami)" != root ]]
}
declare -fx _is_not_root

_is_termux() {
    _is_linux && [[ "$HOME" =~ "com.termux/files/home" ]]
}

if ! _is_shell_variable_setted 'MY_CURRENT_SHELL';then
    echo "missing bash variable: MY_CURRENT_SHELL, valid value are \'bash\' or \'zsh\'"
    return 1
fi

_is_bash() {
    [[ "$MY_CURRENT_SHELL" =~ 'bash' ]]
}

_is_zsh() {
    [[ "$MY_CURRENT_SHELL" =~ 'zsh' ]]
}

if _is_darwin;then
    ulimit -S -n 1024
    if _is_file_exist '/opt/local/bin/port';then
        export MY_CURRENT_PACKAGE_MANAGER='macports'
    elif _is_file_exist '/usr/local/bin/brew';then
        export MY_CURRENT_PACKAGE_MANAGER='homebrew'
    else
        unset MY_CURRENT_PACKAGE_MANAGER
    fi
else
    unset MY_CURRENT_PACKAGE_MANAGER
fi

if _is_file_exist "$HOME/.dotfiles/sh/init.bash";then
    source "$HOME/.dotfiles/sh/init.bash"
fi
