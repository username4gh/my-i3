#! /usr/bin/env bash

if [[ $(whoami) != root ]];then
    _my_load_sh_files $MY_SH_MODULE/java src
    export PATH="$MY_SH_MODULE/java/script:$PATH"
fi
