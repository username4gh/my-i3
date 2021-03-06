#! /usr/bin/env bash

# exec module's function with special name
_snfunction_on_module_level() {
    method="_$(_file_name_noext $2)$1"

    echo "$method"

    if _is_command_exist "$method" ;then
        if [[ "$3" == 'execute' ]];then
            echo "  calling $method"
            "$method"
        fi
    fi
}

_snfunction_on_modules_level() {
    while IFS= read -r item;
    do
        echo "[module: $(_dir_basename $item)]"
        if [[ "$2" == 'execute' ]];then
            _snfunction_on_module_level $1 "$(_dir_basename $item)" execute
        else
            _snfunction_on_module_level $1 "$(_dir_basename $item)"
        fi
    done < <(_pythonfind --root-dir "$MY_SH/module" --mindepth 1 --maxdepth 1 --type d)
}

_snfunction_complete () {
    if _is_bash;then
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local completion_args="init list"
        COMPREPLY=( $(compgen -W "${completion_args}" -- ${cur}) )
    fi
}
