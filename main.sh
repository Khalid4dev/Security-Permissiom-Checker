#!/bin/bash

source functions.sh

case "$1" in
    -h)
        help
        exit 0
        ;;
    *)  
        help
        menu 
        ;;
    
esac


