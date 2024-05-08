source functions.sh

# Call the function
compare_permissions


#!/bin/bash

source functions.sh

weaken $1

vulnerable_files=$(find "$1" -type f \( -perm -o=w -o -perm -o=x \))


Change_Perm "${vulnerable_files[@]}"

#Encrypt "${vulnerable_files[@]}" "er"
Decrypt "${vulnerable_files[@]}" "er"

