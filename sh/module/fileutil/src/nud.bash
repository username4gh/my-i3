#! /usr/bin/env bash

nud() {
    if [[ "$1" =~ [0-9]+ ]];then
        cd "$(nlu $1)"
    else
        echo "plz enter a valid number, use nlu to list all valid number"
    fi
}
