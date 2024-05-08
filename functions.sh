#!/bin/bash



# Function to check permissions of a file and return them
check_permissions() {
    file="$1"
    if [ ! -e "$file" ]; then
        echo "File '$file' does not exist."
        exit 1
    fi
    permissions=$(stat -c "%A" "$file")
    echo "$permissions"
}

# Function to compare permissions between two files
compare_permissions() {
    read -p "Enter path to first file: " file1
    read -p "Enter path to second file: " file2
    if [ -z "$file1" ] || [ -z "$file2" ]; then
        echo "Please provide paths to both files."
        exit 1
    fi
    permissions_file1=$(check_permissions "$file1")
    permissions_file2=$(check_permissions "$file2")
    if [ "$permissions_file1" = "$permissions_file2" ]; then
        echo "Permissions are identical for both files."
    else
        echo "Permissions are different:"
        echo "$file1: $permissions_file1"
        echo "$file2: $permissions_file2"
    fi
}


