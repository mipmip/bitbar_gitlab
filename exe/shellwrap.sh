#!/bin/bash

if [[ "$#" -ge 1 ]];then
    if [[ "$1" == 'copy' ]] ; then

        echo -n "$2" | pbcopy
        echo COPIED "$2"
    fi
    if [[ "$1" == 'set' ]] ; then
        /usr/bin/ruby ~/.BitBar/gitlab-bitbar-plugin.rb set $2 $3
        echo SET "$2 $3"
    fi
fi
