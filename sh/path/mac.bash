#! /usr/bin/env bash

if [[ "$(_check_os)" == 'Darwin' ]]; then
    if [[ "$MY_CURRENT_PACKAGE_MANAGER" == 'macports' ]];then
        # no need to install any '*completion' package, leave it to oh-my-zsh/bash-it
        export PATH="/opt/local/bin:$PATH"
        export PATH="/opt/local/sbin:$PATH"
        export PATH="/opt/local/libexec/gnubin:$PATH"

        export MANPATH="/usr/share/man:/usr/local/share/man:/usr/X11/man"
        export MANPATH="/opt/local/share/man:/opt/local/man:${MANPATH}"

        if [[ -f /opt/local/etc/profile.d/bash_completion.sh ]]; then
            . /opt/local/etc/profile.d/bash_completion.sh
        fi
    elif [[ "$MY_CURRENT_PACKAGE_MANAGER" == 'homebrew' ]];then
        export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

        # prefer `homebrew/versions/bash-completion2`, the `bash-completion` package wonn't work properly with other stuff in this dotfile, some function is missing
        if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
            . $(brew --prefix)/share/bash-completion/bash_completion
        fi
    else
        echo "install [macports](https://www.macports.org/) or [homebrew](http://brew.sh/)"
    fi
fi
