#!/bin/bash

if [[ "$#" -ge 1 ]];then
    if [[ "$1" == 'copy' ]] ; then

        echo -n "$2" | pbcopy
        echo COPIED "$2"
    fi
    if [[ "$1" == 'set' ]] ; then
        exedir=$(grep EXE_UTIL_DIR ~/.bitbar_gitlab_cnf.yml|cut -d'"' -f2)
        /usr/bin/ruby $exedir/gitlab-bitbar-plugin.rb set $2 $3
        echo SET "$2 $3"
    fi
fi
