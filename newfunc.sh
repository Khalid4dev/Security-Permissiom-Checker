#!/bin/bash

fork(){
    echo "$1"
    python3 -c "import subprocess; subprocess.run(['bash', '-c', '. \"$0\"; $1'])"
}

# Function to check permissions of a file and return them
checkPermission() {
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
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "compare_permissions $@"
        exit 0;;
    
    esac
    while true; do
        read -p "Enter path to first file: " file1
        read -p "Enter path to second file: " file2

        if [ -z "$file1" ] || [ -z "$file2" ]; then
            echo "Please provide paths to both files."
            continue
        fi

        if [ ! -e "$file1" ]; then
            echo "First file does not exist. Please enter an existing file."
            continue
        fi

        if [ ! -e "$file2" ]; then
            echo "Second file does not exist. Please enter an existing file."
            continue
        fi

        break
    done
    permissions_file1=$(checkPermission "$file1")
    permissions_file2=$(checkPermission "$file2")
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
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Encrypt $@"
        exit 0;;
    
    esac
    while true; do
        read -p "Enter the directory path: " dir
        if [ ! -d "$dir" ]; then
            echo "Directory does not exist."
            continue
        fi
        break
    done
    local files=$(find "$dir" -type f)
    for file in $files; do
        chmod o-xw "$file" && chmod g-xw "$file"
        echo "$file"
    done
    echo "done"
}

# Function to encrypt files
Encrypt() {
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Encrypt $@"
        exit 0;;
    
    esac

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
Decrypt() {
    case "$1" in
    -h)
    echo "This function Encypts of a all files in given directory."
        echo "You will be prompted to enter the path of a directory. and the wanted password"
        echo "-h shows help , -f to fork the command , -s run it in a subshell , -t to use threads"
        exit 0;;
    -f)
        shift # Move to the next argument after -f
        fork "Decrypt $@"
        exit 0;;
    
    esac
    read -p "Enter the directory path: " dir
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

# Parse command line arguments
while getopts ":hf" opt; do
    case ${opt} in
        h ) # Display help message
            echo "Usage: $0 [option]"
            echo "Options:"
            echo "  -h (help)          Display detailed documentation of the program"
            echo "  enc                Run the Encryption command"
            echo "  dec                Run the Decryption command"
            echo "  cmpp               Compare two files Permisions"
            echo "  cp                 Change the a Directory SubFolders Permissions"
            echo "Example:"
            echo "  enc -f"
            exit 0
            ;;
       
        \? ) echo "Invalid option: $OPTARG" 1>&2;;
    esac
done
shift $((OPTIND -1))

# If -f option is provided, then fork the command and exit
if [ "$1" = "-f" ]; then
    shift # Move to the next argument after -f
    fork "$@"
    exit 0
fi

# If no options are provided, show help
# if [ $# -eq 0 ]; then
#     echo "No options provided."
    
#     exit 1
# fi

# Otherwise, execute the specified function
case "$1" in
    enc) Encrypt "${@:2}" ;;
    dec) Decrypt "${@:2}" ;;
    cmpp) compare_permissions "${@:2}" ;;
    cp) Change_Perm "${@:2}" ;;
    
esac
