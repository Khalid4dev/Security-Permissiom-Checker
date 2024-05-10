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


check_vul(){
    vulnerable_files=$(find "$1" -type f \( -perm -o=w -o -perm -o=x \))
    return $vulnerable_files
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

# Function to change permissions of a file
Change_Perm() {
    local files=$(find "$1" -type f)
    for file in $files; do
        chmod o-xw "$file" && chmod g-xw "$file"
        echo "$file"
    done
    echo "done"
}

# Function to encrypt files
Encrypt() {

    read -p "entrez le chemin de votre dossier : " dir
    
    local files=$(find "$dir" -type f)

    echo $files
    local password="${!#}"
    for file in $files; do
        echo $file
        if [ -f "$file" ]; then
            openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$file.enc" -k "$password"
            rm "$file"
        fi
    done
}

# Function to decrypt files
Decrypt(){
    read -p "entrez le chemin de votre dossier : " dir
    
    local files=$(find "$dir" -type f)
    local password="${!#}"
    for file in $files; do
        if [ -f "$file" ]; then
            if openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -out "${file%.enc}" -k "$password"; then
                echo "Decryption successful: $file"
                rm "$file"
            else
                echo "Decryption failed or incorrect password: $file"
                rm "${file%.enc}"
            fi
        fi
    done
}

# Function to weaken permissions of files in a directory
weaken(){
    dirs=$(find "$1" -type f)
    for file in $dirs;do
    chmod o+xw $file
    done
    echo "weaken done"
}

# FUnction Menu
menu(){
    echo "1. Compare Permissions"
    echo "2. Change Permissions"
    echo "3. Encrypt"
    echo "4. Decrypt"
    echo "5. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) compare_permissions ;;
        2) Change_Perm ;;
        3) Encrypt ;;
        4) Decrypt ;;
        5) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}