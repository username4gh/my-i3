#! /usr/bin/env bash
if [[ "$(_check_os)" == 'Darwin' ]]; then
    # using macports
    if [[ "$MY_CURRENT_PM" == 'macports' ]];then
        # no need to install any '*completion' package, leave it to oh-my-zsh/bash-it

        # keep macports remaining completely isolated
        export PATH="/opt/local/bin:$PATH"
        export PATH="/opt/local/sbin:$PATH"
        export PATH="/opt/local/libexec/gnubin:$PATH"

        export MANPATH="/usr/share/man:/usr/local/share/man:/usr/X11/man"
        export MANPATH="/opt/local/share/man:/opt/local/man:${MANPATH}"

        if [[ -f /opt/local/etc/profile.d/bash_completion.sh ]]; then
            . /opt/local/etc/profile.d/bash_completion.sh
        fi
    elif [[ "$MY_CURRENT_PM" == 'homebrew' ]];then
        # using homebrew
        export PATH="/usr/local/bin:$PATH"

        # homebrew/versions/bash-completion2
        if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
            . $(brew --prefix)/share/bash-completion/bash_completion
        fi
    else
        echo "install macports or homebrew"
        echo "http://brew.sh/"
        echo "https://www.macports.org/"
    fi
fi
