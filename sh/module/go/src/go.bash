#! /usr/bin/env bash

if [[ -d "$MY_BIN/go" ]];then
    export GOROOT="$MY_BIN/go"
    export PATH="$GOROOT/bin:$PATH"
fi

if [[ -d "$HOME/go" ]];then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi
