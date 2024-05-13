#!/bin/bash

source functions.sh

if [[ "$1" == "-h" ]]; then
    display_help
    exit 0
    else
    menu
fi


