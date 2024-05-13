#!/bin/bash

source functions.sh

case "$1" in
    -h)
        help
        exit 0
        ;;
    -f)
        fork_command "$2"
        ;;
    -t)
        thread_command "${@:2}"
        ;;
    -s)
        subshell_command "${@:2}"
        ;;
    -l)
        log_command "$2"
        ;;
    -r)
        restore_command
        ;;
    *)
        menu
        ;;
    
esac


