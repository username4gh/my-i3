#! /usr/bin/env bash

export MY_SH_COMPLETIONS="$MY_I3/completions"

_completion_read() {
    if [[ "$MY_CURRENT_SHELL" == 'bash' ]];then
        # $1 --> variant name
        if [[ "$#" -eq 1 ]];then
            if [[ -f "$MY_SH_COMPLETIONS/$1.completion" ]];then
                cat "$MY_SH_COMPLETIONS/$1.completion"
            fi
        else
            echo "Usage: _completion_read completion_file_name"
        fi
    fi
}

_completion_write() {
    if [[ "$MY_CURRENT_SHELL" == 'bash' ]];then
        # $1 --> variant name
        # $2 --> variant value
        if [[ ! -d "$MY_SH_COMPLETIONS" ]];then
            mkdir -p "$MY_SH_COMPLETIONS"
        fi

        if [[ "$#" -gt 1 ]];then
            local size=$#
            local max_index=$((size-1))
            local args=($@)

            local name
            for ((i = 0; i < max_index; i++))
            do
                if [[ $i -eq $((size-2)) ]];then
                    name+=${args[$i]}
                else
                    name+=${args[$i]}_
                fi
            done

            if [[ -f "$MY_SH_COMPLETIONS/$name.completion" ]];then
                # delete old record, we need the gnu sed to achieve it
                sed -e "/${args[$max_index]}/d" -i.tmp "$MY_SH_COMPLETIONS/$name.completion"
            fi

            echo "${args[$max_index]}" >> "$MY_SH_COMPLETIONS/$name.completion"
        else
            echo "Usage: _completion_write parent child grandchild"
        fi
    fi
}

_completion_generate() {
    if [[ "$MY_CURRENT_SHELL" == 'bash' ]];then
        # $1 target command
        # $2 directory
        # $3 pattern to match certain file
        while IFS= read -r item
        do
            _completion_write $1 $(basename $item | cut -d '.' -f1)
        done < <(find "$2" -maxdepth 1 -type f | s "$3")
    fi
}

_completion_register_write(){
    return
}

_completion_register_generate() {
    return
}

_completion_complete () {
    if [[ "$MY_CURRENT_SHELL" == 'bash' ]];then
        local cur="${COMP_WORDS[COMP_CWORD]}"

        local size=$COMP_CWORD
        local max_index=$((size-1))
        local args=($COMP_LINE)

        local name
        for ((i = 0; i < size; i++))
        do
            if [[ $i -eq $max_index ]];then
                name+=${args[$i]}
            else
                name+=${args[$i]}_
            fi
        done

        local completion_args="$(_completion_read $name)"

        if [[ "${#completion_args}" == 0 ]];then
            compopt -o default
        else
            compopt +o default
            COMPREPLY=( $(compgen -W "${completion_args}" -- ${cur}) )
        fi
    fi
}

_completion_setup() {
    # $1 target command
    if [[ "$MY_CURRENT_SHELL" == 'bash' ]];then
        complete -F _completion_complete $1
    fi
}

completion_generate() {
    while IFS= read -r item
    do
        # deal with _completion_register_write
        while IFS= read -r line
        do
            completion_args=$(echo "$line" | cut -d ' ' -f2-)
            _completion_write $completion_args
        done < <(s -f $item '_completion_register_write')

        # deal with _completion_register_generate
        while IFS= read -r line
        do
            IFS=' ' read -r -a array <<< "$line"
            completion_target="${array[1]}"
            # using eval to avoid apostrophe
            completion_dir="$(eval echo ${array[2]})"
            completion_pattern="${array[3]}"
            _completion_generate "$completion_target" "$completion_dir" "$completion_pattern"
        done < <(s -f $item _completion_register_generate)
        # filtered out some irrelevant files to boost performance
    done < <(find "$MY_SH_MODULE" -type f -iname "*.bash" | s 'src')
}
